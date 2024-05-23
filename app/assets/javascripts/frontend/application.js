//= require jquery
//= require bootstrap-sprockets
//= require clipboard
//= require lightbox

$(document).ready(function() {
  setupPricingTabs();
});

$(document).on('turbolinks:load', function() {
  setupPricingTabs();

  // This method is posting request to controller method if the select option is changed
    $('.settings__select_tag').on('change', function () {
        selectedDate = $(this).children("option:selected").val();
        monthsArray = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
        monthNumber = monthsArray.indexOf(selectedDate.split(" ")[0].toLowerCase()) + 1
        window.location.replace('/app/settings/invoices/'+ selectedDate.split(" ")[1] + "/" + monthNumber);
    });
})

var setupPricingTabs = function() {
  $('.pricing-plans__tab').each(function() {
    $(this).click(function() {
      var pricingTable = $(this).attr('data-table');
      var $pricingTable = $(pricingTable);

      $('.pricing-plans__tab').removeClass('pricing-plans__tab--active');
      $(this).addClass('pricing-plans__tab--active');

      $('.pricing-plans__table').removeClass('d-block').addClass('d-none');
      $pricingTable.removeClass('d-none').addClass('d-block');
    });
  });
};

$(document).on('turbo:load', function(){  
  
  var clipboard = new Clipboard('.clipboard-btn');
	
});
