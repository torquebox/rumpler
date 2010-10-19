

module Rumpler

  class RootSpecsLoader

    attr_accessor :out_dir

    attr_accessor :inherent_specs
    attr_accessor :base_specs

    def initialize(root_specs_yaml, force_root, out_dir)
      @root_specs_yaml = root_specs_yaml
      @force_root      = force_root
      @cache           = {}
      @base_specs      = []
      @out_dir         = out_dir
    end

    def resolve
      roots_yaml     = YAML.load( File.read( @root_specs_yaml ) )

      @cache = load_cache( @root_specs_yaml + '.lock' )

      if ( @cache.nil? )
        inherent_specs = resolve_gemfiles( roots_yaml['inherent'] )
        base_specs     = resolve_gemfiles( roots_yaml['base'] )
        @cache         = build_cache( inherent_specs, base_specs )

        File.open( @root_specs_yaml + '.lock', 'w' ) do |f|
          f.puts YAML.dump( @cache )
        end
      end
    end

    def load_cache(file)
      return nil if @force_root
      YAML.load( file )
    end

    def build_cache(inherent_specs, base_specs)
      yaml = {}

      yaml[:inherent] = []
      yaml[:base] = []

      inherent_specs.each do |spec|
        yaml[:inherent] << {
          :name=>spec.name,
          :version=>spec.version.segments,
          :platform=>spec.platform,
        }
      end

      base_specs.each do |spec|
        yaml[:base] << {
          :name=>spec.name,
          :version=>spec.version.segments,
          :platform=>spec.platform,
        }
      end

      YAML.dump( yaml )
    end

    def resolve_gemfiles(gemfiles)
      specs = []
      gemfiles.each do |gemfile|
        Dir.chdir( File.dirname( @root_specs_yaml ) ) do
          puts "Reading from #{gemfile}" 
          ENV['BUNDLE_GEMFILE'] = gemfile
          definition = Bundler::Definition.build( gemfile, gemfile + '.lock', true )
          definition.resolve_remotely! 
          specs = specs + definition.specs.to_a
        end
      end
      specs = specs.flatten.uniq
    end

    def dump
      puts "Reading #{@root_specs_yaml}"
      resolve
      @base_specs.each do |gemspec|
        converter = GemspecConverter.new( out_dir, Config.new, gemspec )
        converter.dump
      end
    end

  end

end
