
require 'bundler'
require 'fileutils'

module Rumpler
  class GemfileConverter
  
    attr_accessor :gemfile
    attr_accessor :ruby_config
    attr_accessor :definition

    attr_accessor :output_dir

    attr_accessor :inhibit_exclusions
  
    def initialize(gemfile, output_dir, ruby_config=Config.new)
      @gemfile = gemfile
      @ruby_config = ruby_config
      @output_dir = output_dir
      @resolved = false
      @inhibit_exclusions = false
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
      false
    end

    def should_exclude_spec?(name, version)
     false
    end
  
    def dump()
      puts "Dumping #{gemfile}"
      resolve()
      dump_specs()
    end

    def dump_specs()
      @definition.specs.each do |spec|
        dump_spec(spec) unless should_exclude_spec?( spec.name, spec.version )
      end
    end
  
    def dump_spec(gemspec)
      converter = GemspecConverter.new( output_dir, ruby_config, gemspec )
      converter.dump
    end
  
  end
end
