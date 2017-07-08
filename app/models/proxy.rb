class Proxy < ApplicationRecord
    
    def self.import_list
      proxy_list_page = "https://www.proxynova.com/proxy-server-list/"
      response = RestClient.get("#{URI.parse(proxy_list_page)}")
      html_page = Nokogiri::HTML(response)
      doc = html_page.xpath('//*[@id="tbl_proxy_list"]/tbody[1]/tr')
      if doc.count > 1
        Proxy.delete_all
        doc.each do |row|
            
            ip = row.css("td[1]").text
            next unless ip.include? "document" #there is some row that did not contain ips

            ip.remove!("document.write('")
            ip.remove!("'.substr(2) + '")
            ip.remove!("');")
            ip = ip[2..-1]
            
            if row.css("td[2] a").text.empty?
                port = row.css("td[2]").text.gsub(/[^0-9]/, "")
            else
                port = row.css("td[2] a").text
            end
            
            new_proxy = Proxy.new
            new_proxy.ip = ip
            new_proxy.port = port
            new_proxy.save
        end
      end
    end

end
