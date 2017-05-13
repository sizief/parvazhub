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

end
