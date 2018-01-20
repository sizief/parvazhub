class FlightPrice < ApplicationRecord
	belongs_to :flight, counter_cache: true

	def self.delete_old_flight_prices(supplier,route_id,date)
      flights = Flight.select(:id).where(route_id: route_id).where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).to_a
	  flights = flights.map{ |flight| flight.id}
	  FlightPrice.where(flight_id: flights).where(flight_date:"#{date}").where(supplier: "#{supplier}").delete_all
	end 

	def get(flight_id,result_time_to_live)
	  responses = Array.new
	  suppliers_list = FlightPrice.select(:id, :flight_id, :price, :supplier, :created_at).where(flight_id: flight_id)
				.where('created_at >= ?', result_time_to_live)
				.order(:price)
	  suppliers_list.each do |supplier|
		response = Hash.new
		response[:id] = supplier.id
		response[:flight_id] = supplier.flight_id
		response[:price] = supplier.price
		response[:supplier_english_name] = supplier.supplier
		response[:created_at] = supplier.created_at
		response[:supplier_persian_name] = supplier_persian_name supplier.supplier
		response[:supplier_logo] = supplier_logo supplier.supplier
		responses << response
	  end
	  return responses
	end

	private
	def supplier_logo supplier_name
	  "https://parvazhub.com/static/suppliers/" + supplier_name.to_s + "-logo.png"
	end

	def supplier_persian_name(supplier_name)
	  if supplier_name == "zoraq"
		return "زورق"
	  elsif supplier_name == "alibaba"
		return "علی‌بابا"
	  elsif supplier_name == "safarme"
		return "سفرمی"
	  elsif supplier_name == "flightio"
		return "فلایتیو"
	  elsif supplier_name == "ghasedak"
		return "قاصدک۲۴"
	  elsif supplier_name == "respina"
		return "رسپینا۲۴"
	  elsif supplier_name == "trip"
		return "تریپ"
	  elsif supplier_name == "travelchi"
		return "تراولچی"
	  elsif supplier_name == "iranhrc"
		return "ایران‌اچ‌آر‌سی"
	  elsif supplier_name == "sepehr"
		return "سپهرسیر"
	  elsif supplier_name == "flytoday"
		return "فلای‌تودی"
	  elsif supplier_name == "safarestan"
		return "سفرستان"
	  else
		return supplier_name
	  end
	end
end
