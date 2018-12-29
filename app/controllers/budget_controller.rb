class BudgetController < ApplicationController

  def index
    now = DateTime.current
    eom = now.end_of_month
    year = now.strftime('%Y')
    month = now.strftime('%b')
    endDay = eom.strftime('%d')
    range = "01 #{month} #{year}:TO:#{endDay} #{month} #{year}"
    expenses = current_user.expenses_by_category_and_date_range(range)

    @categories = current_user.categories
    @categories.entries.each do |category|
      expenses.each do |expense|
        if expense.id == category.id
          category.spent = expense.sum
        end
      end
    end
  end
end
