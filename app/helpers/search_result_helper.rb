module SearchResultHelper
	
	def delay_to_human(delay)
		if delay.to_f < 15 or delay.nil?
			return nil
	  elsif delay.to_f >= 15 and delay.to_f < 25
			number = 20
		elsif delay.to_f >= 25 and delay.to_f < 35
			number = 30
		elsif delay.to_f >= 35 and delay.to_f < 45
			number = 40
		elsif delay.to_f >= 45 and delay.to_f < 55
			number = 50
		elsif delay.to_f >= 55 and delay.to_f < 85
			number = 80
		elsif delay.to_f >= 85 
			number = 120 #delay.to_f
		end
		return "<i class=\"warning circle yellow icon\"></i>احتمال  #{number} دقیقه تاخیر".html_safe
	end

	def trip_duration_to_human total_minute
		message = " "
		unless total_minute.nil?
			message = " "
			hours = total_minute / 60
			minutes = (total_minute) % 60
			message = "#{hours} ساعت " unless hours == 0 
			message += "و #{minutes} دقیقه " unless minutes == 0 
		end
		return message
	end

	def stop_to_human stops
		stops = stops.split(",")
		if stops.count == 1
			message = "بدون توقف" 
		else
			message = "#{stops.count-1} توقف در "
		    stops.each_with_index do |stop, index|
				next if stops.count == index+1
				message += " و " if index >= 1
				message += stop
			end
		end
		message
	end

	def number_with_zero(number)
	  number_string = number.to_s
	  case number_string.size
	  when 5
		number_with_zero = "000" + number_string
	  when 6
		number_with_zero = "00" + number_string
	  when 7
		number_with_zero = "0" + number_string
	  when 8
		number_with_zero = number_string	
	  end
	  number_with_zero
	end

	def day_name date,saerch_parameter_date
		date = date.to_date
		day_name = nil
		if date == Date.today 
			day_name = "امروز"
		elsif date == (Date.today+1) 
			day_name = "فردا"
		else
			day_name = date.to_parsi.strftime("%A")
		end
		(search_date_dentifier(date,saerch_parameter_date)+day_name).html_safe
	end

	def search_date_dentifier date,saerch_parameter_date
		if saerch_parameter_date.to_date == date.to_date
			"<i class='arrow down icon'></i>" 
		else
			""
		end
	end

	def price_to_human price
		if price.nil? 
			message = "<i class='plane icon'></i>".html_safe 
		else
			 #number_with_delimiter(price)
			 message = ((price/1000).to_s + "<sup><span style='font-size:0.5em'>هزارتومان</span></sup>").html_safe
		end
		message
	end

end