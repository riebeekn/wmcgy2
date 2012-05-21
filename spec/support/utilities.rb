include ActionView::Helpers::NumberHelper

def sign_in(user)
  visit signin_path
  fill_in "session_email",    with: user.email
  fill_in "session_password", with: user.password
  click_button "Sign in"
end

def full_title(page_title)
  base_title = I18n.t(:app_base_title)
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def display_amount(transaction)
  number_to_currency(transaction.amount) 
end