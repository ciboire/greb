# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def self.email_regex
     /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
   end

   def self.email_message
     'needs to be in the form user@example.com.'
   end
end

