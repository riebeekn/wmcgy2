module TransactionsHelper
  
  def display_amount(transaction)
    if transaction.is_debit?
      "-#{number_to_currency(transaction.amount)}"
    else
      number_to_currency(transaction.amount) 
    end
  end
end