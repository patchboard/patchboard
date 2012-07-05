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

rule ".json" => ".coffee" do |target|
  sh "#{$COFFEE} bin/c2json.coffee #{target.source} #{target.name}"
end

task "examples:build" => %w[
  examples/messaging/api.json
  examples/messaging/directory.json
  examples/messaging/resource_schema.json
]


