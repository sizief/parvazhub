require 'test_helper'

class CityTest < ActiveSupport::TestCase

  test "city list should return hash with more than five city" do
    city_list = City.list
    assert city_list.is_a? Hash
    assert  city_list.count > 4
  end

  test "should return default destination code" do
    city_code = City.default_destination_city
    assert city_code.length > 2
  end

  test "should return city code" do
    wrong_persian_name = "بیرجند "
    correct_persian_name = "کیش "

    wrong_city_code = City.get_city_code_based_on_name wrong_persian_name
    correct_city_code = City.get_city_code_based_on_name correct_persian_name

    assert ([true,false].include? wrong_city_code), "city code is not exist but returned not false"
    assert (correct_city_code.is_a? String), "city code is not a string"
    assert_not_empty correct_city_code, "city code is empty" 
    assert_not wrong_city_code
  end

  
end
