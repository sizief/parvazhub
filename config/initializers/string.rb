# frozen_string_literal: true
# encoding: UTF-8

class String
  def to_fa
    gsub(
      /[1234567890]/,
      '1' => '۱',
      '2' => '۲',
      '3' => '۳',
      '4' => '۴',
      '5' => '۵',
      '6' => '۶',
      '7' => '۷',
      '8' => '۸',
      '9' => '۹',
      '0' => '۰'
    )
  end
end
