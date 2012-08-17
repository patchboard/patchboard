Client = require("patchboard/src/client")
testify = require("patchboard/src/testify")

fs = require("fs")

# read login:password from a file
string = fs.readFileSync("auth")
string = string.slice(0, string.length - 1)
# pack it up, yo.
basic_auth = new Buffer(string).toString("base64")

Client.discover "http://localhost:1338/", (err, client) ->

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
      200: (response, repo_list) ->
        repo = repo_list[3]
        repo.get
          on:
            200: (response, repo) ->
              console.log repo.name
              console.log repo.source.resource_type
              console.log repo.owner.resource_type
              console.log repo.owner.url

      response: (response) ->
        console.log "unexpected response status"
        console.log response


  return

