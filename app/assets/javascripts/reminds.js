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
  if(gon.lat !== undefined && gon.lng != undefined) {
    var gmap = new GMap('map', { lat: gon.lat, lng: gon.lng });
    gmap.init();
    gmap.setMarker({ lat: gon.lat, lng: gon.lng });
  }
  if(gon.autoComplete === true && gmap !== undefined && gon.remindType !== undefined) {
    var type = gon.remindType.toLowerCase();
    gmap.setAutoComplete({
      address: type + '_place',
      place: type + '_address',
      formatted_address: 'formatted_address',
      lat: type + '_latitude',
      lng: type + '_longitude'
    });
  }

  var displayForm = function(type) {
    var hideName, showName;
    if(type === 'Event') {
      hideName = '[data-type="Schedule-remind"]';
      showName = '[data-type="Event-remind"]';
    } else if(type ==='Schedule') {
      showName = '[data-type="Schedule-remind"]';
      hideName = '[data-type="Event-remind"]';
    }
    $(hideName).each(function(i, elem) {
      $(elem).hide();
    })
    $(showName).each(function(i, elem) {
      $(elem).show();
    })
    $('#remind_remind_type').val(type);
  }

  if(gon.remindType !== undefined) {
    displayForm(gon.remindType);
  }



  // タブの切替
  $('.tabs li').on('click', function(e) {
    e.preventDefault();
    var type = $(this).attr('data-type');
    if(type === undefined) return;

    //schedule
    $('.tabs li.is-active').removeClass('is-active');
    $(this).addClass('is-active');

    displayForm(type);

    if(type === 'Event') {
      console.log('event');
    } else if(type === 'Schedule') {
      console.log('schedule');
    }
  });


})
