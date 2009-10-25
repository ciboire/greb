class BootcampsController < ApplicationController

  # Main page
  def index
    session[:section] = 'home'
  end
  
  # When and where
  def overview
    session[:section] = 'overview'
  end
  
  # Contact form
  def contact
    session[:section] = 'contact'
  end
  
  # Contact form
  def links
    session[:section] = 'links'
  end
  
  # Registration form
  def register
    session[:section] = 'register'
    @student = Student.create(:bootcamp_id => params[:bootcamp_id])
  end
  
  # Reminder form
  def reminder
    session[:section] = 'reminder'
    @bootcamp = Bootcamp.find(params[:bootcamp_id])
  end
  
  def deliver_reminder
     # Check form of email
     @bootcamp = Bootcamp.find(params[:bootcamp_id])
     reg = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
     unless (reg.match(params[:reminder][:email]) ? true : false)
       flash.now[:error] = "Email needs to be in the form user@example.com."
       render :controller => :bootcamps, :action => :reminder
       return
     end

     if Notifications.deliver_reminder(params[:reminder], @bootcamp.id)
       flash[:notice] = "A reminder will be sent to you."
       redirect_to :controller => :bootcamps, :action => :reminder, :bootcamp_id => @bootcamp.id
     else
       flash.now[:error] = "An error occurred while setting up reminder.  Please try again."
       render :controller => :bootcamps, :action => :reminder
     end
  end
  
  def update_reg_contact_info
		@student = Student.find(params[:student_id])
		@student.email = params[:email]
		@student.name = params[:name]
		@student.save
		render :nothing => true
	end
  
  def deliver_contact
    # Check form of email
    reg = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    unless (reg.match(params[:contact][:email]) ? true : false)
      flash.now[:error] = "Email needs to be in the form user@example.com."
      render :controller => :bootcamps, :action => :contact
      return
    end
    
    if Notifications.deliver_contact(params[:contact])
      flash[:notice] = "Your email was successfully sent."
      redirect_to :controller => :bootcamps, :action => :contact
    else
      flash.now[:error] = "An error occurred while sending this email.  Please try again."
      render :controller => :bootcamps, :action => :contact
    end
  end


  #------------------------------------------------------------------------------------------------
  #
  # PDT callback.
  #
  def thanks
    session[:section] = 'register'

    bad_transaction = 'An error occurred while retrieving payment information from PayPal.<br />' \
    + 'Please contact support@vegaphysics.com for assistance.'

    tx_token = params['tx']

    if tx_token.blank?
      logger.info('Missing PayPal transaction token')
      flash[:error] = bad_transaction
      return
    end

    if Payment.find_by_tx_token(tx_token)
      logger.info("Duplicate PayPal transaction token #{tx_token}")
      flash[:error] = "We have already completed transaction #{tx_token}.<br /><br />Thank you for your payment.<br /><br />" \
      + " A receipt for your purchase was emailed to you."
      return
    end

    # Payment Data Transfer identity token from
    # PayPal.com > Profile > Website Payment Preferences
    id_token = 'PC-XFy7qV1jXUU9CCYCJPsJTlxXD5Vu5cfmzEuS0Lrx9qn4OUvcUeH-8ODy'
    uri = URI.parse('http://www.paypal.com/cgi-bin/webscr')

    request_path = "at=" + id_token + "&tx=" + tx_token + "&cmd=_notify-synch"
    logger.info "PDT query to PayPal: #{request_path}"

    response = nil

    Net::HTTP.start(uri.host, uri.port) do |request|
      response = request.post(uri.path, request_path).body
    end

    logger.info "PDT response from PayPal: #{response}"
    status = response.split[0]
    logger.info "PDT status: #{status}"

    unless 'SUCCESS' == status
      logger.info("Unexpected PDT status: #{status}")
      flash[:error] = bad_transaction
      return
    end

    # Unpack the transaction details from the PDT into the params hash.
    response.each do |line|
      key, value = line.scan( %r{^(\w+)\=(.*)$} ).flatten
      params[key] = CGI.unescape(value) if key
    end

    # Check email address to prevent spoof payments.
    receiver_email = params['receiver_email']

    unless receiver_email == 'admin@vegaphysics.com'
      logger.info("Unexpected PDT receiver email: #{receiver_email}")
      flash[:error] = bad_transaction
      return
    end

    custom = params['custom'].split
    student_id = custom[0]
    bootcamp_id = custom[1]
    description = "student_id: #{student_id}; bootcamp_id: #{bootcamp_id}"
    payment_gross = params['mc_gross']
    logger.info "PDT gross payment: #{payment_gross}"
    logger.info "PDT #{description}"
    logger.info "PDT custom: " + params['custom']
    
    # Save a copy of the transaction in case there is a dispute
    Payment.create(:description => description, :student_id => student_id, :bootcamp_id => bootcamp_id,
      :amount => payment_gross, :tx_token => tx_token)
    flash[:success] = 'Thank you for your payment!  Your registration is complete.'
    
    # Update Student table to reflect successful transaction
    @student = Student.find(student_id)
    @student.tx_token = tx_token
    @student.tx_accepted = true
    @student.save
    
    # Update Bootcamp table
    @bootcamp = Bootcamp.find(bootcamp_id)
    if (Student.count(:all, :conditions => {:bootcamp_id => bootcamp_id, :tx_accepted => true}) > @bootcamp.max_students)
      @bootcamp.space_available = false
      @bootcamp.save
    end
    
    # Email student confirmation
    subject = "Registration confirmation for GRE Bootcamp Math Review"
    Notifications.deliver_confirmation("#{@student.id}", "#{@bootcamp.id}", subject)
    
    @bootcamp_id = @bootcamp.id
    @student_id = @student.id
  end


  #------------------------------------------------------------------------------------------------
  #
  # IPN callback.
  #
  # Receive asynchronous Instant Payment Notification POSTs from PayPal.
  # Verify the payload by echoing it back to PayPal.
  # Perform some sanity checks, then update the Payments table if
  # the transaction has completed.
  #
  def get_ipn
    logger.info "Incoming IPN raw: #{request.raw_post}"
    logger.info "Incoming IPN params: #{params}"

    # Reply to PayPal's notifier that we received its message.
    render :status => :ok, :nothing => true

    uri = URI.parse('http://www.paypal.com/cgi-bin/webscr')

    request_path = 'cmd=_notify-validate&' + request.raw_post
    logger.info "IPN query to PayPal: #{request_path}"

    response = nil

    # Echo the payload back to PayPal.
    Net::HTTP.start(uri.host, uri.port) do |request|
      response = request.post(uri.path, request_path).body
    end

    logger.info "IPN response from PayPal: #{response}"

    # Make sure the transaction is valid.
    unless 'VERIFIED' == response
      logger.info("Unexpected IPN status: #{response}")
      return
    end

    # Don't process the same transaction twice.
    tx_token = params['txn_id']
    if Payment.find_by_tx_token(tx_token)
      logger.info("Duplicate PayPal transaction ID #{tx_token}")
      return
    end

    # Check email address to prevent spoof payments.
    unless 'admin@vegaphysics.com' == params['receiver_email']
      logger.info("Unexpected IPN receiver email: #{params['receiver_email']}")
      return
    end

    # Save completed transactions only.
    unless 'Completed' == params['payment_status']
      logger.info("Unexpected IPN payment status: #{params['payment_status']}")
      return
    end
    
    custom = params['custom'].split
    student_id = custom[0]
    bootcamp_id = custom[1]
    description = "student_id: #{student_id}; bootcamp_id: #{bootcamp_id}"
    payment_gross = params['mc_gross']
    logger.info "IPN gross payment: #{payment_gross}"
    logger.info "IPN #{description}"
    logger.info "IPN custom: " + params['custom']
    
    # Save a copy of the transaction in case there is a dispute
    Payment.create(:description => description, :student_id => student_id, :bootcamp_id => bootcamp_id,
      :amount => payment_gross, :tx_token => tx_token)
    
    # Update Student table to reflect successful transaction
    @student = Student.find(student_id)
    @student.tx_token = tx_token
    @student.tx_accepted = true
    @student.save
    
    # Update Bootcamp table
    @bootcamp = Bootcamp.find(bootcamp_id)
    if (Student.count(:all, :conditions => {:bootcamp_id => bootcamp_id, :tx_accepted => true}) > @bootcamp.max_students)
      @bootcamp.space_available = false
      @bootcamp.save
    end

    # Email student confirmation
    subject = "Registration confirmation for GRE Bootcamp Math Review"
    Notifications.deliver_confirmation("#{@student.id}", subject)
  end
end