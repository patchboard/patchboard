$COFFEE = "node_modules/coffee-script/bin/coffee"

task "build:node" do
  sh "#{$COFFEE} --compile --bare --output build/ node/"
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

task "build:examples" => %w[
  examples/messaging/api.json
  examples/messaging/directory.json
  examples/messaging/resource_schema.json
  examples/messaging/interface.json
  examples/messaging/map.json
]


