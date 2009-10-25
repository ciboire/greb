class Notifications < ActionMailer::Base
  def contact(email_params)
    subject       email_params[:subject]
    recipients    "support@grebootcamp.com"
    from          email_params[:email]
    content_type  'text/html'
    sent_on       Time.now
    body          email_params[:body]
  end
  
  def confirmation(student_id, bootcamp_id, subj)
    subject       subj
    recipients    Student.find(student_id).email
    from          "registration@grebootcamp.com"
    content_type  'text/html'
    sent_on       Time.now
    body          :student_id => student_id, :bootcamp_id => bootcamp_id
  end
  
  def reminder(email_params, bootcamp_id)
    subject       "Remind #{email_params[:name]} about Bootcamp #{bootcamp_id}"
    recipients    "support@grebootcamp.com"
    from          email_params[:email]
    content_type  'text/html'
    sent_on       Time.now
    body          "Remind #{email_params[:name]} (#{email_params[:email]}) about Bootcamp #{bootcamp_id}:  #{Bootcamp.find(bootcamp_id).date} in #{Bootcamp.find(bootcamp_id).city}"
  end
end