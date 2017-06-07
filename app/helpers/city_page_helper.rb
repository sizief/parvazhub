module CityPageHelper

  def prepare_each_calendar price 
    offset =0
    prepared_calendar = price
    starting_day = price.first.keys[0].to_s.to_date.strftime "%A"
    case starting_day
      when "Saturday"
        offset = 0
      when "Sunday"
        offset = 1
      when "Monday"
        offset = 2
      when "Tuesday"
        offset = 3
      when "Wednesday"
        offset = 4
      when "Thursday"
        offset = 5
      when "Friday"
        offset = 6
    end

    #this is fot preparing to show starting on saturday
    first_day = price.first.keys[0].to_s.to_date
    0.upto(offset-1) do |i|
      prepared_calendar.unshift({(first_day-i-1).to_s.to_sym =>"-"})
    end

    last_day = price.last.keys[0].to_s.to_date
    0.upto(27-price.size) do |i|
      prepared_calendar << {(last_day-i+1).to_s.to_sym =>"-"}
    end
    return prepared_calendar
  end

  def prepare_for_calendar_view prices
  	prices.each do |key,value|
      value = prepare_each_calendar value
    end
  end

  def city_page_box city_code
    #(@city_pages & [@search_parameter[:destination], @search_parameter[:origin]]).present? %> 
    box = '
    <a href="/city/#{cities[city_code.to_sym][:en]}">
    <div class="web-font city-header-image" style=" background-image: url(/assets/cities/#{cities[city_code.to_sym][:en]}-big.jpg);background-size: cover; ">
      <h1 style="background: url(/assets/opacity-backgrounds/black50p.png); " class="city-page-title web-font">
      قیمت پروازهای 
      #{cities[city_code.to_sym][:fa]
    </h1>
    </div>
    </a>'
  end
end