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

task "build" => "validate_example"

task "validate_example" do
  sh "bin/patchboard validate src/example_api.coffee"
end

task "build" => "schema.json"

file "schema.json" => "src/schema.coffee" do
  sh "coffee src/schema.coffee > schema.json"
  sh "git add schema.json"
end

desc "Run tests"
task "test" do
  sh "coffee test/server/path_matcher_test.coffee"
  sh "coffee test/server/classifier_test.coffee"
  sh "coffee test/server/service_test.coffee"
end

#def format_issue(issue, format="plain")
  #if issue.assignee
    #login = issue.assignee.login
  #else
    #login = nil
  #end
  #case format
  #when "markdown"
    #"* #{login || "<unassigned>"} - [#{issue.number}](#{issue.html_url}) - #{issue.title}"
  #when "plain"
    #"* %-16s - %-4s - %s" % [login, "##{issue.number}", issue.title]
  #else
    #raise "Unknown format for issue printing: '#{format}'"
  #end
#end

#task "transfer_issues" do
  #require "ghee"
  #ghee = Ghee.access_token("foobarbaz")
  #main = ghee.repos("automatthew", "patchboard")
  #server = ghee.repos("automatthew", "patchboard-server")
  #main.issues(:labels => "server").each do |issue|
    #options = {
      #:title => issue.title,
      #:body => issue.body,
    #}
    #if issue.assignee
      #options[:assignee] = issue.assignee.login
    #end
    #pp options
    #server.issues.create(options)
  #end

#end

