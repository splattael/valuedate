# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{valuedate}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Suschlik"]
  s.date = %q{2010-01-30}
  s.email = %q{peter-valuedate@suschlik.de}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/valuedate.rb",
     "test.watchr",
     "test/helper.rb",
     "test/test_valuedate.rb",
     "valuedate.gemspec"
  ]
  s.homepage = %q{http://github.com/splattael/valuedate}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Validates values.}
  s.test_files = [
    "test/test_valuedate.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<riot>, [">= 0.10.11"])
      s.add_development_dependency(%q<riot_notifier>, [">= 0"])
    else
      s.add_dependency(%q<riot>, [">= 0.10.11"])
      s.add_dependency(%q<riot_notifier>, [">= 0"])
    end
  else
    s.add_dependency(%q<riot>, [">= 0.10.11"])
    s.add_dependency(%q<riot_notifier>, [">= 0"])
  end
end
