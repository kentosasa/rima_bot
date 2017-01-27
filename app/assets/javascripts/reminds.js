$(document).ready(function() {
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

  $('#candidate-datepicker').datetimepicker({
    timepicker: false,
    inline: true,
    lang: 'ja',
    minDate: 0,
    startDate: new Date(),
    onSelectDate: function(current, _) {
      var date = new Date(current)
      var month = date.getMonth() + 1
      var day = date.getDate()
      var dates = ["日","月","火","水","木","金","土"];
      var week = dates[date.getDay()]
      var elem = '#' + gon.remindType.toLowerCase() + '_candidate_body';
      var text  = $(elem).val();
      if(text.length !== 0) text += '\n'
      text += month + '/' + day + '(' + week + ') 19:00 ~'
      $(elem).val(text)
    }
  })

  // GMap 生成
  if(gon.lat !== undefined && gon.lng != undefined) {
    var gmap = new GMap('map', { lat: gon.lat, lng: gon.lng });
    gmap.init();
    gmap.setMarker({ lat: gon.lat, lng: gon.lng });
  }

  if(gon.autoComplete === true && gmap !== undefined && gon.remindType !== undefined) {
    var type = gon.remindType.toLowerCase();
    if(gon.create === true) {
      type = 'remind';
    }
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
    var elem = '#' + gon.remindType.toLowerCase() + '_remind_type';
    $(elem).val(type);
  }

  if(gon.remindType !== undefined) {
    displayForm(gon.remindType);
    if(gon.remindType == 'Schedule') {
      $('.tabs .event-remind').removeClass('is-active');
      $('.tabs .schedule-remind').addClass('is-active');
    }
  }


  // フォームのトグルボタン
  $('#toggle-button').on('click', function(e) {
    e.preventDefault();
    $('#toggle-body').toggleClass('is-open');
    $(this).find('span').toggleClass('is-open');
    google.maps.event.trigger(map, 'resize')
  })

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
      $('#toggle-body').removeClass('is-open')
      console.log('event');
    } else if(type === 'Schedule') {
      console.log('schedule');
    }
  });
})
