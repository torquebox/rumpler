
require 'bundler'
require 'fileutils'

module Rumpler
  class GemfileConverter
  
    attr_accessor :gemfile
    attr_accessor :ruby_config
    attr_accessor :definition

    attr_accessor :output_dir
  
    def initialize(gemfile, output_dir, ruby_config=Config.new, exclusions=[])
      @gemfile = gemfile
      @ruby_config = ruby_config
      @output_dir = output_dir
      @resolved = false
      @exclusions = exclusions
    end
  
    def resolve
      return if @resolved
      resolve!
      @resolved = true
    end

    def resolve!()
      ENV['BUNDLE_GEMFILE'] = gemfile
      @definition = Bundler::Definition.build( @gemfile, @gemfile + '.lock', true )
      @definition.dependencies.reject!{|dep|  should_exclude_dep?( dep.name ) }
      @definition.resolve_remotely!
    end

    def should_exclude_dep?(name)
      [
        %r(^org.torquebox),
        %r(^ruby-debug),
      ].any? do |regexp|
        regexp =~ name
      end
    end

    def should_exclude_spec?(spec)
      compare = { 
        :name=>spec.name,
        :platform=>spec.platform,
        :version=>[spec.version.segments[0], spec.version.segments[1]],
      }
      @exclusions.each do |e|
        if ( ( e[:name] == spec.name ) && 
             ( e[:platform] == spec.platform ) && 
             ( e[:version][0] == spec.version.segments[0] ) &&
             ( e[:version][1] == spec.version.segments[1] ) )
          return true
        end
      end
      false
    end
  
    def dump()
      puts "Reading #{gemfile}"
      resolve()
      dump_specs()
    end

    def dump_specs()
      @definition.specs.each do |spec|
        dump_spec(spec) unless should_exclude_spec?( spec )
      end
    end
  
    def dump_spec(gemspec)
      converter = GemspecConverter.new( output_dir, ruby_config, gemspec )
      converter.dump
    end
  
  end
end
