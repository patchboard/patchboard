Client = require("patchboard/src/client")
testify = require("patchboard/src/testify")

fs = require("fs")

string = fs.readFileSync("auth")
string = string.slice(0, string.length - 1)
basic_auth = new Buffer(string).toString("base64")

Client.discover "http://localhost:1338/", (err, client) ->

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
        console.log "unexpected responses status"
        console.log response


  return

  configuration = client.resources.configuration

  testify "configuration.update responds with 204", (test) ->
    #time = Date.now()
    rand = Math.random().toString()
    configuration.update
      content:
        origins: [rand]
        names: ["known", "event", "names"]
      on:
        204: (response) ->
          test.done()
          testify "configuration.get", (test) ->
            configuration.get
              on:
                200: (response, config) ->
                  origins = config.origins
                  test.assert.equal(origins.constructor, Array)
                  test.assert.ok(origins.length > 0)
                  test.assert.ok origins.some (item) ->
                    item == rand
                  test.assert.equal(config.names.constructor, Array)
                  test.assert.ok(config.names.length > 0)
                  test.done()
                response: (response) ->
                  test.assert.fail null, null, "Unexpected response status: #{response.status}"




