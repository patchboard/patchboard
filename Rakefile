$COFFEE = "node_modules/coffee-script/bin/coffee"

task "build" do
  sh "#{$COFFEE} --compile --bare --output build/ src/"
end

task "json" do
  # FIXME: this should really be using the json output files
  # as targets.
  FileList["*.coffee"].each do |file|
    sh "#{$COFFEE} #{file}"
  end
end


