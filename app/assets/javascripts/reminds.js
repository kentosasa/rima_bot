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
  if(gon.lat && gon.lng) {
    var gmap = new GMap('map', { lat: gon.lat, lng: gon.lng });
    gmap.init();
    gmap.setMarker({ lat: gon.lat, lng: gon.lng });
  }
  if(gon.autoComplete) {
    gmap.setAutoComplete({
      address: 'remind_place',
      place: 'remind_address',
      formatted_address: 'formatted_address',
      lat: 'remind_latitude',
      lng: 'remind_longitude'
    });
  }

  // タブの切替
  $('.tabs li').on('click', function(e) {
    e.preventDefault();
    var type = $(this).attr('data-type');
    if(type === undefined) return;

    //schedule
    $('.tabs li.is-active').removeClass('is-active');
    $(this).addClass('is-active');

    if(type === 'event') {
      console.log('event');
    } else if(type === 'schedule') {
      console.log('schedule');
    }
  });


})
