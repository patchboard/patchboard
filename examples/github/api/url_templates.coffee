module.exports = (base_url) ->

  user:
    resource: "user"
    generate_url: (options) ->
      "#{base_url}/users/#{options.user}"

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

  #repository:
    #contributors: "#{base_url}/repos/:owner/:repository/contributors"

  #organization:
    #self: "#{base_url}/orgs/:organization"
    #repositories: "#{base_url}/orgs/:organization/repos"

