

module Rumpler
  class Config
    attr_accessor :ruby_sitelib
    attr_accessor :gem_dir
    attr_accessor :bin_dir
    attr_accessor :ruby_abi
  
    attr_accessor :tree_prefix
  
    def initialize(config_file = nil)
      @ruby_sitelib = '/opt/jruby/lib/ruby/site_ruby/1.8'
      @gem_dir = '/opt/jruby/lib/ruby/gems/1.8'
      @bin_dir = '/opt/jruby/bin'
      @ruby_abi    = '1.8-java'
      @tree_prefix = 'torquebox-'
      
      
      unless config_file.nil?
        if File.exists?(config_file)          
          f = YAML.load_file(config_file)
          @ruby_sitelib    = f['ruby_sitelib'] unless f['ruby_sitelib'].nil?
          @gem_dir         = f['gem_dir'] unless f['gem_dir'].nil?
          @bin_dir         = f['bin_dir'] unless f['bin_dir'].nil?
          @ruby_abi        = f['ruby_abi'] unless f['ruby_abi'].nil?
          @tree_prefix     = f['tree_prefix'] unless f['tree_prefix'].nil?
        else
          puts "Can't find config file: #{config_file}. Using defaults."
        end
      end
    end
  end
end
