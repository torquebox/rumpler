%global tree_prefix  torquebox-
%global ruby_sitelib /opt/jruby/lib/ruby/site_ruby/1.8
%global gem_dir      /opt/jruby/lib/ruby/gems/1.8
%global bin_dir      /opt/jruby/bin
%global gem_name     mime-types
%global gem_instdir  %{gem_dir}/gems/%{gem_name}-%{version}
%global ruby_abi     1.8-java

Name: torquebox-rubygem-mime-types-1
Version: 1.16
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
BuildArch: noarch
Summary: Manages a MIME Content-Type database that will return the Content-Type for a given filename
URL: http://mime-types.rubyforge.org/
Source0: http://rubygems.org/gems/mime-types-1.16.gem

Provides: %{tree_prefix}rubygem(%{gem_name}) = %{version}

Requires: ruby(abi) = %{ruby_abi}


%description

MIME::Types for Ruby originally based on and synchronized with MIME::Types for Perl by Mark Overmeer, copyright 2001 - 2009. As of version 1.15, the data format for the MIME::Type list has changed and the synchronization will no longer happen.

%prep

%build

%install

rm -rf %{buildroot}
install -m 755 -d %{buildroot}%{bin_dir}
install -m 755 -d %{buildroot}%{gem_dir}
install -m 755 -d %{buildroot}%{gem_dir}/gems/mime-types-1.16/lib
gem install --local --bindir %{buildroot}%{bin_dir} --install-dir %{buildroot}%{gem_dir} --force --ignore-dependencies --platform ruby %{SOURCE0}

%clean

rm -rf %{buildroot}

%files

%defattr(-, root, root, -)
%{bin_dir}/
%{gem_dir}/gems/mime-types-1.16/
%{gem_dir}/cache/mime-types-1.16.gem
%{gem_dir}/specifications/mime-types-1.16.gemspec
%doc %{gem_dir}/doc/mime-types-1.16
%doc %{gem_instdir}/History.txt
%doc %{gem_instdir}/Install.txt
%doc %{gem_instdir}/Licence.txt
%doc %{gem_instdir}/README.txt

%changelog
