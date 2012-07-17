$COFFEE = File.expand_path("node_modules/.bin/coffee")

task "build" => %w[
  coffeescript
  build:examples
]

task "coffeescript" do
  sh "#{$COFFEE} --compile --bare --output build/ src/"
end


desc "Run tests"
task "test" => %w[
  build
  test:spire
  test:service
]

task "test:spire" => "build" do
  Dir.chdir("examples/spire") do
    sh "#{$COFFEE} spire_client_test.coffee"
    sh "#{$COFFEE} classifier_test.coffee"
  end
end

task "test:matching" => "build" do
  sh "#{$COFFEE} test/path_matcher_test.coffee"
end

task "test:service" => "build" do
  sh "#{$COFFEE} test/path_matcher_test.coffee"
  sh "#{$COFFEE} test/schema_manager_test.coffee"
end

rule ".json" => ".coffee" do |target|
  sh "#{$COFFEE} bin/c2json.coffee #{target.source} #{target.name}"
end

task "build:examples" => %w[
  examples/spire/resource_schema.json
  examples/spire/interface.json
  examples/spire/map.json
]


