class TransactionsController < ApplicationController
  before_filter :signed_in_user
  helper_method :sort_column, :sort_direction 
  
  def index
    if params[:sort] == "category"
      @transactions = sort_by_category
    else
      @transactions = sort
    end
  end
  
  def new
    @categories = current_user.categories
    @transaction = Transaction.new
  end
  
  def create
    @transaction = build_transaction
    if @transaction.save
      redirect_to transactions_path
    else
      render 'new'
    end
  end
  
  private
  
    def build_transaction
      @transaction = current_user.transactions.build(params[:transaction])
      if @transaction.is_debit?
        @transaction.amount = @transaction.amount.abs * -1
      else
        @transaction.amount = @transaction.amount.abs
      end
      @transaction
    end
    
    def sort
      current_user.transactions.order("#{sort_column} #{sort_direction}").page(params[:page])
    end
    
    def sort_by_category
      current_user.transactions.paginate(page: params[:page], include: :category, 
                                         order: "categories.name #{sort_direction}")
    end
  
    def sort_column
      #Transaction.column_names.include?(params[:sort]) ? params[:sort] : "date"
      # NOTE: above allows user to sort on other columns, which is probably ok but
      #       I think the below is better
      %w[date category description amount].include?(params[:sort]) ? params[:sort] : "date"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
