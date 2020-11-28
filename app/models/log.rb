# frozen_string_literal: true

class Log
  attr_reader :log_name, :content

  def initialize(args)
    @log_name = args[:log_name]
    @content = args[:content]
  end

  def save
    log_file_path_name = "log/supplier/#{log_name}" + Time.now.to_s + '.log'
    log_file = File.new(log_file_path_name.to_s, 'w')
    log_file.puts(content.force_encoding('UTF-8')) unless content.is_a? Array
    log_file.close
  end
end
