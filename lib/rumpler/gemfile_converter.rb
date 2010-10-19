
require 'bundler'
require 'fileutils'

module Rumpler
  class GemfileConverter
  
    DEP_EXCLUDES = [
      %r(^org.torquebox),
      %r(^rails$),
      %r(^rack$),
      %r(^bundler$),
    ]

    SPEC_EXCLUDES = {
      'columnize'=>'03',
      'rake'=>'08',
      'rspec'=>'13',
      'ruby-debug'=>'010',
      'ruby-debug-base'=>'010',
      'sources'=>'00',
      'bundler'=>'*',
      'rack'=>'*',
      'bouncy-castle'=>'*',
      'jruby-openssl'=>'*',
    }
    SPEC_EXCLUDES_REGEXPS = [
      /^activesupport/,
      /^actionpack/,
      /^actionmailer/,
      /^activerecord/,
      /^activemodel/,
      /^activeresource/,
      /^railties/,
      /^rails/,
      /^activerecord-jdbc/,
      /^jdbc-/,
    ]

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
      return false if @inhibit_exclusions
      DEP_EXCLUDES.each do |regexp|
        return true if ( regexp =~ name )
      end
      false
    end

    def should_exclude_spec?(name, version)
      return true if name == 'rake'
      return false if @inhibit_exclusions
      exclude_versions = SPEC_EXCLUDES[ name ]
      if ( ! exclude_versions.nil? )
        test = "#{version.segments[0]}#{version.segments[1]}"
        if ( ( exclude_versions.to_s == '*' ) || [ exclude_versions ].flatten.include?( test ) )
          return true
        end
      end

     SPEC_EXCLUDES_REGEXPS.each do |r|
       return true if ( r =~ name )
     end

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
