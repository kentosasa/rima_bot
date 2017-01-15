$(document).on('turbolinks:load', function() {
  $('.date-input').datetimepicker({
    timepicker: false,
    closeOnDateSelect: true,
    format: 'Y/m/d'
  })

  $('.time-input').datetimepicker({
    datepicker: false,
    step: 30,
    format: 'H:i'
  })

  // GMap 生成
  var gmap = new GMap('map', { lat: gon.lat, lng: gon.lng });
  gmap.init();
  gmap.setMarker({ lat: gon.lat, lng: gon.lng });
  gmap.setAutoComplete({
    address: 'remind_place',
    place: 'remind_address',
    formatted_address: 'formatted_address',
    lat: 'remind_latitude',
    lng: 'remind_longitude'
  });


  // タブ切り替え
  $('.md-view-tab li').on('click', function (e) {
    e.preventDefault();
    var $div = $('.body_container');
    var type = $(this).attr('data-type');
    if (type === undefined) return;
    $div.find('.md-view-tab .is-active').removeClass('is-active');
    $('.md-view-tab .is-active').removeClass('is-active');
    $(this).addClass('is-active');

    if (type == 'text') {
      $div.find('textarea').show();
      $div.find('.md-view').hide();
    } else if (type == 'view') {
      $div.find('textarea').hide();
      $div.find('.md-view').show();
      var text = $div.find('textarea').val();
      $.ajax({
        url: '/api/md_view',
        type: 'post',
        dataType: 'json',
        data: 'text=' + text
      }).done(function (data) {
        console.log(data);
      }).error(function (error) {
        console.log(error.responseText);
        var view = error.responseText;
        $div.find('.md-view').html(view);
      });
    }
  });

})
