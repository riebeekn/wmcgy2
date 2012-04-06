class TransactionsController < ApplicationController
  before_filter :signed_in_user
  
  def index
    @transactions = current_user.transactions.page(params[:page])
  end
end
