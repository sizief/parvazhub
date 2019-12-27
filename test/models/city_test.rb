# frozen_string_literal: true

require 'test_helper'

class CityTest < ActiveSupport::TestCase
  test 'should return default destination code' do
    city_code = City.default_destination_city
    assert city_code.length > 2
  end

  test 'should return city code' do
    wrong_persian_name = 'طرقبه '
    correct_persian_name = 'کیش '

    wrong_city_code = City.get_city_code_based_on_name wrong_persian_name
    correct_city_code = City.get_city_code_based_on_name correct_persian_name

    assert_equal(wrong_city_code, false, 'city code is not exist but returned true')
    assert (correct_city_code.is_a? String), 'city code is not a string'
    assert_not_empty correct_city_code, 'city code is empty'
    assert_not wrong_city_code
  end

  test 'should return city code based on english name' do
    available_city = 'tehran'
    not_available_city = 'torghabe'

    assert_equal City.get_city_code_based_on_english_name(available_city), 'thr'
    assert_equal City.get_city_code_based_on_english_name(not_available_city), false
  end
end
