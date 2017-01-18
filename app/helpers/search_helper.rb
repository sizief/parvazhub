module SearchHelper
	def airline_logo_for (airline_code)
		image_url = "airline-logos/" + airline_code[0..1] + "@2x.png"
		image_tag image_url , class: "airline-logo"
	end
end
