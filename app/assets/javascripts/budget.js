jQuery(function($) {
  bindBudgetValueUpdateSuccessEvent();
  setPlusMinus();
  setBudgetedTotal();
  setSpentTotal();
  setPlusMinusTotal();
});

function bindBudgetValueUpdateSuccessEvent() {
  $('.best_in_place').bind("ajax:success", function (){
    $(this).formatCurrency();
    setPlusMinus();
    setBudgetedTotal();
    setPlusMinusTotal();
  });
}

function setPlusMinus() {
  $('tr').each(function () {
    var budgeted = $(this).find('.best_in_place').asNumber();
    var spent = $(this).find('.spent-item').asNumber();
    if (budgeted !== null && spent !== null) {
      var plusMinus = budgeted - spent;
      var $field = $(this).find('.plus-minus');
      if (plusMinus < 0) {
        $field.addClass('debit');
      } else {
        $field.removeClass('debit');
      }
      $field.html(plusMinus).formatCurrency();
    }
  });
}

function setBudgetedTotal() {
  var sum = 0;
  $('.best_in_place').each(function() {
    sum += $(this).asNumber();
  });

  $('#budget-total').html(sum).formatCurrency();
}

function setSpentTotal() {
  var sum = 0;
  $('.spent-item').each(function() {
    sum += $(this).asNumber();
  });

  $('#spent-total').html(sum).formatCurrency();
}

function setPlusMinusTotal() {
  var sum = 0;
  $('.plus-minus').each(function() {
    sum += $(this).asNumber();
  });

  if (sum < 0) {
    $('#plus-minus-total').addClass('debit');
  } else {
    $('#plus-minus-total').removeClass('debit');
  }
  $('#plus-minus-total').html(sum).formatCurrency();
}
