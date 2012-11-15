module.exports = (base_url) ->

  user: (options) ->
    "#{base_url}/users/#{options.user}"

  repositories: (options) ->
    "#{base_url}/users/#{options.owner}/repos"

  #repository:
    #contributors: "#{base_url}/repos/:owner/:repository/contributors"

  #organization:
    #self: "#{base_url}/orgs/:organization"
    #repositories: "#{base_url}/orgs/:organization/repos"

