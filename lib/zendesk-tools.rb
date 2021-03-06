require "zendesk-tools/version"
require "zendesk_api"
require 'json'
require 'pathname'
require 'pp'
require 'logger'
require 'log4r'
require 'log4r/config'

require 'zendesk-tools/loggable'
require 'zendesk-tools/command'
require 'zendesk-tools/clean_suspended'
require 'zendesk-tools/upload_files_to_ticket'
require 'zendesk-tools/recover_suspended'

module ZendeskTools
  CONFIG_FILE = Pathname.new(File.expand_path("~/.zendesk-tools.json"))

  def self.config
    @config ||= (
      if CONFIG_FILE.exist?
        JSON.parse(CONFIG_FILE.read)
      elsif ENV['ZD_URL'] && ENV['ZD_TOKEN'] && ENV['ZD_USERNAME']
        heroku_config = { 
         'delete_causes' => ENV['delete_causes'],
         'delete_subjects' => ENV['delete_subjects'],
         'recover_causes' => ENV['recover_causes']
        }
        heroku_config.each do |key, value| 
         unless value.nil?
           heroku_config[key] = value.split(';')
          end
        end
        heroku_config['url'] = ENV['ZD_URL']
        heroku_config['token'] = ENV['ZD_TOKEN']
        heroku_config['username'] = ENV['ZD_USERNAME']

        heroku_config
      else
        raise "Sorry, could not find JSON config in #{CONFIG_FILE}"
      end
    )
  end

  def self.show_config
    pp config
  end

  def self.client
    @client ||= (ZendeskAPI::Client.new do |c|
        # Mandatory:

        c.url      = config['url'] || "https://finn.zendesk.com/api/v2"
        c.username = config.fetch('username')
        c.token    = config.fetch('token')

        # Optional:

        if %w[debug trace].include? config['log_level']
          c.logger = Loggable.logger_for("ZendeskAPI")
        end

        # Retry uses middleware to notify the user
        # when hitting the rate limit, sleep automatically,
        # then retry the request.
        c.retry = true

        # Changes Faraday adapter
        # config.adapter = :patron

        # Merged with the default client options hash
        # config.client_options = { :ssl => false }
      end
    )
  end
end
