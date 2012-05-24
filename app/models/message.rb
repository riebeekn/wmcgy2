class Message
  include ActiveAttr::Model
  
  attribute :name
  attribute :email
  attribute :content
  
  attr_accessible :name, :email, :content

  validates_presence_of :name, :content
  validates_format_of :email, with: Email.EMAIL_REGEX 
  validates_length_of :content, maximum: 500
end
