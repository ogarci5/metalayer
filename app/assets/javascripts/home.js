// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.field-header').click(function() {
    var field = $(this).attr('field');
    if($(this).hasClass('active')) {
      $('.field-header').removeClass('active');
      $.ajax({
        dataType: "html",
        url: '/show',
        data: {by: field, dir: 'desc'}
      }).done(function(html) {
        $('#companies').html(html);
      });
    } else {
      $('.field-header').removeClass('active');
      $(this).addClass('active');
      $.ajax({
        dataType: "html",
        url: '/show',
        data: {by: field, dir: 'asc'}
      }).done(function(html) {
        $('#companies').html(html);
      });
    }
  });
});
