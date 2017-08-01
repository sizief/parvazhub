module SearchHelper
	def airline_logo_for (airline_code,size=nil)
		image_url = "airline-logos/" + airline_code[0..1] + "@2x.png"
		if size == nil
			image_tag image_url , class: "airline-logo image ui "
		else
			image_tag(image_url , class: "airline-logo image ui ", style: "width:#{size}")
		end
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
			"SE"=>"ساها", 
			"ZV"=>"زاگرس",
			"HH"=>"تابان",
			"QB"=>"قشم‌ایر" ,
			"Y9"=>"کیش‌ایر",
			"EP"=>"آسمان",
			"IR"=>"ایران‌ایر",
			"SR"=>"سپهران"
		}
	airlines[airline_code].nil? ? airline_code : airlines[airline_code]
	end

	def airplane_name_for airplane_type
	  case airplane_type.upcase
	  when "MD80","MD-80","MD82","MD-82","MD83","MD-83","MD88","MD-88"
	  	ariplane_name = "بویینگ MD"
	  when "AB3"
	  	ariplane_name = "ایرباس"
	  when "A300-600"
	  	ariplane_name= "ایرباس ۳۰۰"
	  when "A310","AIRBUS A310"
	  	ariplane_name = "ایرباس ۳۱۰"
	  when "A320","AIRBUS A320"
	  	ariplane_name = "ایرباس ۳۲۰"
	  when "BOEING 727-200","727","727-200"
	  	ariplane_name = "بویینگ ۷۲۷"
	  when "B737","737","737-500","B737-400","737-300","737-600","737-300","737-700"
	  	ariplane_name = "بویینگ ۷۳۷"
	  when "FOKKER 100","F100"
	  	ariplane_name = "فوکر ۱۰۰"
	  when "747"
	  	ariplane_name = "بویینگ ۷۴۷"
	  		
	  end
	  
	  ariplane_name ||= airplane_type
	end

	
end