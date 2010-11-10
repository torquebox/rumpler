
require 'rumpler/application_spec_writer'

module Rumpler

  class ApplicationConverter

    attr_accessor :app_dir
    attr_accessor :output_dir
    attr_accessor :version
    attr_accessor :exclusions

    def initialize(app_dir, version, output_dir, config=Config.new, exclusions=[])
      @app_dir = app_dir
      @config = config
      @version = version
      @output_dir = output_dir
      @exclusions = exclusions
    end

    def dump()
      dump_dependencies()
      dump_root_spec()
    end

    def dump_dependencies()
      puts "Analyzing #{app_dir}"

      gemfile = File.join( app_dir, 'Gemfile' )

      @gemfile_converter = GemfileConverter.new( gemfile, output_dir, @config, exclusions )
      @gemfile_converter.dump()
    end

    def dump_root_spec()
      app_name = File.basename( app_dir )
      spec_file = File.join( output_dir, "#{app_name}-dependencies-#{version}.spec" )
      
      puts "Dumping #{spec_file}"
      File.open( spec_file, 'w' ) do |f|
        ApplicationSpecWriter.new( app_name, version, @gemfile_converter.definition, @config, f ).dump
      end
    end

  end

end
