// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.field-header').click(function() {

    $('.field-header').removeClass('active');
    if($(this).hasClass('asc')) {
      $(this).removeClass('asc').addClass('desc').addClass('active');
    } else {
      $(this).removeClass('desc').addClass('asc').addClass('active');
    }

    update_companies();
  });

  $('#page_size').change(function() {
    update_companies();
  });

});

// update the companies
function update_companies() {
  var field_tag = $('.field-header.active'),
      field = field_tag.attr('field'),
      dir = field_tag.hasClass('asc') ? 'asc' : 'desc',
      page_size = $('#page_size').val(),
      data = {by: field, dir: dir, page_size: page_size};

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