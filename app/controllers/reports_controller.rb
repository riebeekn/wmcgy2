class ReportsController < ApplicationController
  before_filter :signed_in_user
  
  def index
  end
  
  def expenses
    render :json => {
      type: 'PieChart',
      cols: [['string', 'Category'], ['number', 'Amount']],
      rows: current_user.expenses_by_category_and_date_range(mtd_ytd_or_all).
              collect { |r| [r.name == nil ? "Uncategorized" : r.name, r.sum.to_f.abs] },
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
      rows: current_user.income_by_category_and_date_range(mtd_ytd_or_all).
              collect { |r| [r.name == nil ? "Uncategorized": r.name, r.sum.to_f] },
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
      rows: calculate_income_expenses(ytd_or_all),
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
      rows: calculate_profit_loss(ytd_or_all),
      options: { 
        backgroundColor: { fill:'#F5F5F5'},
        title: 'Overall profit / loss', isStacked: true,
        titleTextStyle: { fontSize: 18} },
      format_cols: [1,2]
    }
  end
  
  private
  
    def mtd_ytd_or_all
      %w[month year all].include?(params[:range]) ? params[:range] : "month"
    end
    
    def ytd_or_all
      %w[year all].include?(params[:range]) ? params[:range] : "year"
    end

    def period_value(range, period)
      if range == 'year'
        Date::MONTHNAMES[period.to_i][0..2]
      else
        period
      end
    end
  
    def calculate_income_expenses(range)
      if range == "all"
        expenses = current_user.expenses_by_year
        income = current_user.income_by_year
      else
        expenses = current_user.expenses_by_month_for_current_year
        income = current_user.income_by_month_for_current_year
      end
      
      results = []
      expenses.each do |exp|
        income.each do |inc|
          if exp.period == inc.period
            logger.debug "found"
            results <<  [period_value(range, exp.period),
                        inc.sum.to_f,
                        exp.sum.to_f.abs]
          end
        end
      end
      
      results
    end
    
    def calculate_profit_loss(range)
      if range == "all"
        expenses = current_user.expenses_by_year
        income = current_user.income_by_year
      else
        expenses = current_user.expenses_by_month_for_current_year
        income = current_user.income_by_month_for_current_year
      end
      
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
end
