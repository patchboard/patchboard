$COFFEE = File.expand_path("node_modules/.bin/coffee")

$BROWSERIFY = File.expand_path("node_modules/.bin/browserify")
$BROWSERIFY_OPTIONS = "-i zlib --prelude false -o browser/rigger.js"


desc "Build and compile EVERYTHING"
task "build" => %w[
  coffeescript
  browser/rigger.min.js
  build:examples
]

task "build:browser" => %w[browser/rigger.min.js]

file "browser/rigger.js" => "lib/client.js" do |target|
  sh "#{$BROWSERIFY} lib/client.js " +
    "-i zlib --prelude false -o browser/rigger.js"
end

file "browser/rigger.min.js" => "browser/rigger.js" do |target|
  sh "node_modules/.bin/uglifyjs -o #{target.name} browser/rigger.js"
end


# This rigmarole is to allow the coffeescript compilation to depend on whether
# the source files have changed.
CoffeeFiles = FileList["src/**/*.coffee"]
JSFiles = CoffeeFiles.map {|path| path.sub(%r{^src/}, "lib/").sub(%r{\.coffee$}, ".js")}

desc "Compile coffeescript files in src/ to javascript in lib/"
task "coffeescript" => JSFiles

rule(".js" => lambda { |tn|
  tn.sub(/\.js$/, '.coffee').sub(/^lib\//, 'src/')
}) do |target|
  mkdir_p(File.dirname(target.name))
  sh "#{$COFFEE} --compile --bare --print #{target.source} > #{target.name}"
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


