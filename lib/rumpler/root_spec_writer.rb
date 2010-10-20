
module Rumpler

  class RootSpecWriter

    attr_accessor :name
    attr_accessor :version
    attr_accessor :definition
    attr_accessor :config

    def initialize(name, version, specs, config, out)
      @name = name
      @version = version
      @specs = specs
      @config = config
      @out = out
    end

    def tree_prefix
      @config.tree_prefix
    end

    def emit(*args)
      @out.puts( args )
    end

    def dump()
      dump_prolog
      dump_build
      dump_tail
    end
  
    def dump_prolog
      dump_global_variables
      dump_package_summary
      dump_provides
      dump_requires
  
      dump_description 
    end

    def dump_global_variables
      emit "%global tree_prefix  #{config.tree_prefix}"
      emit "%global ruby_abi     #{config.ruby_abi}"
      emit ''
    end

    def dump_package_summary
      emit "Name: #{name}"
      emit "Version: #{version}"
      emit "Release: 1%{?dist}"
      emit "Group: Development/Languages"
      emit "License: GPLv2+ or Ruby"
      emit "BuildArch: noarch"
      emit "Summary: Root dependencies for #{name}"
      emit ''
    end

    def dump_provides
    end

    def dump_requires
      emit "Requires: ruby(abi) = %{ruby_abi}"
      emit ""
      @specs.each do |spec|
        emit "Requires: %{tree_prefix}rubygem(#{spec.name}) = #{spec.version}"
      end
      emit ''
    end

    def dump_description
      emit "%description"
      emit "Dependency aggregator for #{name}"
      emit ''
    end

    def dump_build
      dump_prep
      dump_build
      dump_install
      dump_clean
    end

    def dump_prep
      emit "%prep"
      emit ''
    end

    def dump_build
      emit "%build"
      emit ''
    end
  
    def dump_install
      emit "%install"
      emit ''
    end

    def dump_clean
      emit "%clean"
      emit ''
    end
  
    def dump_tail
      dump_files
      dump_changelog
    end

    def dump_files
      emit "%files"
      emit ''
    end

    def dump_changelog
      emit "%changelog"
      emit ''
    end

  end

end
