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
		elsif delay.to_f >= 55 
			number = 60
		end
		return "<i class=\"warning circle yellow icon\"></i>احتمال  #{number} دقیقه تاخیر".html_safe
	end

	def supplier_to_human(supplier_name)
		if supplier_name == "zoraq"
			return "زورق"
		elsif supplier_name == "alibaba"
			return "علی‌بابا"
		elsif supplier_name == "safarme"
			return "سفرمی"
		elsif supplier_name == "flightio"
			return "فلایتیو"
		elsif supplier_name == "ghasedak24"
			return "قاصدک۲۴"
		elsif supplier_name == "respina"
			return "رسپینا۲۴"
		elsif supplier_name == "trip"
			return "تریپ"
		elsif supplier_name == "travelchi"
			return "تراولچی"
		elsif supplier_name == "iranhrc"
			return "HRC"
		elsif supplier_name == "sepehr"
			return "سپهرسیر"
		else
			return supplier_name
		end
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

end