class City < ApplicationRecord
  validates :city_code, :uniqueness => true
  validates :english_name, :uniqueness => true
  
  def City.pages
    city_pages=["kih","mhd","syz","ifn","tbz","abd","awz"]
  end

  def City.default_destination_city
	"kish"
  end

  def City.get_city_code_based_on_name persian_name
    persian_name = persian_name.sub "ك", "ک"
    persian_name = persian_name.sub "ي", "ی"

    
    city = City.find_by(persian_name: persian_name.strip)
    city_code = city.nil? ? false : city.city_code
    
    #city_code = false
  	#City.list.each do |key,value|
  	#  if value[:fa] == persian_name.strip
  	#    city_code =  key.to_s
  	#  end  	  
  	#end
  	city_code
  end

  def City.get_city_code_based_on_english_name name
    city = City.find_by(english_name: name)
    city_code = city.nil? ? false : city.city_code.downcase
  end
  
end