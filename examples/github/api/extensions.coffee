normalize = (callback) ->
  (options) ->
    if options.owner?.login
      options.owner = options.owner.login
    callback(options)

module.exports = (base_url) ->

  user:
    resource: "user"
    generate_url: normalize (options) ->
      "#{base_url}/users/#{options.owner}"

  organization:
    resource: "user"
    generate_url: normalize (options) ->
      "#{base_url}/orgs/#{options.owner}"

  repository:
    resource: "repository"
    generate_url: (options) ->
      "#{base_url}/repos/#{options.owner}/#{options.repo}"

  repositories:
    resource: "repositories"
    generate_url: (options) ->
      "#{base_url}/users/#{options.user}/repos"

  organization_repositories:
    resource: "repositories"
    generate_url: (options) ->
      "#{base_url}/orgs/#{options.organization}/repos"

  user_gists:
    resource: "gists"
    generate_url: (options) ->
      "#{base_url}/users/#{options.owner}/gists"

  contributors:
    resource: "contributors"
    generate_url: normalize (options) ->
      "#{base_url}/repos/#{options.owner}/#{options.name}/contributors"

  languages:
    resource: "languages"
    generate_url: normalize (options) ->
      "#{base_url}/repos/#{options.owner}/#{options.name}/languages"


