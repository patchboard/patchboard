require "starter/tasks/npm"

def subprojects
  FileList["{server,client}/*/Rakefile"].map {|file| File.dirname(file)}
end

def subtask(*args)
  name = args.first
  desc "Run #{name} for all subprojects"
  task(*args) do
    subprojects.each do |dir|
      Dir.chdir(dir) do
        unless `rake -D #{name}`.empty?
          puts "Running in #{dir}"
          sh "rake #{name}"
        end
      end
    end
  end
  yield if block_given?
end

subtask "test"


task "build" => "schema.json"

file "schema.json" => "coffee/schema.coffee" do
  sh "coffee coffee/schema.coffee > schema.json"
  sh "git add schema.json"
end
