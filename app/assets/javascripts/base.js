(function($){
  $(document).on('page:change', function () {
    $('.hide-js').hide();
    $('.show-js').removeClass('hide');
    $('#cvd-FormBlock-moreOptions').hide();
    $('#cvd-FormBlock-moreOptions > div').addClass('hide');
    $.material.init();
    $('[data-toggle="tooltip"]').tooltip();
    new Clipboard('.btn-clipboard');

    $('#cvd-FormBlock-moreOptions-button').click( function() {
      $(this).find('.glyphicon').toggleClass('glyphicon-plus glyphicon-minus')
      $('#cvd-FormBlock-moreOptions').slideToggle();
    });

    $('[name="token"]').click( function() {
      $(this).select();
      try {
        document.execCommand('copy');
        $('.cvd-TokenCopied').text('Token copié dans le presse papier');
        setTimeout("$('.cvd-TokenCopied').text('')", 4000);
      } catch (err) {
        console.log('Oops, unable to copy token');
      }
    });
  });
})(jQuery);
