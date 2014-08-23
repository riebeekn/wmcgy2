jQuery(function($) {
	// populate charts on page load
  if ($("[data-chart]").length > 0) {
		$.getScript("https://www.google.com/jsapi",	function(data, textStatus) {
    	google.load("visualization", "1.0", { 
				packages: ["corechart"], 
				callback: function() {
					loadChart($('#expensesChart'), getTopChartDateRange()); 
					loadChart($('#incomeChart'), getTopChartDateRange()); 
					loadChart($('#incomeExpenseChart'), $('#middleChartsRange').val());
					loadChart($('#profitLossChart'), $('#middleChartsRange').val());
					loadChart($('#expenseTrendChart'), $('#bottomChartsRange').val());
					loadChart($('#incomeTrendChart'), $('#bottomChartsRange').val());
				}
			})
		});
  }

	// set up the start date picker (defaults to first of current month)
	$('#start_date').datepicker({
		dateFormat: 'dd M yy', showAnim: 'slideDown' 
	})
	if ($('#start_date').val() == '') {
		var firstOfMonth = new Date();
		firstOfMonth.setDate(1);
		$('#start_date').datepicker('setDate', firstOfMonth);
	}
	$('#start_date').change(function() {
		loadChart($('#incomeChart'), getTopChartDateRange());
		loadChart($('#expensesChart'), getTopChartDateRange());
	});
	
	// set up the end date picker (defaults to current day)
	$('#end_date').datepicker({
		dateFormat: 'dd M yy', showAnim: 'slideDown' 
	})
	if ($('#end_date').val() == '') {
		$('#end_date').datepicker('setDate', new Date());
	}
	$('#end_date').change(function() {
		loadChart($('#incomeChart'), getTopChartDateRange());
		loadChart($('#expensesChart'), getTopChartDateRange());
	});

	// hide tables on page load
	$('table#expensesTable,table#incomeTable,table#incomeExpenseTable,table#profitLossTable').hide();

	// middle charts date range selection event
	$('#middleChartsRange').change(function() {
		loadChart($('#incomeExpenseChart'), $(this).val());
		loadChart($('#profitLossChart'), $(this).val());
	});

	// bottom charts date range selection event
	$('#bottomChartsRange').change(function() {
		loadChart($('#expenseTrendChart'), $(this).val());
		loadChart($('#incomeTrendChart'), $(this).val());
	});
	
	// show / hide top details
	$('a#toggle_top_details').click(function(event) {
		event.preventDefault();
		$('table#expensesTable,table#incomeTable').fadeToggle();
	});
	
	// show / hide middle details
	$('a#toggle_middle_details').click(function(event) {
		event.preventDefault();
		$('table#incomeExpenseTable,table#profitLossTable').fadeToggle();
	});
});

function getTopChartDateRange() {
	return $('#start_date').val() + ':TO:' + $('#end_date').val();
}

function loadChart(div, range) {
	var url = div.data("chart") + "?range=" + range
  return $.getJSON(url, function(data) {
    var chart, formatter, table;
    table = new google.visualization.DataTable();
    $.each(data.cols, function() {
      return table.addColumn.apply(table, this);
    });
    table.addRows(data.rows);
    chart = new google.visualization.ChartWrapper();
    chart.setChartType(data.type);
    chart.setDataTable(table);
    chart.setOptions(data.options);
    chart.setOption("width", div.width());
    chart.setOption("height", div.height());
    formatter = new google.visualization.NumberFormat({
      prefix: "$",
      negativeParens: true
    });
    $.each(data.format_cols, function() {
      return formatter.format(table, parseInt(this));
    });
		
		// populate data tables
		if (url.indexOf('reports/expenses?') >= 0) {
			populateTable('expensesTable', data.rows);
		}
		else if (url.indexOf('reports/income?') >= 0) {
			populateTable('incomeTable', data.rows);
		}
		else if(url.indexOf('reports/income_and_expense?') >= 0) {
			populateTable('incomeExpenseTable', data.rows);
		}
		else if(url.indexOf('reports/profit_loss?') >= 0) {
			populateTable('profitLossTable', data.rows);
		}
		
    return chart.draw(div.get(0));
	});
}

function populateTable(tableId, rows) {
	tbody = $('table#' + tableId + ' tbody');
	tfoot = $('table#' + tableId + ' tfoot'); 

	// remove existing items
	tbody.find('tr').each(function(i, val) {
		$(val).remove();
	});
	tfoot.find('tr').each(function(i, val) {
		$(val).remove();
	});
	
	// add new items
	if (tableId == 'incomeExpenseTable') {
		income_total = 0;
		expense_total = 0;
		$.each(rows, function(i, item) {
			income_total += item[1];
			expense_total += item[2];
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[0]),
					$('<td>').text(item[1]).formatCurrency(),
					$('<td>').text(item[2]).formatCurrency()
				)
			)
		});
		tfoot.append(
			$('<tr>').append(
				$('<td>').text('Total'),
				$('<td>').text(income_total).formatCurrency(),
				$('<td>').text(expense_total).formatCurrency()
			)
		)
	}
	else if (tableId == 'profitLossTable') {
		total = 0;
		$.each(rows, function(i, item) {
			total += item[1] == 0 ? item[2] : item[1]
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[0]),
					$('<td>').text(item[1] == 0 ? item[2] : item[1]).formatCurrency()
				)
			)
		});
		tfoot.append(
			$('<tr>').append(
				$('<td>').text('Total'),
				$('<td>').text(total).formatCurrency()
			)
		)
	}
	else {
		total = 0;
		$.each(rows, function(i, item) {
			total += item[1];
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[0]),
					$('<td>').text(item[1]).formatCurrency()
				)
			)
		});
		tfoot.append(
			$('<tr>').append(
				$('<td>').text('Total'),
				$('<td>').text(total).formatCurrency()
			)
		)
	}
}