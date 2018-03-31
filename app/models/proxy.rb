class Proxy < ApplicationRecord
    validates :ip, :uniqueness => { :scope => :port,
    :message => "already saved" }

    def self.new_proxy
      active_proxies = Proxy.where(status:"active")
      random_proxy = active_proxies[rand(active_proxies.count)]
      if random_proxy.nil? 
        return nil
      else
        proxy_url = "https://"+random_proxy.ip.to_s+":"+random_proxy.port.to_s
      end
    end

    def self.set_status(proxy_url,status)
      ip = proxy_url.split(":")[1][2..-1] 
      port = proxy_url.split(":")[2]
      proxy = Proxy.find_by(ip: ip, port: port)
      unless proxy.nil? 
        proxy.status = status
        proxy.save
      end
    end

    def check_validity(ip,port)
      proxy = "https://"+ip.to_s+":"+port.to_s
      begin
        RestClient::Request.execute(method: :get, url: 'http://api.ipify.org?format=json',
                            timeout: 4, proxy: proxy)
      rescue
          return false
      end
      return true
    end
    
    def update_proxy
      import_free_proxy_list
      import_ssl_proxies
      #import_proxynova 
    end

    private
    
    def import_proxynova
      proxy_list_page = "https://www.proxynova.com/proxy-server-list/"
      #response = RestClient.get("#{URI.parse(proxy_list_page)}")
      response = RestClient::Request.execute(method: :get, url: "#{URI.parse(proxy_list_page)}", timeout: 10)
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
            new_proxy.status = "active"
            new_proxy.save
        end
      end
    end

    def import_free_proxy_list
      proxy_list_page = "https://free-proxy-list.net/"
      response = RestClient::Request.execute(method: :get, url: "#{URI.parse(proxy_list_page)}", timeout: 10)
      html_page = Nokogiri::HTML(response)
      doc = html_page.xpath('//*[@id="proxylisttable"]/tbody/tr')
      
      doc.each_with_index do |row, index|
        ip = row.css("td[1]").text
        port = row.css("td[2]").text
        https = row.css("td[7]").text

        if (check_validity(ip,port) and (https == "yes"))
            new_proxy = Proxy.new
            new_proxy.ip = ip
            new_proxy.port = port
            new_proxy.status = "active"
            new_proxy.save
        end
        break if index > 30 #there are too many proxies on their list
      end
    end

    def import_ssl_proxies
      proxy_list_page = "https://www.sslproxies.org/"
      #response = RestClient.get("#{URI.parse(proxy_list_page)}")
      response = RestClient::Request.execute(method: :get, url: "#{URI.parse(proxy_list_page)}", timeout: 10)
      html_page = Nokogiri::HTML(response)
      doc = html_page.xpath('//*[@id="proxylisttable"]/tbody/tr')
      
      doc.each_with_index do |row, index|
        ip = row.css("td[1]").text
        port = row.css("td[2]").text

        if check_validity(ip,port)
            new_proxy = Proxy.new
            new_proxy.ip = ip
            new_proxy.port = port
            new_proxy.status = "active"
            new_proxy.save
        end
        break if index > 30 #there are too many proxies on their list
      end
    end
    




end