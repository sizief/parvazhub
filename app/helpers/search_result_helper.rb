module SearchResultHelper
  
  def which_city_page(origin,destination)
  	city_code =nil
  	if City.pages.include? origin
  	  city_code = origin 
  	elsif City.pages.include? destination
  		city_code = destination
  	end
  end

end