class TransactionsController < ApplicationController
  before_filter :signed_in_user
  helper_method :sort_column, :sort_direction 
  
  def index
    @transactions = sort
  end
  
  def new
    @category_names = populate_category_names  
    @transaction = Transaction.new(amount: nil, is_debit: true)
  end
  
  def create
    @transaction = build_transaction_for_create(params[:transaction][:amount])
    @transaction.category = current_user.categories.find_or_create_by_name(
          params[:transaction][:category_name].strip)
    if @transaction.save
      redirect_to transactions_path
    else
      @category_names = populate_category_names
      @transaction.date = params[:transaction][:date]
      @transaction.amount = sprintf("%.2f", params[:transaction][:amount].gsub("$", "").to_f)
      render 'new'
    end
  end
  
  def edit
    @categories = current_user.categories
    @transaction = get_transaction_for_edit(params[:id])
  end
  
  def update
    @transaction = current_user.transactions.find(params[:id])
    params[:transaction][:amount].gsub!("$", "") # switch this to callback on model?
    if @transaction.update_attributes(params[:transaction])
      redirect_to transactions_path, notice: "Transaction updated"
    else
      @categories = current_user.categories
      @transaction.amount = sprintf("%.2f", params[:transaction][:amount].gsub("$", "").to_f)
      render 'edit'
    end
  end
  
  def destroy
    current_user.transactions.destroy(params[:id])
    redirect_to transactions_path, notice: "Transaction deleted."
  end
  
  private
  
    def populate_category_names
      # categories are seperated with ':::' for parsing in the js
      current_user.categories.map do |c| 
        c.name + ':::'
      end
    end
    
    def get_transaction_for_edit(transaction_id)
      transaction = current_user.transactions.find(transaction_id)
      transaction.amount = sprintf("%.2f", transaction.amount.abs)
      transaction.date = transaction.date.strftime('%d %b %Y')
      transaction
    end
    
    def build_transaction_for_create(amount)
      transaction = current_user.transactions.build(params[:transaction])
      transaction.date = add_time_to_date(transaction.date, DateTime.now)
      transaction.amount = amount.gsub("$", "")
      normalize_amount(transaction)
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
      sort_string = params[:sort] == "category" ? "categories.name" : sort_column
      current_user.transactions.paginate(page: params[:page], include: :category,
                                         order: "#{sort_string} #{sort_direction}")
    end
  
    def sort_column
      %w[date category description amount].include?(params[:sort]) ? params[:sort] : "date"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
    # --- END SORTING ---
end
