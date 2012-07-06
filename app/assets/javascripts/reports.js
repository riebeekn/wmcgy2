jQuery(function($) {
	// populate charts on page load
  if ($("[data-chart]").length > 0) {
		$.getScript("https://www.google.com/jsapi",	function(data, textStatus) {
    	google.load("visualization", "1.0", { 
				packages: ["corechart"], 
				callback: function() {
					loadChart($('#expensesChart'), $('#topChartsRange').val());
					loadChart($('#incomeChart'), $('#topChartsRange').val());
					loadChart($('#incomeExpenseChart'), $('#bottomChartsRange').val());
					loadChart($('#profitLossChart'), $('#bottomChartsRange').val());
				}
			})
		});
  }

	$('#start_date').datepicker({
		dateFormat: 'dd M yy', showAnim: 'slideDown' 
	})
	
	$('#end_date').datepicker({
		dateFormat: 'dd M yy', showAnim: 'slideDown' 
	})
	
	$('#end_date').change(function() {
		loadChart($('#expensesChart'), $('#start_date').val() + ':TO:' + $('#end_date').val())
	});

	// hide tables on page load
	$('table#expensesTable,table#incomeTable,table#incomeExpenseTable,table#profitLossTable').hide();

	// top charts date range selection event
	$('#topChartsRange').change(function() {
		loadChart($('#expensesChart'), $(this).val());
		loadChart($('#incomeChart'), $(this).val());
	});
	
	// bottom charts date range selection event
	$('#bottomChartsRange').change(function() {
		loadChart($('#incomeExpenseChart'), $(this).val());
		loadChart($('#profitLossChart'), $(this).val());
	});
	
	// show / hide top details
	$('a#toggle_top_details').click(function(event) {
		event.preventDefault();
		$('table#expensesTable,table#incomeTable').fadeToggle();
	});
	
	// show / hide bottom details
	$('a#toggle_btm_details').click(function(event) {
		event.preventDefault();
		$('table#incomeExpenseTable,table#profitLossTable').fadeToggle();
	});
});

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
	// remove existing items
	tbody.find('tr').each(function(i, val) {
		$(val).remove();
	});
	
	// add new items
	if (tableId == 'incomeExpenseTable') {
		$.each(rows, function(i, item) {
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[0]),
					$('<td>').text(item[1]).formatCurrency(),
					$('<td>').text(item[2]).formatCurrency()
				)
			)
		});
	}
	else if (tableId == 'profitLossTable') {
		$.each(rows, function(i, item) {
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[0]),
					$('<td>').text(item[1] == 0 ? item[2] : item[1]).formatCurrency()
				)
			)
		});
	}
	else {
		$.each(rows, function(i, item) {
			tbody.append(
				$('<tr>').append(
					$('<td>').text(item[0]),
					$('<td>').text(item[1]).formatCurrency()
				)
			)
		});
	}
}