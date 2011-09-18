require 'fileutils'
require 'erb'
require 'pathname'

namespace :cart do

  # Time Constants 
  date          = Time.new
  STAMP         = date.strftime("%Y%m%d")
  YY            = date.year
  MM            = date.month
  DD            = date.day
  BUILD_DATE    = date.strftime("%Y-%m-%dT%H:%M:%SZ")
  
  # Arguments to be passed to Packagemaker binary
  PM_EXTRA_ARGS  = '--verbose --no-recommend --no-relocate'
  
  # Path to binaries
  TAR           = '/usr/bin/tar'
  CP            = '/bin/cp'
  INSTALL       = '/usr/bin/install'
  DITTO         = '/usr/bin/ditto'
  PACKAGEMAKER  = '/Developer/usr/bin/packagemaker'
  
  # Plist options
  @plist_flavor      = 'plist'
  @package_plist     = '.package.plist'
  @package_target_os = '10.4'
  @plist_template    = 'prototype.plist'
  @title             = 'CHANGE_ME'
  @reverse_domain    = 'com.replaceme'
  @pm_restart        = 'None'
  
  #Prototype.plist options for ERB template
  @output_file       = 'prototype.plist'
  @template_file     = "#{Pathname.pwd.parent}/cart.plist.erb"

  # Set @package_version in your Rakefile if you don't want version set to
  # today's date
  @package_version       = "#{STAMP}"
  @package_major_version = "#{YY}"
  @package_minor_version = "#{MM}#{DD}"
  
  # DMG-specific options
  @dmg_format_code   = 'UDZO'
  @zlib_level        = '9'
  @dmg_format_option = "-imagekey zlib-level=#{@zlib_level}"
  @dmg_format        = "#{@dmg_format_code} #{@dmg_format_option}"
  

  def announce(msg='')
      STDERR.puts "================"
      STDERR.puts msg
      STDERR.puts "================"
  end

  def safe_system *args
      raise RuntimeError, "Failed: #{args.join(' ')}" unless system *args
  end
  
  def get_template
    File.read(@template_file)
  end
  
  def output_file
    File.open("#{@scratch}/#{@output_file}", "w+") do |f|
      f.write(ERB.new(get_template).result())
    end
  end

  def build_package
    @package_file  = "#{@package_name}.pkg"
    @zip_name      = "#{@package_file}.zip"
    safe_system("sudo #{PACKAGEMAKER} --root #{@working_tree['WORK_D']} \
    		--id #{@package_id} \
    		--filter DS_Store \
    		--target #{@package_target_os} \
    		--title #{@title} \
    		--info #{@scratch}/prototype.plist \
    		--scripts #{@working_tree['SCRIPT_D']} \
    		--resources #{@working_tree['RESOURCE_D']} \
    		--version #{@package_version} \
    		#{PM_EXTRA_ARGS} --out #{@working_tree['PAYLOAD_D']}/#{@package_file}")
		safe_system("cp -R #{@scratch}/payload/#{@package_file} .")
		announce("Your package #{@package_file} has been built!")
  end
  
  def build_dmg
    @dmg_name      = "#{@package_name}.dmg"
    safe_system("sudo hdiutil create -volname #{@package_name} \
  		-srcfolder #{@working_tree['PAYLOAD_D']} \
  		-uid 99 \
  		-gid 99 \
  		-ov \
  		-format #{@dmg_format} \
  		#{@dmg_name}")
  end
	
	def make_directory_tree
	  @package_id    = "#{@reverse_domain}.#{@title}"
	  @package_name  = "#{@title}-#{@package_version}"
    @cart_tmp      = '/tmp/cart'
    @scratch       = "#{@cart_tmp}/#{@package_name}"
    @working_tree  = {     
       'SCRIPT_D'   => "#{@scratch}/scripts",
       'RESOURCE_D' => "#{@scratch}/resources",
       'WORK_D'     => "#{@scratch}/root",
       'PAYLOAD_D'  => "#{@scratch}/payload",
    }
    puts "Cleaning Tree: #{@cart_tmp}"
    FileUtils.rm_rf(@cart_tmp)
    @working_tree.each do |key,val|
      puts "Creating: #{val}"
      FileUtils.mkdir_p(val)
    end
  end
end