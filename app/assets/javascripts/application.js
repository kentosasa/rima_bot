// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready( function () {
  /* notificationの閉じるをクリックしたら閉じる */
  $('.notification .delete').on('click', function () {
    $(this).parent().fadeOut();
  });

  /* notificationは何もしなくても5秒後に消滅する */
  setTimeout(function () {
    $('.notification').each(function () {
      if (!$(this).attr('data-flash')) $(this).fadeOut('normal');
    });
  }, 5000);

  $('.nav-toggle').on('click', function() {
    $('.nav-menu').toggleClass('is-active')
  })

  $('.contact #send-mail').on('click', function(e) {
    e.preventDefault()
    var name = $('#contact-name').val()
    var email = $('#contact-email').val()
    var body = $('#contact-body').val()
    console.log(name, email, body)
    if(name === '' || email === '' || body === '') {
      swal({
        text: 'お名前、メールアドレス、本文を入力してください。',
        type: 'warning',
        timer: 2000
      })
      return
    }

    $(this).addClass('is-loading is-disabled')
    $.ajax({
      url: 'https://formspree.io/rimasan.bot@gmail.com',
      method: 'POST',
      data: {name: name, email: email, body: body},
      dataType: 'json'
    })

    swal({
      title: 'メールを送信しました。',
      type: 'success',
      timer: 2000
    })
    $(this).removeClass('is-loading is-disabled')
    $('#contact-name').val('')
    $('#contact-email').val('')
    $('#contact-body').val('')
  })
})
