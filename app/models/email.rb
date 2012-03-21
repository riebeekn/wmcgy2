class Email
  include ActiveAttr::Model
  
  def self.EMAIL_REGEX
    /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  end
  
  attribute :email
  validates_format_of :email, :with => self.EMAIL_REGEX
  
end