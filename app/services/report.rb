class Report

  def self.period_value(range, period)
    if range == 'year'
      Date::MONTHNAMES[period.to_i][0..2]
    else
      period.to_s
    end
  end

  # values is an array of key value pairs 
  # (ie. for "all"... 2010 52274.76 2010 -123812,  for "mtd"... 1 -800, 1 1500)
  # so this method just returns the value part of the item when the key matches the period passed in
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
      if !expenses[0].nil?
        start = expenses[0].period.to_i
      end
      if !income[0].nil?
        start = income[0].period.to_i unless income[0].period.to_i > start
      end
      (start..period_end.year).to_a
    else
      (1..period_end.month).to_a
    end
  end

  def self.calculate_profit_loss(range, user, period_end = Time.now)
    if range == "all"
      expenses = user.expenses_by_year
      income = user.income_by_year
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
end