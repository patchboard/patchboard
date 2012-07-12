$COFFEE = "node_modules/coffee-script/bin/coffee"

task "build" => %w[
  rigger-schema.json
  build:node
  build:examples
]

task "build:node" do
  sh "#{$COFFEE} --compile --bare --output node/ coffeescript/"
end


desc "Run tests"
task "test" => "build" do
  sh "#{$COFFEE} test.coffee"
end

rule ".json" => ".coffee" do |target|
  sh "#{$COFFEE} bin/c2json.coffee #{target.source} #{target.name}"
end

task "build:examples" => %w[
  examples/spire/resource_schema.json
  examples/spire/interface.json
]


