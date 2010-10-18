
require 'rumpler/application_spec_writer'

module Rumpler

  class ApplicationConverter

    attr_accessor :app_dir
    attr_accessor :output_dir
    attr_accessor :version

    def initialize(app_dir, version, output_dir)
      @app_dir = app_dir
      @version = version
      @output_dir = output_dir
    end

    def dump()
      dump_dependencies()
      dump_root_spec()
    end

    def dump_dependencies()
      puts "Dumping #{app_dir}"

      gemfile = File.join( app_dir, 'Gemfile' )

      @gemfile_converter = GemfileConverter.new( gemfile, output_dir )
      @gemfile_converter.dump()
    end

    def dump_root_spec()
      app_name = File.basename( app_dir )
      spec_file = File.join( output_dir, "#{app_name}-dependencies-#{version}.spec" )
      
      puts "Dumping #{spec_file}"
      File.open( spec_file, 'w' ) do |f|
        ApplicationSpecWriter.new( app_name, version, @gemfile_converter.definition, @gemfile_converter.ruby_config, f ).dump
      end
    end

  end

end
