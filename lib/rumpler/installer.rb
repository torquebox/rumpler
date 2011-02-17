require "rubygems"
require "rubygems/installer"
require "rubygems/doc_manager"
require "rubygems/source_index"

module Gem
  class Requirement
    def hash
      requirements.to_s.hash
    end
  end
end


Gem::Installer.new( "%{SOURCE0}", {
  :force=>true,
  :env_shebang=>true,
  :ignore_dependencies=>true,
  :install_dir=>"%{buildroot}%{gem_dir}",
  :bin_dir=>"%{buildroot}%{bin_dir}",
  :wrappers=>true,
} ).install


spec = Gem::SourceIndex.load_specification( "%{buildroot}%{gem_dir}/specifications/%{gem_package_name}.gemspec" )
doc_manager = Gem::DocManager.new( spec )
doc_manager.generate_rdoc()
