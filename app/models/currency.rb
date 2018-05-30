class Currency 
  def to_dollar amount
    (amount.to_f/ENV["DOLLAR_TO_RIAL_RATE"].to_f).round(1)
  end   
end