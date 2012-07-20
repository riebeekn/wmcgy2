class TransactionsController < ApplicationController
  helper_method :sort_column, :sort_direction 
  
  def index
    respond_to do |format|
      format.html { @transactions = sort }
      format.csv { 
        csv_transactions = current_user.transactions.all(include: :category, order: "date desc")
        send_data Transaction.to_csv(csv_transactions)
      }
    end
  end
  
  def new
    @category_names = populate_category_names  
    @transaction = Transaction.new(amount: nil, is_debit: true)
  end
  
  def create
    @transaction = build_transaction(params[:transaction], params[:transaction][:amount],
                                      params[:transaction][:category_name])
    if @transaction.save
      redirect_to transactions_path
    else
      @category_names = populate_category_names
      @transaction.date = params[:transaction][:date]
      @transaction.amount = stringify_amount(params[:transaction][:amount])
      @transaction.category.name = params[:transaction][:category_name]
      render 'new'
    end
  end
  
  def edit
    @categories = current_user.categories
    @transaction = current_user.transactions.find(params[:id])
    @transaction.amount = stringify_amount(@transaction.amount)
    @transaction.date = @transaction.date.strftime('%d %b %Y')
    @category_class = get_category_css_class(@transaction.category_name)
    @category_span = get_category_span(@transaction.category_name)
  end
  
  def update
    numeralize_amount(params[:transaction][:amount])
    @transaction = current_user.transactions.find(params[:id])
    if @transaction.update_attributes(params[:transaction])
      redirect_to transactions_path, notice: "Transaction updated"
    else
      @category_class = get_category_css_class(params[:transaction][:category_name])
      @category_span = get_category_span(params[:transaction][:category_name])
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
  
    def get_category_css_class(category)
      "error" if category.nil?
    end
    
    def get_category_span(category)
      "<span class='help-inline'>can't be blank</span>" if category.nil?
    end
    
    def build_transaction(transaction, amount, category_name)
      numeralize_amount(amount)
      transaction = current_user.transactions.build(transaction)
      transaction.skip_category_validation = true
      if transaction.valid?
        transaction.category = current_user.categories.find_or_create_by_name(
              category_name.strip)
      end
      transaction.skip_category_validation = false
      return transaction
    end
    
    def numeralize_amount(amount)
      amount.gsub!("$", "")
    end
    
    def stringify_amount(amount)
      sprintf("%.2f", amount.to_f.abs) unless amount == '' or amount.to_f == 0
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
