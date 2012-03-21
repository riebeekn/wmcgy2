class Session
  include ActiveAttr::Model
  # note class just allows for simple form to be used
  attribute :email
  attribute :password
  attribute :remember_me, type: Integer
  
end