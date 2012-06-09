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
    numeralize_amount(params[:transaction][:amount])
    @transaction = current_user.transactions.build(params[:transaction])
    @transaction.category = current_user.categories.find_or_create_by_name(
          params[:transaction][:category_name].strip)
    if @transaction.save
      redirect_to transactions_path
    else
      @category_names = populate_category_names
      @transaction.date = params[:transaction][:date]
      @transaction.amount = stringify_amount(params[:transaction][:amount])
      render 'new'
    end
  end
  
  def edit
    @categories = current_user.categories
    @transaction = current_user.transactions.find(params[:id])
    @transaction.amount = stringify_amount(@transaction.amount)
    @transaction.date = @transaction.date.strftime('%d %b %Y')
  end
  
  def update
    numeralize_amount(params[:transaction][:amount])
    @transaction = current_user.transactions.find(params[:id])
    if @transaction.update_attributes(params[:transaction])
      redirect_to transactions_path, notice: "Transaction updated"
    else
      @categories = current_user.categories
      @transaction.amount = stringify_amount(params[:transaction][:amount])
      render 'edit'
    end
  end
  
  def destroy
    current_user.transactions.destroy(params[:id])
    redirect_to transactions_path, notice: "Transaction deleted."
  end
  
  private
  
    def numeralize_amount(amount)
      amount.gsub!("$", "")
    end
    
    def stringify_amount(amount)
      sprintf("%.2f", amount.to_f.abs)
    end
    
    def populate_category_names
      # categories are seperated with ':::' for parsing in the js
      current_user.categories.map do |c| 
        c.name + ':::'
      end
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
