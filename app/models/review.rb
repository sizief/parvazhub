class Review < ApplicationRecord
  belongs_to :user
  enum category: [:general, :airline, :supplier]

  def get_last_supplier_review
    review = get_not_null_text_review "supplier"
    unless review.nil?
      review = review.attributes
      review["author"] = review["author"].empty? ? "ناشناس" : review["author"]
      review["persian_name"] = Supplier.new.get_persian_name review["page"]
    end
    review
  end

  def get_last_airline_review
    review = get_not_null_text_review "airline"
    unless review.nil?
      review = review.attributes
      review["author"] = review["author"].empty? ? "ناشناس" : review["author"]
      review["persian_name"] = Airline.new.get_persian_name_by_english_name review["page"]
    end
    review
  end
  
  private
  
  def get_not_null_text_review review_type
    Review.where(category: review_type).where.not(text: nil).where.not(text: "").where(published: true).last
  end
end
