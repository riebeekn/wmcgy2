class TransactionsController < ApplicationController
  before_filter :signed_in_user
  
  def index
    @transactions = current_user.transactions
  end
end
