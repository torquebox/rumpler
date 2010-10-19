

module Rumpler

  class RootSpecsLoader

    attr_accessor :out_dir

    attr_accessor :inherent_specs
    attr_accessor :base_specs

    def initialize(root_specs_yaml, force_root, out_dir=nil)
      @root_specs_yaml = root_specs_yaml
      @force_root      = force_root
      @cache           = {}
      @base_specs      = []
      @out_dir         = out_dir
      @resolved        = false
    end

    def resolve
      resolve! unless @resolved
      @resolved = true
    end

    def resolve!
      @cache = load_cache( @root_specs_yaml + '.lock' )

      if ( @cache.nil? )
        roots_yaml     = YAML.load( File.read( @root_specs_yaml ) )
        inherent_specs = resolve_gemfiles( roots_yaml['inherent'] )
        base_specs     = resolve_gemfiles( roots_yaml['base'] )
        @cache         = build_cache( inherent_specs, base_specs )

        puts "Writing cache #{@root_specs_yaml}.lock"
        File.open( @root_specs_yaml + '.lock', 'w' ) do |f|
          f.write YAML.dump( @cache )
        end
      end
    end

    def load_cache(file)
      return nil if @force_root
      puts "Reading #{file}"
      YAML.load( File.read( file ) )
    end

    def build_cache(inherent_specs, base_specs)
      cache = {}

      cache[:inherent] = []
      cache[:base] = []

      inherent_specs.each do |spec|
        cache[:inherent] << {
          :name=>spec.name,
          :version=>spec.version.segments,
          :platform=>spec.platform,
        }
      end

      base_specs.each do |spec|
        source_uri = "http://rubygems.org/"
        ( source_uri = spec.source_uri.to_s ) if ( spec.respond_to?( :source_uri ) )
 
        cache[:base] << {
          :name=>spec.name,
          :version=>spec.version.segments,
          :gem_version=>spec.version,
          :platform=>spec.platform,
          :source=>source_uri,
        }
      end
      
      cache
    end

    def resolve_gemfiles(gemfiles)
      specs = []
      gemfiles.each do |gemfile|
        Dir.chdir( File.dirname( @root_specs_yaml ) ) do
          puts "Reading #{gemfile}" 
          ENV['BUNDLE_GEMFILE'] = gemfile
          definition = Bundler::Definition.build( gemfile, gemfile + '.lock', true )
          definition.resolve_remotely! 
          specs = specs + definition.specs.to_a
        end
      end
      specs = specs.flatten.uniq
    end

    def exclusions
      resolve
      (@cache[:inherent] + @cache[:base]).uniq
    end

    def dump
      puts "Reading #{@root_specs_yaml}"
      resolve
      @cache[:base].each do |details|
        spec_spec = [ details[:name], 
                      details[:gem_version].to_s,
                      details[:platform] ] 
        gemspec = Gem::SpecFetcher.fetcher.fetch_spec( spec_spec, URI.parse( details[:source] ) )
        converter = GemspecConverter.new( out_dir, Config.new, gemspec )
        converter.dump
      end
    end

  end

end
