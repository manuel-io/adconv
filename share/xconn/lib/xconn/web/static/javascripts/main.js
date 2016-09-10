var autoreload = true;

$(document).ready(function() {
  $('#logbar').scrollTop($('#logbar')[0].scrollHeight);
  
  $("#autoreload").click(function() {
    if (autoreload) {
      autoreload = false;
      $(this).css('color', '#000000');
    } else {
      autoreload = true;
      $(this).css('color', '#cccccc');
      window.location.reload(true);
    }
  });

  setTimeout(function() {
    if (autoreload) {
      window.location.reload(true);
    }
  }, 10000);
});
