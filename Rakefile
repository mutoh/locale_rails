$:.unshift "./lib"

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

require 'locale_rails/version'

#desc "Default Task"
#task :default => [ :test ]

PKG_NAME = "locale_rails"
PKG_VERSION = Locale::LOCALE_RAILS_VERSION

# Run the unit tests
task :test do 
  Dir.glob("test/test_*.rb").each do |v|
    ruby "-Ilib #{v}"
  end
end

Rake::RDocTask.new { |rdoc|
  begin
    allison = `allison --path`.chop
  rescue Exception
    allison = ""
  end
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Ruby-Locale for Ruby on Rails"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README', 'ChangeLog')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.template = allison if allison.size > 0
}

desc "Create gem and tar.gz"
spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = 'Ruby-Locale for Ruby on Rails is the pure ruby library which provides basic functions for localization based on Ruby-Locale.'
  s.author = 'Masao Mutoh'
  s.email = 'mutomasa at gmail.com'
  s.homepage = 'http://locale.rubyforge.org/'
  s.rubyforge_project = "locale"
  s.files = FileList['**/*'].to_a.select{|v| v !~ /pkg|CVS/}
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.add_dependency('locale', '>= 0.9.0')
  s.has_rdoc = true
  s.description = <<-EOF
    Ruby-Locale for Ruby on Rails is the pure ruby library which provides basic functions for localization.
  EOF
end

Rake::PackageTask.new("ruby-locale_rails", PKG_VERSION) do |o|
  o.package_files = FileList['**/*'].to_a.select{|v| v !~ /pkg|git/}
  o.need_tar_gz = true
  o.need_zip = false
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar_gz = false
  p.need_zip = false
end

desc "Publish the release files to RubyForge."
task :release => [ :package ] do
  require 'rubyforge'

  rubyforge = RubyForge.new
  rubyforge.login
  rubyforge.add_release("locale", "locale",
                        "Ruby-Locale for Ruby on Rails #{PKG_VERSION}",
                        "pkg/#{PKG_NAME}-#{PKG_VERSION}.gem")
end
