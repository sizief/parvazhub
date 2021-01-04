$(document).ready(function(){
  function waitingModal(origin, destination, suppliers) {
    return `
      <div class="ui basic modal waiting" style="left: initial;text-align: center;font-size: x-large;">
        <div style="display:flex;align-items:center;justify-content:center;height:100%;width:100%;">
          <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="0 0 300 300" preserveAspectRatio="none" style="width:300px; height:300px; top:0; left:0;">
            <circle cx="100" cy="150" r="57" id="pink-halo" fill="none" stroke="#29aae1" stroke-width="8" stroke-dasharray="0, 361" transform="rotate(-90,100,100)" />
            <text id="myTimer" text-anchor="middle" x="150" y="115" style="font-size: 40px; fill:#ffffff">
            </text>
          </svg>
        </div>
        <div style='font-size: 0.7em; margin-top: -6em;'>
          <div style='width: 270px; line-height: 29px;margin: auto'>
            در حال جستجوی پروازهای
           ${origin}
           به
           ${destination}
        از  سایت‌های
           معتبر فروش بلیط
          </div>
          <div style='text-align: center;  width: 320px; margin: auto;'>
            ${suppliers}
          </div>
        </div>
      </div>`
  }

  function countDown(timeout) {
    var circle = document.getElementById('pink-halo');
    var myTimer = document.getElementById('myTimer');
    var t = timeout;
    var interval = 30;
    var angle = 0;
    var angle_increment = 360/t;
    var intervalCounter = 0;
    return (
      window.setInterval(function () {
        intervalCounter ++;
        circle.setAttribute("stroke-dasharray", angle + ", 361");
        myTimer.innerHTML = t - parseInt((angle/360)*t);

        if (angle >= 360) {
            window.clearInterval(window.timer);
        }

        angle += angle_increment/(1000/interval);
    }.bind(this), interval));
  }

  function isSearchResultPage(url) {
    if (url.length != 6) return false
    if (url[3] != 'flights') return false
    if (url[5].split('-').length != 3) return false

    return true
  }

  document.addEventListener("turbolinks:request-start", function(event) {
    let url = event.data.url.split('/')
    if (!isSearchResultPage(url)) return

    let timeoutDomestic = $("#jsLoading").attr("data-timeout")
    let cities = JSON.parse($("#jsLoading").attr("data-cities"))
    let suppliers = $("#jsLoading").attr("data-suppliers")

    origin = url[4].split('-')[0]
    destination = url[4].split('-')[1]

    let suppliersTags = suppliers.split('-').map(
      function(supplier){
        return(`
        <div style="display: inline-block; width: 140px;margin-top: 2em;">
          <img class="image ui supplier-logo tiny flight-price-logo " src="/static/suppliers/${supplier}-logo.png" />
        </div>
          `
        )
      }
    )
    $("#jsLoading").append(waitingModal(cities[origin], cities[destination], suppliersTags.join(' ')));

    $('.ui.basic.modal.waiting')
    .modal({blurring: true})
    .modal('setting', 'closable', false)
    .modal('show');
    window.timer = countDown(timeoutDomestic);
  });
  document.addEventListener("turbolinks:load", function() {
    $("#jsLoading").empty();
    $('.ui.basic.modal.waiting').modal('hide');
    window.clearInterval(window.timer);
  });
  document.addEventListener("turbolinks:before-visit", function() {
    $("#jsLoading").empty();
    window.clearInterval(window.timer);
  });
});
