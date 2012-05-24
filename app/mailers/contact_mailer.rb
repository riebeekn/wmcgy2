class ContactMailer < ActionMailer::Base
  default from: "contact.us@example.com"

  def contact_us(message)
    @content = message.content
    mail  to: "nick.riebeek@gmail.com", 
          from: "#{message.email}", 
          subject: "Contact us email from wmcgy sent by #{message.name}"
  end
end
