module Puppet::Parser::Functions
  newfunction(:to_yaml, :type => :rvalue) do |args|

    require 'yaml'

    data = args[0]

    return YAML.to_yaml(data)

  end
end
