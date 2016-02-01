(function($){
  $(document).on('page:change', function () {
    $.material.init();
    new Clipboard('.btn-clipboard');
  });
})(jQuery);
