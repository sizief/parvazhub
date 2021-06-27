# frozen_string_literal: true

class FlightPriceController < ApplicationController
  def index
    origin_name = params[:origin_name].downcase
    destination_name = params[:destination_name].downcase
    date = params[:date]
    flight_id = params[:id]
    @dates = []
    @georgian_dates = []
    @prices = []

    origin = City.find_by(english_name: origin_name.downcase)
    destination = City.find_by(english_name: destination_name.downcase)

    date_in_human = date_to_human date
    @flight = Flight.find(flight_id)
    @search_parameter = { 
      origin_english_name: origin.english_name,
      origin_persian_name: origin.persian_name,
      origin_code: origin.city_code,
      destination_english_name: destination.english_name,
      destination_persian_name: destination.persian_name,
      destination_code: destination.city_code,
      date: date, date_in_human: date_in_human
    }

    @flight_prices = FlightResult.new.get_flight_price(@flight)
    @flight_price_over_time = FlightPriceArchive.flight_price_over_time(flight_id, date)
    @flight_price_over_time.each do |date, price|
      @georgian_dates << date.to_s.to_date.strftime('%A %d %B')
      @dates << JalaliDate.new(date.to_s.to_date).strftime('%A %d %b')
      @prices << price
    end

    @airline = Airline.find_by(code: @flight.airline_code.split(',').first)
    @reviews = get_reviews @airline

    render :index
  end

  private

  def get_reviews(airline)
    return [] if airline.nil?

    Review
      .where(page: airline.english_name)
      .where.not(text: '')
      .where(published: true)
      .includes(:user)
      .order('created_at DESC')
      .sort_by { |r| r.user.anonymous? ? 1 : 0 }
  end

  def date_to_human(date)
    date = date.to_date
    if date == Date.today
      'امروز'
    elsif date == (Date.today + 1)
      'فردا'
    else
      JalaliDate.new(date.to_date).strftime ' %d %b'
    end
  end
end
