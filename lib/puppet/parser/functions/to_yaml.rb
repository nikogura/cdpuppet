module Puppet::Parser::Functions
  newfunction(:to_yaml, :type => :rvalue) do |args|

    require 'yaml'

    data = args[0]

    return data.to_yaml.gsub(/":(\w+)"/, ":"+'\1').gsub(/>>/, '}').gsub(/<</,'%{')


  end
end
