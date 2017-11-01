class City < ApplicationRecord
  validates :city_code, :uniqueness => true
  
  def City.list
   {
	  thr:{fa:"تهران",en:"tehran"},
	  mhd:{fa:"مشهد",en:"mashhad"},
	  kih:{fa:"کیش",en:"kish"},
	  syz:{fa:"شیراز",en:"shiraz"},
	  ifn:{fa:"اصفهان",en:"isfahan"},
    abd:{fa:"آبادان",en:"abadan"},
    awz:{fa:"اهواز",en:"ahvaz"},
    adu:{fa:"اردبیل",en:"ardabil"}, 
    buz:{fa:"بوشهر",en:"bushehr"}, 
    tbz:{fa:"تبریز",en:"tabriz"},
    bnd:{fa:"بندرعباس",en:"bandarabbas"},
    zbr:{fa:"چابهار",en:"chabahar"},
    rzr:{fa:"رامسر",en:"ramsar"},
    ras:{fa:"رشت",en:"rasht"},
    zah:{fa:"زاهدان",en:"zahedan"},
    sry:{fa:"ساری",en:"sari"},
    gsm:{fa:"قشم",en:"gheshm"},
    ker:{fa:"کرمان",en:"kerman"},
    ksh:{fa:"کرمانشاه",en:"kermanshah"},
    gbt:{fa:"گرگان",en:"gorgan"},  
    azd:{fa:"یزد",en:"yazd"}
   }
  end

  def City.pages
    city_pages=["kih","mhd","syz","ifn","tbz","abd","awz"]
  end

  def City.default_destination_city
	"kish"
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