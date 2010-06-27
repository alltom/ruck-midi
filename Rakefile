require "rubygems"
require "rake"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "ruck-midi"
    gem.email = "tom@alltom.com"
    gem.homepage = "http://github.com/alltom/ruck-midi"
    gem.authors = ["Tom Lieber"]
    gem.summary = %Q{real-time and offline ruck shredulers for MIDI (thanks midiator and midilib)}
    gem.description = <<-EOF
      Real-time and offline ruck shredulers for MIDI using midiator and midilib.
    EOF
    gem.has_rdoc = false
    gem.add_dependency "ruck", ">= 0"
    gem.add_dependency "midiator", ">= 0"
    gem.add_dependency "midilib", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
