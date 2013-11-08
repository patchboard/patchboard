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

task "doc:watch" do
  require "filewatch/watch"
  watch = FileWatch::Watch.new
  watch.watch("doc/README.template.md")
  watch.subscribe do |event|
    if event == :create
      File.open("README.md", "w") do |f|
        f.puts process_doc("doc/README.template.md")
      end
    end
  end
end

task "doc:readme"  do |t|
  File.open("README.md", "w") do |f|
    f.puts process_doc("doc/README.template.md")
  end
end

def process_doc(path)
  regex = %r{^```([^\s#]+)(#L(\S+))?\s*```$}
  out = []
  base_path = File.dirname(path)
  string = File.open(path, "r") do |f|

    f.each_line do |line|

      if md = regex.match(line)
        _full, source_path, badline, line_spec = md.to_a
        if line_spec
          start, stop = line_spec.split("-").map { |s| s.to_i}
        else
          start = 1
        end

        source_path = File.expand_path("#{base_path}/#{source_path}").strip
        extension = File.extname(source_path)
        out << "```#{extension}\n\n"

        embed = []
        File.open(source_path, "r") do |source|
          source.each_line do |line|
            embed << line
          end
        end
        start -= 1
        if stop
          stop -=1
        else
          stop = embed.size - 1
        end
        out << embed.slice(start..stop).join()
        out << "```\n"
      else
        out << line
      end
    end

  end

  out.join()
end


