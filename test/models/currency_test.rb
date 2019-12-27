# frozen_string_literal: true

require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  def setup
    @currency = Currency.new
  end

  test 'to dollar' do
    amount = 200_000
    dollar_amount = @currency.to_dollar amount
    assert_equal dollar_amount, (amount.to_f / ENV['DOLLAR_TO_RIAL_RATE'].to_f).round(1)
  end
end
