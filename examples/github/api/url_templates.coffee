module.exports = (base_url) ->

  user:
    url: "#{base_url}/users/:user"
    repositories: "#{base_url}/users/:user/repos"

  repository:
    contributors: "#{base_url}/repos/:owner/:repository/contributors"

  organization:
    url: "#{base_url}/orgs/:organization"
    repositories: "#{base_url}/orgs/:organization/repos"

