module SearchHelper
	def airline_logo_for (airline_code)
		image_url = "airline-logos/" + airline_code[0..1] + "@2x.png"
		image_tag image_url , class: "airline-logo image ui "
	end

	def airline_name_for(airline_code)
		airlines ={"W5"=>"ماهان",
			"AK"=>"اترک", 
  			"B9"=>"ایران‌ایر‌تور", 
	  		"sepahan"=>"سپاهان", 
	  		"hesa"=>"هسا",  
	  		"I3"=>"آتا", 
	  		"JI"=>"معراج", 
	  		"IV"=>"کاسپین", 
	  		"NV"=>"نفت", 
	  		"saha"=>"ساها", 
	  		"ZV"=>"زاگرس",
	  		"HH"=>"تابان",
	  		"QB"=>"قشم" ,
	  		"Y9"=>"کیش",
	  		"EP"=>"آسمان",
	  		"IR"=>"ایران‌ایر",
	  		"SR"=>"سپهران"
  		}
		airlines[airline_code].nil? ? airline_code : airlines[airline_code]
	end

	def supplier_logo_for (supplier)
		image_url = "suppliers/" + supplier + "-logo.png"
		image_tag image_url , class: "image ui supplier-logo tiny"
	end

	def hour_to_human (time)
		time_without_colon  = "#{time}".tr(':', '')
		phrase = case time_without_colon.to_i
        	when 400..1159 then "صبح"
        	when 1200..1559 then "ظهر"
        	when 1600..1959 then "عصر"
        	when 2000..2359 then "شب"
        	when 0..359 then "شب"
        else
        	" "
       	end
       	time + " " + phrase
	end

	def search_link_builder(origin,destination,date)
		link = "/flights?utf8=✓&search%5Borigin%5D=#{origin}&search%5Bdestination%5D=#{destination}&search%5Bdate%5D=#{date}"
	end

	def day_name_to_human (day)
		days_in_farsi = {today: 'امروز', tomorrow: 'فردا', dayaftertomorrow: 'پس فردا'}
		days_in_farsi[day]
	end

end