// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.field-header').click(function() {
    var field = $(this).attr('field');
    $('.field-header').removeClass('active');
    if($(this).hasClass('asc')) {
      $(this).removeClass('asc');
      $(this).addClass('desc');
      $(this).addClass('active');
      $.ajax({
        dataType: "html",
        url: '/show',
        data: {by: field, dir: 'desc'}
      }).done(function(html) {
        $('#companies').html(html);
      });
    } else {
      $(this).removeClass('desc');
      $(this).addClass('asc');
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
