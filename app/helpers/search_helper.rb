module SearchHelper
	def airline_logo_for (airline_code,size=nil,is_block=true)
		image_url = "airline-logos/" + airline_code[0..1] + "@2x.png"
		block = is_block ? " " : "inline-block"
		if size == nil
			image_tag(image_url , class: "airline-logo image ui #{block}")
		else
			image_tag(image_url , class: "airline-logo image ui #{block}", style: "width:#{size}")
		end


	end

	def supplier_logo_for (supplier,size=nil)
		size ||= "tiny"
		image_url = "suppliers/" + supplier + "-logo.png"
		image_tag image_url , class: "image ui supplier-logo #{size} flight-price-logo"
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

	def search_link_builder(origin_name,destination_name,date)
		link = "/flights/#{origin_name}-#{destination_name}/#{date}"
	end

	def day_name_to_human (day)
		days_in_farsi = {today: 'امروز', tomorrow: 'فردا', dayaftertomorrow: 'پس فردا'}
		days_in_farsi[day]
	end

    def airline_name_for(airline_code)
	  airlines = Airline.hash_list 
	  airlines[airline_code.to_sym].nil? ? airline_code : airlines[airline_code.to_sym]
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
	  when "A321","AIRBUS A321"
			ariplane_name = "ایرباس ۳۲۱"
	  when "A320","AIRBUS A320"
	  	ariplane_name = "ایرباس ۳۲۰"
	  when "BOEING 727-200","727","727-200","B727","B.727"
	  	ariplane_name = "بویینگ ۷۲۷"
	  when "B737","737","737-500","B737-400","737-300","737-600","737-300","737-700","737-100"
	  	ariplane_name = "بویینگ ۷۳۷"
	  when "FOKKER 100","F100"
	  	ariplane_name = "فوکر ۱۰۰"
	  when "747"
	  	ariplane_name = "بویینگ ۷۴۷"
	  		
	  end
	  
	  ariplane_name ||= airplane_type
	end

	
end