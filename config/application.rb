require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FlightSearch
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.default_locale = :en
    
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    #sendinblue config
    #config.action_mailer.smtp_settings = { address: 'smtp-relay.sendinblue.com', port: 587, domain: "parvazhub.com",user_name: "sizief@gmail.com" , password: "LORGbSmqHjp6FZg0", authentication: 'login',enable_starttls_auto: true}
    #zoho config
    #config.action_mailer.smtp_settings = { address: 'smtp.zoho.com', port: 465, domain: "parvazhub.com",user_name: "salam@parvazhub.com" , password: "salamsalam", authentication: 'login',enable_starttls_auto: true}
    #sparkpost config
    config.action_mailer.smtp_settings = { 
    	address: 'smtp.sparkpostmail.com', 
    	port: 587, #2525 
    	domain: "parvazhub.com",
    	user_name: "SMTP_Injection", 
    	password: "5c6101a8cc2208e3e3681d8f0dccbbfa4303901c", 
    	authentication: 'LOGIN',
    	enable_starttls_auto: true}

end
end