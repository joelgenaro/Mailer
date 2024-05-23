// These extensions were ported over from when we moved from
// using asset pipeline to webpacker
$(function() {

  /**
   * A helpful function for quickly displaying the amount of
   * task time a user has remaining.
   *
   * @param  {Number} userId
   * @return {void}
   */
  function fetchUserTimeRemaining(userId) {
    var url = window.adminTimeRemainingPath.replace(':id', userId);

    $.ajax({
      type: "GET",
      url: url
    }).done(function(data) {
      var innerHtml = '<div class="admin-user-info__note-wrap"> \
        <div class="admin-user-info__note"> \
          <p>Time remaining for this user:</p> \
          <span class="status_tag">'+ data.time_remaining +'</span> \
        </div> \
      </div>';
      var html = '<div class="admin-user-info__placeholder">'+ innerHtml +'</div>';

      $('.admin-user-info__placeholder').html(html);
    });
  }

  // Binding when the user is changed, and on page load.
  if (window.adminTimeRemainingPath) {
    $('#assistant_task_user_id').on('change', function(e) {
      var userId = e.target.value;
      fetchUserTimeRemaining(userId);
    });
    $(document).ready(function() {
      var userId = $('#assistant_task_user_id').val();
      if (userId) {
        fetchUserTimeRemaining(userId);
      }
    });
  }

  /**
   * Starts the ticker timer
   *
   * @param {elementId} string
   * @param {counterInputId} string
   * @return {void}
   */
  function startTimer(elementId, counterInputId) {
    var totalSeconds = 0;

    // Start the ticker timer and bind it to a window variable for convenience
    window.tickerTimer = setInterval(function () {
      ++totalSeconds;

      // Time calculations for days, hours, minutes and seconds
      var days = Math.floor(totalSeconds / (60 * 60 * 24));
      var hours = Math.floor((totalSeconds % (60 * 60 * 24)) / (60 * 60));
      var minutes = Math.floor((totalSeconds % (60 * 60)) / 60);
      var seconds = Math.floor((totalSeconds % 60));

      // Display the nicely formatted time
      document.getElementById(elementId).innerHTML = days + "d " + hours + "h "
        + minutes + "m " + seconds + "s ";

      // Update our hidden minutes counter input
      document.getElementById(counterInputId).value = Math.ceil(totalSeconds / 60);
    }, 1000);
  }

  /**
   * Stops the ticker timer and updates the "Minutes" field
   *
   * @param {string} elementId
   * @param {string} counterInputId
   * @param {string} minutesInputId
   * @return {void}
   */
  function stopTimer(elementId, counterInputId, minutesInputId) {
    document.getElementById(minutesInputId).value = document.getElementById(counterInputId).value;
    document.getElementById(elementId).innerHTML = "0m 0s";
    clearInterval(window.tickerTimer);
  }

  // Binding to start the timer
  $('.ticker-timer__button--start').on('click', function(e) {
    e.preventDefault();

    var elementId = 'ticker-timer__time';
    var counterInputId = 'ticker-timer__count-input';

    // Trigger a "click" on the "Add New Time Entry" button, if it exists
    if ($('#'+ counterInputId).attr('data-add-new') == '1') {
      $('.has_many_add').click();
    }

    // Start the timer and show the "Stop Timer" button
    startTimer(elementId, counterInputId);
    $('.ticker-timer__button--start').hide();
    $('.ticker-timer__button--stop').show();
  });

  // Binding to stop the timer
  $('.ticker-timer__button--stop').on('click', function(e) {
    e.preventDefault();

    var elementId = 'ticker-timer__time';
    var counterInputId = 'ticker-timer__count-input';

    if ($('#'+ counterInputId).attr('data-add-new') == '1') {
      var minutesInputId = $('.time_entries .has_many_fields').last().find('input[type="number"]').attr('id');
    } else {
      var minutesInputId = $('#'+ counterInputId).attr('data-input-id');
    }

    // Stop the timer and show the "Start Timer" button
    stopTimer(elementId, counterInputId, minutesInputId);
    $('.ticker-timer__button--stop').hide();
    $('.ticker-timer__button--start').show();
  });
});