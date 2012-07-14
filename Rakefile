$COFFEE = File.expand_path("node_modules/coffee-script/bin/coffee")

task "build" => %w[
  rigger-schema.json
  build:node
  build:examples
]

task "build:node" do
  sh "#{$COFFEE} --compile --bare --output node/ coffeescript/"
end


desc "Run tests"
task "test" => %w[
  build
  test:matching
]

task "test:spire" => "build" do
  Dir.chdir("examples/spire") do
    sh "#{$COFFEE} spire_client_test.coffee"
    sh "#{$COFFEE} dispatcher_test.coffee"
  end
end

#task "test:dispatcher" => "build" do
  #sh "#{$COFFEE} test/dispatcher_test.coffee"
#end

task "test:matching" => "build" do
  sh "#{$COFFEE} test/path_matcher_test.coffee"
end

rule ".json" => ".coffee" do |target|
  sh "#{$COFFEE} bin/c2json.coffee #{target.source} #{target.name}"
end

task "build:examples" => %w[
  examples/spire/resource_schema.json
  examples/spire/interface.json
  examples/spire/map.json
]


