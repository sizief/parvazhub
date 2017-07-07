class Proxy < ApplicationRecord
    
    def self.import_list
      proxy_list_page = "https://free-proxy-list.net/"
      response = RestClient.get("#{URI.parse(proxy_list_page)}")
      html_page = Nokogiri::HTML(response)
      doc = html_page.xpath('//*[@id="proxylisttable"]/tbody/tr')
      if doc.count > 100
        Proxy.delete_all
        doc.each do |row|
            new_proxy = Proxy.new
            new_proxy.ip = row.css("td[1]").text
            new_proxy.port = row.css("td[2]").text
            new_proxy.save
        end
      end
    end

end
