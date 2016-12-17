class SearchController < ApplicationController
  def flight
  end

  def results
  	
  	origin = params[:search][:origin]
  	destination = params[:search][:destination]
  	render html: zoraq_search(origin, destination) #{}"Origin: #{search_criteria[:origin]} and Destination: #{search_criteria[:destination]}"

  end

  def zoraq_search(origin,destination)
	require "uri"
	require "net/http"

	params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => '12/20/2016 00:00:00 AM', 'DepartureReturn' => '12/21/2016 00:00:00 AM', 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
	#params = {'OrginLocationIata' => "IKA", 'DestLocationIata' => "DXB", 'DepartureGo' => '12/20/2016 00:00:00 AM', 'DepartureReturn' => '12/21/2016 00:00:00 AM', 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}

	x = Net::HTTP.post_form(URI.parse('http://development.zoraq.com/Flight/DeepLinkSearch'), params)
	x.body
	end
end
