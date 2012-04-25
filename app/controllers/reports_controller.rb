class ReportsController < ApplicationController
  before_filter :signed_in_user
  
  def index
  end
  
  def expenses
    render :json => {
      type: 'PieChart',
      cols: [['string', 'Category'], ['number', 'Amount']],
      rows: (expenses_by_category top_chart_range),
      options: { 
        backgroundColor: { fill:'#F5F5F5'},
        title: 'Expenses', is3D: true, titleTextStyle: { fontSize: 18} },
      format_cols: [1]
    }
  end
  
  def income
    render :json => {
      type: 'PieChart',
      cols: [['string', 'Category'], ['number', 'Amount']],
      rows: (income_by_category top_chart_range),
      options: { 
        backgroundColor: { fill:'#F5F5F5'},
        title: 'Income', is3D: true, titleTextStyle: { fontSize: 18} },
      format_cols: [1]
    }
  end
  
  def income_and_expense
    render :json => {
      type: 'LineChart',
      cols: [['string', 'Month'], ['number', 'Income'], ['number', 'Expenses']],
      rows: (calculate_income_expenses bottom_chart_range),
      options: { 
        backgroundColor: { fill:'#F5F5F5'},
        title: 'Overall income and expenses', 
        titleTextStyle: { fontSize: 18}, pointSize: 5 },
      format_cols: [1,2]
    }
  end
  
  def profit_loss
    render :json => {
      type: 'ColumnChart',
      cols: [['string', 'Month'], ['number', 'Profit'], ['number', 'Loss']],
      rows: (calculate_profit_loss bottom_chart_range),
      options: { 
        backgroundColor: { fill:'#F5F5F5'},
        title: 'Overall profit / Loss', isStacked: true,
        titleTextStyle: { fontSize: 18} },
      format_cols: [1,2]
    }
  end
  
  private
  
    def top_chart_range
      %w[month year all].include?(params[:range]) ? params[:range] : "month"
    end
    
    def bottom_chart_range
      %w[year all].include?(params[:range]) ? params[:range] : "year"
    end

    def period_value(range, period)
      if range == 'year'
        Date::MONTHNAMES[period.to_i][0..2]
      else
        period
      end
    end
  
    def expenses_by_category(range)
      if range == 'all'
        current_user.transactions.
            select("name, SUM(amount)").
            joins("LEFT JOIN categories on categories.id = transactions.category_id").
            where("is_debit=true").
            group("name").collect { |r| [r.name == nil ? "Uncategorized" : r.name, r.sum.to_f.abs] }
      else
        current_user.transactions.
          select("name, SUM(amount)").
          joins("LEFT JOIN categories on categories.id = transactions.category_id").
          where("DATE_TRUNC('#{range}', date) = DATE_TRUNC('#{range}', now()) AND is_debit=true").
          group("name").collect { |r| [r.name == nil ? "Uncategorized" : r.name, r.sum.to_f.abs] }
      end
    end
    
    def income_by_category(range)
      if range == 'all'
        current_user.transactions.
          select("name, SUM(amount)").
          joins("LEFT JOIN categories on categories.id = transactions.category_id").
          where("is_debit=false").
          group("name").collect { |r| [r.name == nil ? "Uncategorized": r.name, r.sum.to_f] }
      else
        current_user.transactions.
          select("name, SUM(amount)").
          joins("LEFT JOIN categories on categories.id = transactions.category_id").
          where("DATE_TRUNC('#{range}', date) = DATE_TRUNC('#{range}', now()) AND is_debit=false").
          group("name").collect { |r| [r.name == nil ? "Uncategorized": r.name, r.sum.to_f] }
      end
    end
    
    def calculate_income_expenses(range)
      expenses = expenses_query range
      income =   income_query range
      
      results = []
      expenses.each do |exp|
        income.each do |inc|
          if exp.period == inc.period
            results <<  [period_value(range, exp.period),
                        inc.sum.to_f,
                        exp.sum.to_f.abs]
          end
        end
      end
      
      results
    end
    
    def calculate_profit_loss(range)
      expenses = expenses_query range
      income =   income_query range
      
      results = []
      expenses.each do |exp|
        income.each do |inc|
          if exp.period == inc.period
            profit_loss = inc.sum.to_f + exp.sum.to_f
            results <<  [period_value(range, exp.period),
                        profit_loss > 0 ? profit_loss : 0,
                        profit_loss < 0 ? profit_loss : 0]
          end
        end
      end
      
      results
    end
    
    def expenses_query(range)
      if range == 'all'
        current_user.transactions.
          select("extract(year from date) as period, sum(amount)").
          where("is_debit = true").
          group(1).
          order(1)
      else
        current_user.transactions.
          select("extract(month from date) as period, sum(amount)").
          where("date_trunc('#{range}', date) = date_trunc('#{range}', now()) AND is_debit = true").
          group(1).
          order(1)
      end
    end
    
    def income_query(range)
      if range == 'all'
        current_user.transactions.
          select("extract(year from date) as period, sum(amount)").
          where("is_debit = false").
          group(1).
          order(1)
      else
        current_user.transactions.
          select("extract(month from date) as period, sum(amount)").
          where("date_trunc('#{range}', date) = date_trunc('#{range}', now()) AND is_debit = false").
          group(1).
          order(1)
      end
    end
end
