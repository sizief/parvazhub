# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  enum category: %i[general airline supplier]

  scope :last_text_review, ->(category) { 
    where(category: category).where.not(text: nil).where.not(text: '').where(published: true).last
  }

  SUPPLIER = 'supplier'
  AIRLINE = 'airline'
  ANONYMOUS_NAME = 'ناشناس'

  def self.last_supplier_review
    last_text_review(SUPPLIER)
  end

  def self.last_airline_review
    last_text_review(AIRLINE)
  end

  def author_full_name
    return user.full_name unless user.anonymous?
    return ANONYMOUS_NAME if author.nil?
    return ANONYMOUS_NAME if author == ''

    author
  end

  def page_name
    if airline? 
      Airline.new.get_persian_name_by_english_name(page)
    elsif supplier?
      Supplier.new.get_persian_name(page)
    else
      nil
    end
  end

  def airline?
    category === AIRLINE
  end

  def supplier?
    category === SUPPLIER
  end

end
