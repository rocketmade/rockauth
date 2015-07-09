require 'spec_helper'

describe "Ruby Code" do
  spec_generated = false
  Dir["{app,lib}/**/*.rb"].each do |f|
    if File.read(f).match /\#\s*TODO/i
      spec_generated = true
      pending "#{f} has todos"
    end
  end
  unless spec_generated
    it "has no code todos" do
    end
  end
end
