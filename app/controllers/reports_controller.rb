class ReportsController < ApplicationController
  
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
        period.to_s
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
      
      periods = calculate_period(expenses, income, range)
      results = []
      periods.each do |period|
        exp_value = get_value_for_period(expenses, period)
        inc_value = get_value_for_period(income, period)
        results << [period_value(range, period),
                            inc_value.to_f,
                            exp_value.to_f.abs]
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
      
      periods = calculate_period(expenses, income, range)
      results = []
      periods.each do |period|
        exp_value = get_value_for_period(expenses, period)
        inc_value = get_value_for_period(income, period)
        profit_loss = exp_value.to_f + inc_value.to_f
        results <<  [period_value(range, period),
                    profit_loss > 0 ? profit_loss : 0,
                    profit_loss < 0 ? profit_loss : 0]
      end
      
      results
    end
    
    def calculate_period(expenses, income, range)
      if range == "all"
        start = Time.now.year
        if !expenses[0].nil?
          start = expenses[0].period.to_i
        end
        if !income[0].nil?
          start = income[0].period.to_i unless income[0].period.to_i > start
        end
        (start..Time.now.year).to_a
      else
        (1..Time.now.month).to_a
      end
    end

    def get_value_for_period(values, period)
      values.each do |item|
        if item.period == period.to_s
          return item.sum
        end
      end
      return 0
    end
end
