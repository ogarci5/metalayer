// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.field-header').click(function() {

    $('.field-header').removeClass('active');
    $('.field-header').not(this).removeClass('asc desc');
    if($(this).hasClass('asc')) {
      $(this).removeClass('asc').addClass('desc').addClass('active');
      $(this).find('span').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
    } else {
      $(this).removeClass('desc').addClass('asc').addClass('active');
      $(this).find('span').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
    }

    update_companies();
  });

  $('#page_size').change(function() {
    update_companies();
  });

  $('.pagination li').not('.disabled').click(function() {
    $('.pagination li').removeClass('active');
    $(this).addClass('active');

    update_companies();
  });
});

// update the companies
function update_companies() {
  var field_tag = $('.field-header.active'),
      field = field_tag.attr('field'),
      dir = field_tag.hasClass('asc') ? 'asc' : 'desc',
      page_size = parseInt($('#page_size').val()),
      page_start = (parseInt($('.pagination li.active').text()) - 1) * page_size;
      data = {by: field, dir: dir, page_size: page_size, page_start: page_start};

  $('#company-mask').show();
  $.ajax({
    dataType: "html",
    url: '/show',
    data: data
  }).done(function(html) {
    $('#company-mask').hide();
    $('#companies').html(html);
  });
}