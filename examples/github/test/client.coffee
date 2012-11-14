Client = require("patchboard-client")
Testify = require("testify")

fs = require("fs")

# read login:password from a file
string = fs.readFileSync("auth")
string = string.slice(0, string.length - 1)
# pack it up, yo.
basic_auth = new Buffer(string).toString("base64")

client = new Client(require "../api")

# imbue the client with an authorization function
client.authorizer = (type, action) ->
  resource = @
  if type == "Basic"
    basic_auth
  else
    throw "Can't supply credential for #{type}"

repositories = client.resources.repositories
repositories.list
  on:
    response: (response) ->
      console.log "unexpected response status"
      console.log response
    200: (response, repo_list) ->
      repo = repo_list[3]
      repo.get
        on:
          200: (response, repo) ->
            console.log "Name:", repo.name
            console.log "Owner type:", repo.owner.resource_type
            console.log repo.owner.url




