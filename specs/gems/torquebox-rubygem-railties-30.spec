%global tree_prefix  torquebox-
%global ruby_sitelib /opt/jruby/lib/ruby/site_ruby/1.8
%global gem_dir      /opt/jruby/lib/ruby/gems/1.8
%global bin_dir      /opt/jruby/bin
%global gem_name     railties
%global gem_instdir  %{gem_dir}/gems/%{gem_name}-%{version}
%global ruby_abi     1.8-java

Name: torquebox-rubygem-railties-30
Version: 3.0.0
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
BuildArch: noarch
Summary: Tools for creating, working with, and running Rails applications
URL: http://www.rubyonrails.org
Source0: http://rubygems.org/gems/railties-3.0.0.gem

Provides: %{tree_prefix}rubygem(%{gem_name}) = %{version}

Requires: ruby(abi) = %{ruby_abi}

Requires: %{tree_prefix}rubygem(rake) >= 0.8.4
Requires: %{tree_prefix}rubygem(thor) => 0.14.0
Requires: %{tree_prefix}rubygem(thor) < 0.15
Requires: %{tree_prefix}rubygem(activesupport) = 3.0.0
Requires: %{tree_prefix}rubygem(actionpack) = 3.0.0

%description

Rails internals: application bootup, plugins, generators, and rake tasks.

%prep

%build

%install

rm -rf %{buildroot}
install -m 755 -d %{buildroot}%{bin_dir}
install -m 755 -d %{buildroot}%{gem_dir}
install -m 755 -d %{buildroot}%{gem_dir}/gems/railties-3.0.0/lib
gem install --local --bindir %{buildroot}%{bin_dir} --install-dir %{buildroot}%{gem_dir} --force --ignore-dependencies --platform ruby %{SOURCE0}

%clean

rm -rf %{buildroot}

%files

%defattr(-, root, root, -)
%{bin_dir}/
%{gem_dir}/gems/railties-3.0.0/
%{gem_dir}/cache/railties-3.0.0.gem
%{gem_dir}/specifications/railties-3.0.0.gemspec
%doc %{gem_dir}/doc/railties-3.0.0

%changelog

