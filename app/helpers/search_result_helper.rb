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
		return "<i class=\"warning circle yellow icon\"></i> میانگین #{number} دقیقه تاخیر در گذشته".html_safe
	end

end