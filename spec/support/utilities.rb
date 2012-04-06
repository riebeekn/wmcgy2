include ActionView::Helpers::NumberHelper

def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
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
  if transaction.is_debit?
    "-#{number_to_currency(transaction.amount)}"
  else
    number_to_currency(transaction.amount) 
  end
end