require 'yaml'
require 'fileutils'

File.umask(0022)

#read r10k.yaml
configFile = 'r10k.yaml'
defaultFile = "/etc/#{configFile}"
envDir = 'environments'

#directories we're going to nuke
deadList = []

if (Dir.exist?('/etc/puppetlabs/puppet'))
  puppet_confdir = '/etc/puppetlabs/puppet'
else
  puppet_confdir = '/etc/puppet'
end

if (File.exist?("./#{configFile}"))
  config = YAML.load_file("./#{configFile}")
else
  config = YAML.load_file(defaultFile)
end

if (Dir.exist?("./#{envDir}"))
  env_dir = "./#{envDir}"
else
  env_dir = "#{puppet_confdir}/#{envDir}"

end

#for each repo
config['sources'].each do |src|
  modname = src[0]

  if (config['sources'][modname]['filter'])
    fType = config['sources'][modname]['filter']['type']

    # find filter type  (whitelist | blacklist)
    if (config['sources'][modname]['filter']['list'])
      filterMethod = 'list'
    elsif (config['sources'][modname]['filter']['regex'])
      filterMethod = 'regex'
    end

    #iterate over module branches
    Dir.entries("#{env_dir}").select {|name| name =~/^#{modname}_/}.each do |branch_dir|
      branch_name = branch_dir.gsub(/^.+?_/, "")

      #figure out if this thing is in the list, or matches the regex

      if (filterMethod == 'list')
        list = config['sources'][modname]['filter']['list']

        if (list.include?(branch_name))
          if (fType == 'blacklist')
            deadList.push("#{puppet_confdir}/#{envDir}/#{branch_dir}")
          end
        else
          if (fType == 'whitelist')
            deadList.push("#{puppet_confdir}/#{envDir}/#{branch_dir}")
          end
        end

      elsif (filterMethod == 'regex')
        regex = config['sources'][modname]['filter']['regex']

        if (fType == 'blacklist')
          if (branch_name.match(regex))
            deadList.push("#{puppet_confdir}/#{envDir}/#{branch_dir}")
          else
          end
        else
          if (branch_name.match(regex))
            deadList.push("#{puppet_confdir}/#{envDir}/#{branch_dir}")
          else
          end
        end
      else
        puts "unknown filter method '#{filterMethod}' currently only 'list' and 'regex' are supported"
      end
    end
  end
end

#remove the directory
FileUtils.rm_rf(deadList)

#create symlinks to each module's own manifests dir for autoloading

Dir.chdir(env_dir)

config['sources'].each do |src|
  modname = src[0]

  if (config['sources'][modname]['selflink'])
    #iterate over module branches
    Dir.entries("./").select {|name| name =~/^#{modname}_/}.each do |branch_dir|

      Dir.chdir(branch_dir)

      # create fake module dir
      if Dir.exist?('modules')

        newDir = "modules/#{modname}"

        if !File.directory?(newDir)
          Dir.mkdir  newDir
        end

        Dir.chdir(newDir)

        # link in the branch's own manifests into this fake module
        FileUtils.ln_sf("../../manifests", "manifests")

        Dir.chdir("..")

        Dir.chdir("..")

      end

      Dir.chdir("..")

    end

  end

end