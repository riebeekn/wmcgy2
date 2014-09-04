jQuery(function($) {
	// populate charts on page load
  if ($("[data-chart]").length > 0) {
		$.getScript("https://www.google.com/jsapi",	function(data, textStatus) {
    	google.load("visualization", "1.0", { 
				packages: ["corechart"], 
				callback: function() {
					loadChart($('#expensesChart'), getExpenseIncomeChartDateRange()); 
					loadChart($('#incomeChart'), getExpenseIncomeChartDateRange()); 
					loadChart($('#incomeExpenseChart'), $('#overallIncomeExpenseProfitLossChartsRange').val());
					loadChart($('#profitLossChart'), $('#overallIncomeExpenseProfitLossChartsRange').val());
					loadChart($('#expenseTrendChart'), $('#expenseTrendChartRange').val());
					loadChart($('#incomeTrendChart'), $('#incomeTrendChartRange').val());
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
		loadChart($('#incomeChart'), getExpenseIncomeChartDateRange());
		loadChart($('#expensesChart'), getExpenseIncomeChartDateRange());
	});
	
	// set up the end date picker (defaults to current day)
	$('#end_date').datepicker({
		dateFormat: 'dd M yy', showAnim: 'slideDown' 
	})
	if ($('#end_date').val() == '') {
		$('#end_date').datepicker('setDate', new Date());
	}
	$('#end_date').change(function() {
		loadChart($('#incomeChart'), getExpenseIncomeChartDateRange());
		loadChart($('#expensesChart'), getExpenseIncomeChartDateRange());
	});

	// hide tables on page load
	// $('table#expensesTable,table#incomeTable,table#incomeExpenseTable,' + 
	// 	'table#profitLossTable,table#expenseTrendTable,table#incomeTrendTable').hide();

	// overallIncomeExpenseProfitLossChartsRange charts date range selection event
	$('#overallIncomeExpenseProfitLossChartsRange').change(function() {
		loadChart($('#incomeExpenseChart'), $(this).val());
		loadChart($('#profitLossChart'), $(this).val());
	});

	// trend charts date range selection event
	$('#expenseTrendChartRange').change(function() {
		loadChart($('#expenseTrendChart'), $(this).val());
	});

	$('#incomeTrendChartRange').change(function() {
		loadChart($('#incomeTrendChart'), $(this).val());
	});
	
	// show / hide expense income details
	$('a#toggle_expense_income_details').click(function(event) {
		event.preventDefault();
		$('table#expensesTable,table#incomeTable').fadeToggle();
	});
	
	// show / hide income / expense; profit / loss details
	$('a#toggle_overall_p_l_i_e_details').click(function(event) {
		event.preventDefault();
		$('table#incomeExpenseTable,table#profitLossTable').fadeToggle();
	});

	// show / hide expense trend details
	$('a#toggle_expense_trend_details').click(function(event) {
		event.preventDefault();
		$('table#expenseTrendTable').fadeToggle();
	});

		// show / hide income trend details
	$('a#toggle_income_trend_details').click(function(event) {
		event.preventDefault();
		$('table#incomeTrendTable').fadeToggle();
	});
});

function getExpenseIncomeChartDateRange() {
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
		else if(url.indexOf('reports/expense_trend?') >= 0) {
			populateTable('expenseTrendTable', data.rows, data.cols);
		}
		
    return chart.draw(div.get(0));
	});
}

function populateTable(tableId, rows, cols) {
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
	if (tableId === 'incomeExpenseTable') {
		populateIncomeExpenseTable(rows, tbody, tfoot);
	}
	else if (tableId === 'profitLossTable') {
		populateProfitLossTable(rows, tbody, tfoot);
	}
	else if (tableId === 'expenseTrendTable') {
		thead = $('table#' + tableId + ' thead tr');
		populateExpenseTrendTable(cols, rows, thead, tbody, tfoot, tableId);
	}
	else {
		populateSimpleIncomeExpenseTable(rows, tbody, tfoot);
	}
}

function populateExpenseTrendTable(cols, rows, thead, tbody, tfoot, tableId) {
	// set up the header (the period values)
	$.each(rows, function(i, item) {
		thead.append($('<th>').text(item[0]))
	});
	thead.append($("<th class='summary-column'>").text('Avg'));
	
	// set up the first column (the categories)
	$.each(cols, function(i, item) {
		if (i !== 0) {
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[1])
				)
			)
		}
	});

	// add summary header
	tfoot.append(
		$('<tr>').append(
			$('<td>').text('Total')
		)
	)

	// add the row data
	lastTableRow = $('table#' + tableId + ' tr:last');
	$.each(rows, function(i, item) {
		var monthTotal = 0;
		$.each(item, function(i2, item2) {
			if (i2 !== 0) {
				var tr = $('table#' + tableId + ' tr:eq(' + i2 + ')');
				tr.append($('<td>').text(item2).formatCurrency())
				monthTotal +=  item2;
			}
		});
		lastTableRow.append($('<td>').text(monthTotal).formatCurrency())
	});

	// add the Avg column data
	$('table#' + tableId + ' tr').each(function(i){
		if (i !== 0) {
			var total = 0.0;
			var colCount = 0;
			$.each(this.cells, function(i2){
				if (i2 !== 0) {
					total += parseFloat(this.innerHTML.replace('$', '').replace(',', ''));
					colCount++;
				}
			});
			var tr = $('table#' + tableId + ' tr:eq(' + i + ')');
			tr.append($("<td class='summary-column'>").text(total/colCount).formatCurrency())
		}
	});
}

function populateIncomeExpenseTable(rows, tbody, tfoot) {
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

function populateProfitLossTable(rows, tbody, tfoot) {
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

function populateSimpleIncomeExpenseTable(rows, tbody, tfoot) {
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