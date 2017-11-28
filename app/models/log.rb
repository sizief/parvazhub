class Log 
  attr_reader :log_name, :content

  def initialize args
    @log_name = args[:log_name]
    @content = args[:content]
  end

  def save
    log_file_path_name = "log/supplier/#{log_name}"+Time.now.to_s+".log"
    log_file = File.new("#{log_file_path_name}", "w")
    log_file.puts(content)
    log_file.close
  end

end
