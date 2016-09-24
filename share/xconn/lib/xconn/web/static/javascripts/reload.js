var autoreload = true;

$(document).ready(function() {
  $('#logbar').scrollTop($('#logbar')[0].scrollHeight);
  
  $("#reload").click(function() {
    if (autoreload) {
      autoreload = false;
      $(this).css('color', '#666666');
    } else {
      autoreload = true;
      $(this).css('color', '#aaaaaa');
      window.location.reload(true);
    }
  });

  setTimeout(function() {
    if (autoreload) {
      window.location.reload(true);
    }
  }, 10000);
});
