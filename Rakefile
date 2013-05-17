require "starter/tasks/npm"
require "starter/tasks/git"
require "starter/tasks/github"

#def subprojects
  #FileList["{client,server}/*/Rakefile"].map {|file| File.dirname(file)}
#end

#def subtask(*args)
  #name = args.first
  #desc "Run #{name} for all subprojects"
  #task(*args) do
    #subprojects.each do |dir|
      #Dir.chdir(dir) do
        #unless `rake -D #{name}`.empty?
          #puts "Running in #{dir}"
          #sh "rake #{name}"
        #end
      #end
    #end
  #end
  #yield if block_given?
#end

#subtask "test"


task "build" => "validate_example"

task "validate_example" do
  sh "bin/patchboard validate coffee/example_api.coffee"
end

task "build" => "schema.json"

file "schema.json" => "coffee/schema.coffee" do
  sh "coffee coffee/schema.coffee > schema.json"
  sh "git add schema.json"
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

