module Puppet::Parser::Functions
  newfunction(:to_json, :type => :rvalue) do |args|

    require 'json'

    data = args[0]

    return JSON.generate(data).to_s

  end
end
