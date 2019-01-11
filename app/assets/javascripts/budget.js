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
    updateBudgetStatus();
  });
}

function updateBudgetStatus() {
  if ($('#plus-minus-total').asNumber() < 0) {
    $('section.budget-status header').html('OVER BUDGET')
    $('section.budget-status header').addClass('debit');
    $('section.budget-status header').removeClass('credit');
  } else {
    $('section.budget-status header').html('ON BUDGET');
    $('section.budget-status header').addClass('credit');
    $('section.budget-status header').removeClass('debit');
  }
}

function setPlusMinus() {
  $('tr').each(function () {
    var budgeted = $(this).find('.best_in_place').asNumber();
    var spent = $(this).find('.spent-item').asNumber();
    if (budgeted !== null && spent !== null) {
      var plusMinus = budgeted - spent;
      var $field = $(this).find('.plus-minus');
      if (plusMinus < 0) {
        $field.addClass('debit').removeClass('warning');
      } else if (spent >= budgeted * 0.8) {
        $field.addClass('warning').removeClass('debit');
      } else {
        $field.removeClass('debit').removeClass('warning');
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

  var budgetedTotal = $('#budget-total').asNumber();
  var spentTotal = $('#spent-total').asNumber();
  console.log(budgetedTotal);
  console.log(spentTotal);

  if (sum < 0) {
    $('#plus-minus-total').addClass('debit').removeClass('warning');
  } else if (spentTotal >= budgetedTotal * 0.8) {
    $('#plus-minus-total').addClass('warning').removeClass('debit');
  } else {
    $('#plus-minus-total').removeClass('debit');
  }
  $('#plus-minus-total').html(sum).formatCurrency();
}
