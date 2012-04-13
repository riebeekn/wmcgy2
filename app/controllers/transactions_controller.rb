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
    @transaction = Transaction.new(amount: nil)
  end
  
  def create
    @transaction = build_transaction_for_create
    if @transaction.save
      redirect_to transactions_path
    else
      @categories = current_user.categories
      render 'new'
    end
  end
  
  def edit
    @categories = current_user.categories
    @transaction = get_transaction_for_edit
  end
  
  def update
    if build_transaction_for_update.update_attributes(params[:transaction])
      redirect_to transactions_path, notice: "Transaction updated"
    else
      @categories = current_user.categories
      render 'edit'
    end
  end
  
  def destroy
    current_user.transactions.destroy(params[:id])
    redirect_to transactions_path, notice: "Transaction deleted."
  end
  
  private
  
    def get_transaction_for_edit
      @transaction = current_user.transactions.find(params[:id])
      @transaction.amount = @transaction.amount.abs
      @transaction.date = @transaction.date.strftime('%d %b %Y')
      @transaction
    end
    
    def build_transaction_for_update
      @transaction = current_user.transactions.find(params[:id])
      normalize_amount @transaction
    end
    
    def build_transaction_for_create
      @transaction = current_user.transactions.build(params[:transaction])
      if @transaction.amount != nil
        if @transaction.is_debit?
          @transaction.amount = @transaction.amount.abs * -1
        else
          @transaction.amount = @transaction.amount.abs
        end
      end
      @transaction
    end
    
    def normalize_amount(transaction)
      if transaction.amount != nil
        if transaction.is_debit?
          transaction.amount = transaction.amount.abs * -1
        else
          transaction.amount = transaction.amount.abs
        end
      end
      transaction
    end
    
    # --- SORTING ---
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
    # --- END SORTING ---
end
