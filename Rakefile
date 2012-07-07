$COFFEE = "node_modules/coffee-script/bin/coffee"

task "build:node" do
  sh "#{$COFFEE} --compile --bare --output node/ coffeescript/"
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
  examples/spire/api.json
  examples/spire/directory.json
  examples/spire/resource_schema.json
  examples/spire/interface.json
  examples/spire/map.json
]


