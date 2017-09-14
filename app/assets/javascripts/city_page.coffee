# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


document.addEventListener 'turbolinks:load', ->
  $('.city-page-toggle-box').click ->
    $('#link-dates').slideToggle ->
      $('#city-page-search-box').slideToggle()
    return
  return
return