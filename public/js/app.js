$('.delete').on('click', function(event) {
  var confirmDelete = confirm('Are you sure?');
  if (confirmDelete) {
    $.ajax({
      url: '/book/{{book.id}}',
      method: 'DELETE',
      data: {id: '{{book.id}}'}
    }).done(function(data) {
      window.location = '/'
    }).fail(function(jqXHR, textStatus, errorThrown) {
      alert('Could not delete, check logs');
      console.log(jqXHR);
      console.log(textStatus);
    });
  }
});

$('a').on('click', function(event) {
  $el = $(event.target);
  $('.details.hidden').hide();
  $el.parents('li').find('.details.hidden').show();
});
