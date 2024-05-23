//= require jquery
$(document).ready(function() {
    setupPricingTabs();
    faq_accordian();
});

$(document).on('turbolinks:load', function() {
  setupPricingTabs();
  faq_accordian();
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

var swapTextContent = function() {
    $('.business-profile-free-text').toggle();
    $('.business-profile-free-text-container').toggle();
    if ($('.business-profile__more-link').text() == "more") {
        $('.business-profile__more-link').text("(less)")
    } else {
        $('.business-profile__more-link').text("more")
    }
}

var faq_accordian = function () {
  
    var acc = document.getElementsByClassName("accordion-item");
    var i;

    for (i = 0; i < acc.length; i++) {
        acc[i].addEventListener("click", function () {
            this.classList.toggle("active");
        });
    }

    var height = document.getElementsByClassName("accordion-content").offsetHeight;
    console.log(height);
}

document.addEventListener("click", (event) => { 
  if (!event.target.matches('.toggle_side_menu')) return;
  var side_bar = document.getElementById('side-menu');
  side_bar.classList.toggle('side-menu--hidden');
  side_bar.classList.toggle('side-menu');
  document.getElementById('hamburger_menu').classList.toggle('is-active');
  document.body.style.overflow = side_bar.classList.contains('side-menu--hidden') ? 'visible' : 'hidden'
});