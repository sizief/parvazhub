class City
  def City.list
   {
	  thr:{fa:"تهران",en:"tehran"},
	  mhd:{fa:"مشهد",en:"mashhad"},
	  kih:{fa:"کیش",en:"kish"},
	  syz:{fa:"شیراز",en:"shiraz"},
	  ifn:{fa:"اصفهان",en:"isfahan"}
   }
  end

  def City.pages
    city_pages=["kih","mhd","syz","ifn"]
  end

  def City.default_destination_city
	"kih"
  end

  def City.get_city_code_based_on_name persian_name
    persian_name = persian_name.sub "ك", "ک"
    persian_name = persian_name.sub "ي", "ی"

    city_code = false
  	City.list.each do |key,value|
  	  if value[:fa] == persian_name.strip
  	    city_code =  key.to_s
  	  end  	  
  	end
  	city_code
  end

  def City.get_city_code_based_on_english_name english_name
    city_code = false
    City.list.each do |key,value|
      if value[:en] == english_name.strip
        city_code =  key.to_s
      end     
    end
    city_code
  end

end