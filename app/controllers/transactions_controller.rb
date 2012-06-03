class TransactionsController < ApplicationController
  include ActionView::Helpers::NumberHelper
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
    populate_category_names  
    @transaction = Transaction.new(amount: nil, is_debit: true)
  end
  
  def create
    @transaction = build_transaction_for_create
    @transaction.category = current_user.categories.find_or_create_by_name(
          params[:transaction][:category_name].strip)
    if @transaction.save
      redirect_to transactions_path
    else
      populate_category_names
      @transaction.date = params[:transaction][:date]
      @transaction.amount = ''
      render 'new'
    end
  end
  
  def edit
    @categories = current_user.categories
    @transaction = get_transaction_for_edit
  end
  
  def update
    @transaction = build_transaction_for_edit
    if @transaction.save
      redirect_to transactions_path, notice: "Transaction updated"
    else
      @categories = current_user.categories
      @transaction.amount = ''
      render 'edit'
    end
  end
  
  def destroy
    current_user.transactions.destroy(params[:id])
    redirect_to transactions_path, notice: "Transaction deleted."
  end
  
  private
  
    def populate_category_names
      @categories = current_user.categories
      @category_names = @categories.map do |c| 
                          c.name + ':::'
                        end
    end
    
    def get_transaction_for_edit
      @transaction = current_user.transactions.find(params[:id])
      @transaction.amount = number_to_currency(@transaction.amount.abs).gsub("$", "").gsub(",","")
      @transaction.date = @transaction.date.strftime('%d %b %Y')
      @transaction
    end
    
    def build_transaction_for_create
      @transaction = current_user.transactions.build(params[:transaction])
      @transaction.date = add_time_to_date(@transaction.date, DateTime.now)
      @transaction.amount = params[:transaction][:amount].gsub("$", "")
      normalize_amount(@transaction)
    end
    
    def build_transaction_for_edit
      @transaction = current_user.transactions.find(params[:id])
      origDate = @transaction.date
      @transaction.attributes = { 
        is_debit: params[:transaction][:is_debit],
        date: params[:transaction][:date],
        category_id: params[:transaction][:category_id],
        description: params[:transaction][:description],
        amount: params[:transaction][:amount].gsub("$", "")
      }
      
      normalize_amount(@transaction)
    end
    
    def add_time_to_date(date_to_add_time_to, time_to_add)
      if date_to_add_time_to != nil
        date_to_add_time_to + (time_to_add.hour).hour +
                              (time_to_add.min).minute +
                              (time_to_add.sec).second
      end
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
      current_user.transactions.paginate(page: params[:page], include: :category,
                                         order: "#{sort_column} #{sort_direction}")
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
