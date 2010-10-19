

module Gem
  class Requirement
    def rpm_version_transform(version)
      if version == "> 0.0.0"
        version = ""
      elsif version =~ /^~> (.+)$/
        next_version = Gem::Version.create($1).bump.to_s

        version = ["=> #$1", "< #{next_version}"]
      end
      version
    end

    def to_rpm
      result = as_list
      return result.map { |version| rpm_version_transform(version) }.flatten
    end

  end
end


module Rumpler
  class GemspecConverter
  
    attr_accessor :output_dir
    attr_accessor :gemspec
    attr_accessor :ruby_config
  
    def initialize(output_dir, ruby_config, gemspec)
      @output_dir  = output_dir
      @ruby_config = ruby_config
      @gemspec     = gemspec
      @out         = nil
    end
    
    def emit(*args)
      #puts args
      @out.puts( args )
    end
  
    def base_gem_package_name()
      return "#{gem_name}-#{version}-#{platform}" if ( platform != 'ruby' )
      "#{gem_name}-#{version}"
    end
  
    def gem_url()
      if ( gemspec.platform != 'ruby' )
        "http://rubygems.org/gems/#{gem_name}-#{version}-#{gemspec.platform}.gem"
      else
        "http://rubygems.org/gems/#{gem_name}-#{version}.gem"
      end
    end
  
    def gem_name()
      gemspec.name
    end
  
    def description()
      @gemspec.description.to_s.chomp
    end
  
    def major_minor()
      major = gemspec.version.segments[0]
      minor = gemspec.version.segments[1]
      "#{major}#{minor}"
    end

    def rpm_name()
      major = gemspec.version.segments[0]
      minor = gemspec.version.segments[1]
      "#{ruby_config.tree_prefix}rubygem-#{gemspec.name}-#{major}#{minor}"
    end
  
    def rpm_arch
      "noarch"
    end
  
    def version()
      @gemspec.version
    end
  
    def summary()
      @gemspec.summary.gsub(/\.$/, '' )
    end
  
    def platform()
      @gemspec.platform
    end
  
    def dump()
      rpmspec_path = File.join( output_dir, rpm_name + '.spec' )
      puts "Dumping #{rpmspec_path}"
      FileUtils.mkdir_p( File.dirname( rpmspec_path ) )
      File.open( rpmspec_path, 'w' ) do |file|
        @out = file
        dump_all()
      end
    end
  
    def dump_all
      dump_prolog

      dump_prep
      dump_build
      dump_install
      dump_clean
  
      dump_files
      dump_changelog
    end

    def dump_prolog
      dump_global_variables
      dump_package_summary
      dump_provides
      dump_requires
  
      dump_description 
  
    end
  
    def dump_global_variables
      emit "%global tree_prefix  #{ruby_config.tree_prefix}"
      emit "%global ruby_sitelib #{ruby_config.ruby_sitelib}"
      emit "%global gem_dir      #{ruby_config.gem_dir}"
      emit "%global bin_dir      #{ruby_config.bin_dir}"
      emit "%global gem_name     #{gem_name}"
      emit "%global gem_instdir  %{gem_dir}/gems/%{gem_name}-%{version}"
      emit "%global ruby_abi     #{ruby_config.ruby_abi}"
      emit ''
    end
  
    def dump_package_summary
      emit "Name: #{rpm_name}"
      emit "Version: #{version}"
      emit "Release: 1%{?dist}"
      emit "Group: Development/Languages"
      emit "License: GPLv2+ or Ruby"
      emit "BuildArch: #{rpm_arch}"
      emit "Summary: #{summary}"
  
      if (gemspec.homepage)
        emit "URL: #{gemspec.homepage}"
      end
  
      emit "Source0: #{gem_url}"
      emit ""
    end
  
    def dump_provides
      emit "Provides: %{tree_prefix}rubygem(%{gem_name}) = %{version}"
      emit ""
    end
  
    def dump_requires
      emit "Requires: ruby(abi) = %{ruby_abi}"
      emit ""
      gemspec.runtime_dependencies.each do |dep|
        for req in dep.requirement.to_rpm 
          emit "Requires: %{tree_prefix}rubygem(#{dep.name}) #{req}"
        end
      end
      emit ""
    end
  
    def dump_description
      emit "%description"
      emit ""
      emit description
      emit ""
    end
  
  
    def dump_prep
      emit "%prep"
      emit ""
    end
  
    def dump_build
      emit "%build"
      emit ""
    end
  
    def dump_install
      emit "%install"
      emit ""
      emit "rm -rf %{buildroot}"
      emit "install -m 755 -d %{buildroot}%{bin_dir}"
      emit "install -m 755 -d %{buildroot}%{gem_dir}"
      emit "install -m 755 -d %{buildroot}%{gem_dir}/gems/#{base_gem_package_name}/lib"
      emit "gem install --local --bindir %{buildroot}%{bin_dir} --install-dir %{buildroot}%{gem_dir} --force --ignore-dependencies --platform #{platform} %{SOURCE0}"
      emit ""
    end
  
    def dump_clean
      emit "%clean"
      emit ""
      emit "rm -rf %{buildroot}"
      emit ""
    end
  
    def dump_files
      emit "%files"
      emit ""
      emit "%defattr(-, root, root, -)"
      emit "%{bin_dir}/"
      emit "%{gem_dir}/gems/#{base_gem_package_name}/"
      emit "%{gem_dir}/cache/#{base_gem_package_name}.gem"
      emit "%{gem_dir}/specifications/#{base_gem_package_name}.gemspec"
      if gemspec.has_rdoc 
        emit "%doc %{gem_dir}/doc/#{base_gem_package_name}"
      end
      for f in gemspec.extra_rdoc_files
        emit "%doc %{gem_instdir}/#{f}"
      end
      emit ""
    end
  
    def dump_changelog
      emit "%changelog"
      emit ""
    end
  
  end

end
  
      
