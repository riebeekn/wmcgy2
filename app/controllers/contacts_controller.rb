class ContactsController < ApplicationController
  def new
    @message = Message.new
  end
  
  def create
     @message = Message.new(params[:message])
      if @message.valid?
        ContactMailer.contact_us(@message).deliver
        redirect_to new_contact_path, notice: "Message sent! Thank you for contacting us."
      else
        render "new"
      end
  end
end
