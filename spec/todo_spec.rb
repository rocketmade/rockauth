require 'spec_helper'

describe "Ruby Code" do
  spec_generated = false
  Dir["{app,lib}/**/*.rb"].each do |f|
    file_content = File.read(f)
    if file_content.match /\#\s*TODO/i
      spec_generated = true
      file_content.split("\n").each do |line|
        if line.match /\#\s*TODO/i
          pending "TODO in #{f}: #{line.gsub(/^.*\#\s*TODO/i,'')}"
        end
      end
    end
  end
  unless spec_generated
    it "has no code todos" do
    end
  end
end
