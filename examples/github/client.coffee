{Client} = require("patchboard")

api = require "./api"

class GitHubClient extends Client
  constructor: (@basic_auth_string) ->
    super(api)

    @authorizer = (type, action) =>
      resource = @
      if type == "Basic"
        @basic_auth_string
      else
        throw "Can't supply credential for #{type}"

  identifiers:
    user: (object) ->
      {login: object.login}

    organization: (object) ->
      {login: object.login}

    repository: (object) ->
      {login: object.owner.login, name: object.name}




module.exports = GitHubClient

