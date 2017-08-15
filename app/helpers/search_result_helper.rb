module SearchResultHelper
  
  def which_city_page(origin,destination)
  	city_code =nil
  	if City.pages.include? origin
  	  city_code = origin 
  	elsif City.pages.include? destination
  		city_code = destination
  	end
	end
	
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
		return "<i class=\"warning circle yellow icon\"></i>  #{number} دقیقه سابقه تاخیر".html_safe
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
		else
			return supplier_name
		end
	end

end