# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	$('#transaction_category_name').focus()
	
	$('#transaction_date').datepicker({
		dateFormat: 'dd M yy', showAnim: 'slideDown' 
	})
	if $('#transaction_date').val() is ''
		$('#transaction_date').datepicker('setDate', new Date())
		
	# load up categories in the in place editor for the new transactions page
	categories = $('#category_names')
	alert('cattyies')
	if categories.val()?
		categories = categories.val().split ":::"
		$('#transaction_category_name').autocomplete
			source: categories
			delay: 0
	