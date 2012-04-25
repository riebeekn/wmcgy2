jQuery(function($) {
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

	$('#topChartsRange').change(function() {
		loadChart($('#expensesChart'), $(this).val());
		loadChart($('#incomeChart'), $(this).val());
	});
	$('#bottomChartsRange').change(function() {
		loadChart($('#incomeExpenseChart'), $(this).val());
		loadChart($('#profitLossChart'), $(this).val());
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
    return chart.draw(div.get(0));	
	});
}
