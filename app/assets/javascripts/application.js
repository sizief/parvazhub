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
//  this is georgian calendar: calendar.min
//= require jquery2
//= require jquery_ujs
//= require turbolinks
//= require semantic-ui
//= require rtlcss.min
//= require persian-date.min
//= require persian-datepicker-0.4.5.min
//= require tablesort
//= require typeahead.bundle.min
//= require chart.min
//= require_tree .

// add hide and show to modal for before and after load 
document.addEventListener("turbolinks:request-start", function() {
   $('.ui.basic.modal.waiting').modal('show');
});
document.addEventListener("turbolinks:load", function() {
  $('.ui.basic.modal.waiting').modal('hide');
});

$(document).ready(function(){
    // add modal to modal mark up
    $('.ui.basic.modal.waiting')
        .modal({blurring: true})
        .modal('setting', 'closable', false);
});


    
