class Report

  def self.period_value(range, period)
    if range == 'year' || range == '12'
      Date::MONTHNAMES[period.to_i][0..2]
    else
      period.to_s
    end
  end

  def self.get_value_for_period(values, period)
    values.each do |item|
      if item.period == period.to_s
        return item.sum
      end
    end
    return 0
  end

  def self.calculate_period(expenses, income, range, period_end = Time.now)
    if range == "all"
      start = Time.now.year
      if !expenses.nil? && !expenses[0].nil?
        start = expenses[0].period.to_i
      end
      if !income.nil? && !income[0].nil?
        start = income[0].period.to_i unless income[0].period.to_i > start
      end
      (start..period_end.year).to_a
    elsif range == "12"
      start_month = (period_end - 11.months).month
      periods = []
      12.times do
        if start_month <= 12
          periods << start_month
        else
          start_month = 1
          periods << start_month
        end
        start_month += 1
      end
      periods
    else
      (1..period_end.month).to_a
    end
  end

  def self.calculate_profit_loss(range, user, period_end = Time.now)
    if range == "all"
      expenses = user.expenses_by_year
      income = user.income_by_year
    elsif range == "12"
      expenses = user.expenses_for_last_12_months
      income = user.income_for_last_12_months
    else
      expenses = user.expenses_by_month_for_current_year(period_end.year)
      income = user.income_by_month_for_current_year(period_end.year)
    end
    
    periods = Report.calculate_period(expenses, income, range, period_end)
    results = []
    periods.each do |period|
      exp_value = Report.get_value_for_period(expenses, period)
      inc_value = Report.get_value_for_period(income, period)
      profit_loss = exp_value.to_f + inc_value.to_f
      results <<  [Report.period_value(range, period),
                  profit_loss > 0 ? profit_loss : 0,
                  profit_loss < 0 ? profit_loss : 0]
    end
    
    results
  end

  def self.calculate_income_expenses(range, user, period_end = Time.now)
    if range == "all"
      expenses = user.expenses_by_year
      income = user.income_by_year
    elsif range == "12"
      expenses = user.expenses_for_last_12_months
      income = user.income_for_last_12_months
    else
      expenses = user.expenses_by_month_for_current_year(period_end.year)
      income = user.income_by_month_for_current_year(period_end.year)
    end
    
    periods = Report.calculate_period(expenses, income, range, period_end)
    results = []
    periods.each do |period|
      exp_value = Report.get_value_for_period(expenses, period)
      inc_value = Report.get_value_for_period(income, period)
      results << [Report.period_value(range, period),
                          inc_value.to_f,
                          exp_value.to_f.abs]
    end
    
    results
  end

  def self.expense_categories(user)
    cats = [['string', 'Month']]
    user.expense_categories.each do |category| 
      cats.push(['number', category])
    end

    # hack as for some reason line graph will barf with only a single series
    # need to investigate this further... for now just inserting a 'dumby'
    # value so at least the chart shows up
    if cats.count == 2
      cats.push(['number', 'nil'])
    end

    cats
  end

  def self.income_categories(user)
    cats = [['string', 'Month']]
    user.income_categories.each do |category| 
      cats.push(['number', category])
    end

    # hack as for some reason line graph will barf with only a single series
    # need to investigate this further... for now just inserting a 'dumby'
    # value so at least the chart shows up
    if cats.count == 2
      cats.push(['number', 'nil'])
    end

    cats
  end

  def self.calculate_expense_trend(range, user, period_end = Time.now)
    if range == "all"
      expenses = user.expenses_by_category_and_year
    elsif range == "12"
      expenses = user.expenses_by_category_for_last_12_months
    else
      expenses = user.expenses_by_category_and_month_for_current_year(period_end.year)
    end

    results = []
    periods = Report.calculate_period(expenses, nil, range, period_end)
    
    # hack as for some reason line graph will barf with only a single series
    # need to investigate this further... for now just inserting a 'dumby'
    # value so at least the chart shows up
    add = user.expense_categories.count == 1
    periods.each do |period|
      result = []
      result << Report.period_value(range, period)
      user.expense_categories.each do |category|
        found = false
        expenses.each do |item|
          if item.period == period.to_s && item.name == category
            result << item.sum.to_f.abs
            found = true
            break
          end
        end
        if (!found)
          result << 0
        end
      end
      if (add)
        result << 0
      end
      results << result
    end
    
    results
  end

  def self.calculate_income_trend(range, user, period_end = Time.now)
    if range == "all"
      income = user.income_by_category_and_year
    elsif range == "12"
      income = user.income_by_category_for_last_12_months
    else
      income = user.income_by_category_and_month_for_current_year(period_end.year)
    end

    results = []
    periods = Report.calculate_period(income, nil, range, period_end)
    
    # hack as for some reason line graph will barf with only a single series
    # need to investigate this further... for now just inserting a 'dumby'
    # value so at least the chart shows up
    add = user.income_categories.count == 1
    periods.each do |period|
      result = []
      result << Report.period_value(range, period)
      user.income_categories.each do |category|
        found = false
        income.each do |item|
          if item.period == period.to_s && item.name == category
            result << item.sum.to_f.abs
            found = true
            break
          end
        end
        if (!found)
          result << 0
        end
      end
      if (add)
        result << 0
      end
      results << result
    end
    
    results
  end

  def self.period_drop_down_options(user)
    distinct_years_for_users_transactions = 
        user.transactions.
          select("distinct(extract(year from date)) as period").
          where("date_trunc('year', date) != date_trunc('year', current_date)").
          order("period DESC").map { |i| i.period }

    charts_period_options = {'year to date' => 'year', 'last 12 months' => '12', 'all' => 'all'}
    
    distinct_years_for_users_transactions.each do |year|
      charts_period_options[year] = year 
    end

    charts_period_options
  end
end