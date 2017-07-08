class Proxy < ApplicationRecord
    validates :ip, :uniqueness => { :scope => :port,
    :message => "already saved" }

    def update_proxy
      import_free_proxy_list
      import_proxynova 
    end
    
    def import_proxynova
      proxy_list_page = "https://www.proxynova.com/proxy-server-list/"
      response = RestClient.get("#{URI.parse(proxy_list_page)}")
      html_page = Nokogiri::HTML(response)
      doc = html_page.xpath('//*[@id="tbl_proxy_list"]/tbody[1]/tr')
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

        if check_validity(ip,port)
            new_proxy = Proxy.new
            new_proxy.ip = ip
            new_proxy.port = port
            new_proxy.save
        end
      end
    end

    def import_free_proxy_list
      proxy_list_page = "https://free-proxy-list.net/"
      response = RestClient.get("#{URI.parse(proxy_list_page)}")
      html_page = Nokogiri::HTML(response)
      doc = html_page.xpath('//*[@id="proxylisttable"]/tbody/tr')
      
      doc.each_with_index do |row, index|
        ip = row.css("td[1]").text
        port = row.css("td[2]").text

        if check_validity(ip,port)
            new_proxy = Proxy.new
            new_proxy.ip = ip
            new_proxy.port = port
            new_proxy.save
        end
        break if index > 30 #there are too many proxies on their list
      end
    end

    def check_validity(ip,port)
      proxy = "http://"+ip+":"+port
      begin
        RestClient::Request.execute(method: :get, url: 'http://api.ipify.org?format=json',
                            timeout: 1, proxy: proxy)
      rescue
          return false
      end
      return true
    end

    def clean_up
      Proxy.all.each do |proxy|
        proxy.delete unless check_validity(proxy.ip.to_s,proxy.port.to_s)
      end
    end

    def self.new_proxy
      random_proxy = Proxy.offset(rand(Proxy.count)).first
      proxy_url = "http://"+random_proxy.ip.to_s+":"+random_proxy.port.to_s
    end

end
