class ReportsController < ApplicationController
  
  def index
  end
  
  def expenses
    render :json => {
      type: 'PieChart',
      cols: [['string', 'Category'], ['number', 'Amount']],
      rows: current_user.expenses_by_category_and_date_range(params[:range]).
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
      rows: current_user.income_by_category_and_date_range(params[:range]).
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
      rows: Report.calculate_income_expenses(ytd_or_all, current_user),
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
      rows: Report.calculate_profit_loss(ytd_or_all, current_user),
      options: { 
        backgroundColor: { fill:'#F5F5F5'},
        title: 'Overall profit / loss', isStacked: true,
        titleTextStyle: { fontSize: 18} },
      format_cols: [1,2]
    }
  end
  
  private
  
    def ytd_or_all
      %w[year all].include?(params[:range]) ? params[:range] : "year"
    end
    
end
