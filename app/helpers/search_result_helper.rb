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
	  elsif delay.to_f >= 15 and delay.to_f < 30
			number = 20
		elsif delay.to_f >= 30 and delay.to_f < 45
			number = 40
		elsif delay.to_f >= 45 and delay.to_f < 60
			number = 50
		elsif delay.to_f >= 60 
			number = 90
		end
		return "<i class=\"wait yellow icon\"></i> احتمال #{number} دقیقه تاخیر".html_safe
	end

end