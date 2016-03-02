(function($){
  $(document).on('page:change', function () {
    $('#cvd-FormBlock-moreOptions').hide();
    $('#cvd-FormBlock-moreOptions > div').addClass('hide');
    $.material.init();
    $('[data-toggle="tooltip"]').tooltip();
    new Clipboard('.btn-clipboard');

    $('#cvd-FormBlock-moreOptions-button').click( function() {
      $(this).find('.glyphicon').toggleClass('glyphicon-plus glyphicon-minus')
      $('#cvd-FormBlock-moreOptions').slideToggle();
    });
  });
})(jQuery);
