
module Rumpler

  class RootSpecsLoader

    attr_accessor :out_dir

    attr_accessor :inherent_specs
    attr_accessor :base_specs

    def initialize(root_specs_yaml, force_root, out_dir)
      @root_specs_yaml = root_specs_yaml
      @force_root      = force_root
      @inherent_specs  = []
      @base_specs      = []
      @out_dir         = out_dir
    end

    def resolve()
      resolve! unless resolve_from_cache
    end

    def resolve!
      roots_yaml = YAML.load( File.read( @root_specs_yaml ) )
      resolve_inherent( roots_yaml['inherent'] )
      resolve_base( roots_yaml['base'] )
      yaml = { 'inherent'=>@inherent_specs, 'base'=>@base_specs }
      File.open( @root_specs_yaml + '.lock', 'w' ) do |f|
        f.puts( YAML.dump( yaml ) )
      end
    end

    def resolve_from_cache
      return false if @force_root
      if ( File.exists?( @root_specs_yaml + '.lock' ) )
        yaml = YAML.load( File.read( @root_specs_yaml + '.lock' ) )
        @inherent_specs = yaml['inherent']
        @base_specs = yaml['base']
	return true
      end
      false
    end

    def resolve_inherent(gemfiles)
      gemfiles.each do |gemfile|
        Dir.chdir( File.dirname( @root_specs_yaml ) ) do
          puts "Reading from #{gemfile}" 
          ENV['BUNDLE_GEMFILE'] = gemfile
          definition = Bundler::Definition.build( gemfile, gemfile + '.lock', true )
          definition.resolve_remotely! 
          definition.specs.each do |e|
            @inherent_specs << e
          end
        end
      end
      @inherent_specs = @inherent_specs.flatten.uniq
    end

    def resolve_base(gemfiles)
      gemfiles.each do |gemfile|
        Dir.chdir( File.dirname( @root_specs_yaml ) ) do
          puts "Reading from #{gemfile}"
          ENV['BUNDLE_GEMFILE'] = gemfile
          definition = Bundler::Definition.build( gemfile, gemfile + '.lock', true )
          definition.resolve_remotely!
          definition.specs.each do |e|
            @base_specs << e
          end
          definition.lock( "#{gemfile}.lock" ) 
        end
      end
      @base_specs = @base_specs.flatten.uniq - @inherent_specs
    end

    def dump
      puts "Dumping #{@root_specs_yaml}"
      resolve
      @base_specs.each do |gemspec|
        converter = GemspecConverter.new( out_dir, Config.new, gemspec )
        converter.dump
      end
    end

  end

end
