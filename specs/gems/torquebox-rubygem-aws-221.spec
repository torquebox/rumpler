%global tree_prefix  torquebox-
%global ruby_sitelib /opt/jruby/lib/ruby/site_ruby/1.8
%global gem_dir      /opt/jruby/lib/ruby/gems/1.8
%global bin_dir      /opt/jruby/bin
%global gem_name     aws
%global gem_instdir  %{gem_dir}/gems/%{gem_name}-%{version}
%global ruby_abi     1.8-java

Name: torquebox-rubygem-aws-221
Version: 2.3.21
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
BuildArch: noarch
Summary: AWS Ruby Library for interfacing with Amazon Web Services
URL: http://github.com/appoxy/aws/
Source0: http://rubygems.org/gems/aws-2.3.21.gem

Provides: %{tree_prefix}rubygem(%{gem_name}) = %{version}

Requires: ruby(abi) = %{ruby_abi}

Requires: %{tree_prefix}rubygem(uuidtools) >= 0
Requires: %{tree_prefix}rubygem(http_connection) >= 0
Requires: %{tree_prefix}rubygem(xml-simple) >= 0

%description

AWS Ruby Library for interfacing with Amazon Web Services.

%prep

%build

%install

rm -rf %{buildroot}
install -m 755 -d %{buildroot}%{bin_dir}
install -m 755 -d %{buildroot}%{gem_dir}
install -m 755 -d %{buildroot}%{gem_dir}/gems/aws-2.3.21/lib
gem install --local --bindir %{buildroot}%{bin_dir} --install-dir %{buildroot}%{gem_dir} --force --ignore-dependencies --platform ruby %{SOURCE0}

%clean

rm -rf %{buildroot}

%files

%defattr(-, root, root, -)
%{bin_dir}/
%{gem_dir}/gems/aws-2.3.21/
%{gem_dir}/cache/aws-2.3.21.gem
%{gem_dir}/specifications/aws-2.3.21.gemspec
%doc %{gem_dir}/doc/aws-2.3.21

%changelog

