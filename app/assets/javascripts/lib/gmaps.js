"use strict";

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var GMap = function () {
  function GMap(mapid, latlng) {
    var opts = arguments.length <= 2 || arguments[2] === undefined ? { zoom: 16 } : arguments[2];

    _classCallCheck(this, GMap);

    this.mapid = mapid;
    this.latlng = latlng;
    this.opts = opts;
    this.pins = [];
    this.pin = {}; // this.pinはmarkerとそれに対応するinfoWindowを持つ
  }

  _createClass(GMap, [{
    key: "init",
    value: function init() {
      this.map = new google.maps.Map(document.getElementById(this.mapid), {
        center: new google.maps.LatLng(this.latlng),
        zoom: this.opts.zoom,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false,
        scrollwheel: false
      });
      var style = [{ "featureType": "road.highway", "elementType": "labels", "stylers": [{ "hue": "#ffffff" }, { "saturation": -100 }, { "lightness": 100 }, { "visibility": "off" }] }, { "featureType": "landscape.natural", "elementType": "all", "stylers": [{ "hue": "#ffffff" }, { "saturation": -100 }, { "lightness": 100 }, { "visibility": "on" }] }, { "featureType": "road", "elementType": "all", "stylers": [{ "hue": "#ffe94f" }, { "saturation": 100 }, { "lightness": 4 }, { "visibility": "on" }] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "hue": "#ffe94f" }, { "saturation": 100 }, { "lightness": 4 }, { "visibility": "on" }] }, { "featureType": "water", "elementType": "geometry", "stylers": [{ "hue": "#333333" }, { "saturation": -100 }, { "lightness": -74 }, { "visibility": "off" }] }];
      this.map.setOptions({ styles: style });
    }

    // 住所のオートコンプリートをONにする

  }, {
    key: "setAutoComplete",
    value: function setAutoComplete(id) {
      var _this = this;

      var input = document.getElementById(id.address);
      var options = {
        language: 'jp',
        componentRestrictions: { country: 'jp' },
        types: ['establishment']
      };
      var autoComplete = new google.maps.places.Autocomplete(input, options);

      google.maps.event.addListener(autoComplete, 'place_changed', function () {
        var place = autoComplete.getPlace();
        console.log(place);

        _this.setCenter({
          lat: place.geometry.location.lat(),
          lng: place.geometry.location.lng()
        });
        _this.setInfoWindow("<h3>" + place.name + "</h3>", _this.pin);

        $("#" + id.address).val(place.name);
        $("#" + id.place).val(place.formatted_address);
        $("#" + id.formatted_address).text(place.formatted_address);
        $("#" + id.lat).val(place.geometry.location.lat());
        $("#" + id.lng).val(place.geometry.location.lng());
      });
    }

    // infoWindowを設置する

  }, {
    key: "setInfoWindow",
    value: function setInfoWindow(content, pin) {
      var _this2 = this;

      var html = "<div class='info-window'>" + content + "</div>";

      if (pin.infoWindow) {
        pin.infoWindow.setContent(html);
        return;
      }

      pin.infoWindow = new google.maps.InfoWindow({ content: html });
      pin.marker.addListener('click', function () {
        pin.infoWindow.open(_this2.map, pin.marker);
      });
      pin.infoWindow.open(this.map, pin.marker);
    }
  }, {
    key: "setCenter",
    value: function setCenter(latlng) {
      this.map.setCenter(latlng);
      this.setMarker(latlng);
    }
  }, {
    key: "removeAllMarkers",
    value: function removeAllMarkers() {}

    // 複数のマーカーを設置

  }, {
    key: "setMarkers",
    value: function setMarkers(positions) {
      var _this3 = this;

      if (!positions) return;

      // 表示領域の生成
      this.bounds = new google.maps.LatLngBounds();
      positions.map(function (pos) {
        var latlng = new google.maps.LatLng({ lat: pos.latitude || 0.0, lng: pos.longitude || 0.0 });
        var marker = new google.maps.Marker({
          position: latlng,
          map: _this3.map
        });
        // 地図表示領域をマーカー位置に合わせて拡大します。
        _this3.bounds.extend(marker.position);
        var pin = {
          marker: marker,
          infoWindow: _this3.richInfoWindow(pos)
        };
        pin.marker.addListener('click', function () {
          pin.infoWindow.open(this.map, pin.marker);
        });
        _this3.pins.push(pin);
      });
      // 地図表示領域の変更を反映します。
      this.map.fitBounds(this.bounds);
    }

    // RichなinfoWindow

  }, {
    key: "richInfoWindow",
    value: function richInfoWindow(pos) {
      var html = ["<div class='info-window card' data-id='" + pos.id + "'>", "<header class='card-header'>", "<p class='card-header-title'>" + pos.name + "</p>", '</header>', "<div class='card-content'>", "<div class='content'>" + pos.body.substr(0, 50) + "...</div>", '</div>', "<footer class='card-footer'>", "<a class='card-footer-item' href='/events/" + pos.id + "'>詳細</a>", "<a class='card-footer-item' href='" + pos.link + "'>詳細リンク</a>", '</footer>', '</div>'].join('');
      var infoWindow = new google.maps.InfoWindow({
        content: html
      });
      return infoWindow;
    }

    // 一つのマーカーを設置

  }, {
    key: "setMarker",
    value: function setMarker(latlng) {
      if (this.pin.marker) {
        this.pin.marker.setPosition(new google.maps.LatLng(latlng));
        return;
      }

      this.pin.marker = new google.maps.Marker({
        position: new google.maps.LatLng(latlng),
        map: this.map
      });
    }
  }]);

  return GMap;
}();
