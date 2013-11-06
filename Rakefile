require "starter/tasks/npm"
require "starter/tasks/git"
require "starter/tasks/github"


task "link" do
  sh "npm link ../patchboard-js"
end

task "unlink" do
  sh "npm rm patchboard-js"
end

task "install_local" do
  sh "npm install ../patchboard-js"
end

task "build" =>  %w[ validate_example schema.json ]

task "validate_example" do
  sh "bin/patchboard validate src/example_api.coffee"
end

file "schema.json" => "src/schema.coffee" do
  sh "coffee src/schema.coffee > schema.json"
  sh "git add schema.json"
end

desc "Run tests"
task "test" do
  sh "coffee test/path_matcher_test.coffee"
  sh "coffee test/classifier_test.coffee"
  sh "coffee test/service_test.coffee"
end



