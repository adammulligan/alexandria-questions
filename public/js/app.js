var initialiseDeleteButton = function(bookId) {
  $('.delete').on('click', function(event) {
    var confirmDelete = confirm('Are you sure?');
    if (confirmDelete) {
      $.ajax({
        url: '/books/'+bookId,
        method: 'DELETE',
        data: {id: bookId}
      }).done(function(data) {
        window.location = '/';
      }).fail(function(jqXHR, textStatus, errorThrown) {
        alert('Could not delete, check logs');
        console.log(jqXHR);
        console.log(textStatus);
      });
    }
  });
};

$('a').on('click', function(event) {
  $el = $(event.target);
  $('.details.hidden').hide();
  $el.parents('li').find('.details.hidden').show();
});

$('.new_category').on('keypress', function(event) {
  if (event.which === 13) {
    event.preventDefault();

    $el = $(event.target);

    $select = $el.parents('fieldset').find('select');
    $select.append('<option selected>'+$el.val()+'</option');

    $el.val('');
  }
});
