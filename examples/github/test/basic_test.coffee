GitHubClient = require("../client")
Testify = require("testify")

fs = require("fs")
# read login:password from a file
string = fs.readFileSync("auth")
string = string.slice(0, string.length-1)
basic_auth = new Buffer(string).toString("base64")


client = new GitHubClient(basic_auth)

user = client.resources.user(user: "dyoder")
repos = client.resources.repositories(owner: "dyoder")

console.log repos

repos.list
  on:
    response: (response) ->
      console.log "unexpected response status"
      console.log response.body
    200: (response, data) ->
      console.log data.length

#repositories = client.directory.own_repositories

#repositories.list
  #on:
    #response: (response) ->
      #console.log "unexpected response status"
      #console.log response
    #200: (response, repo_list) ->
      #repo = repo_list[3]
      #repo.get
        #on:
          #200: (response, repo) ->
            #console.log "Name:", repo.name
            #console.log "Owner type:", repo.owner.resource_type
            #console.log repo.owner.url




