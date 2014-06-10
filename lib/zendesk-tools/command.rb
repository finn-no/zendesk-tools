module ZendeskTools
  class Command
    include Loggable

    def self.run(args)
      new(ZendeskTools.client, args).run
    end

    def initialize(client, args)
      @client = client
      @args   = args
    end

  end
end