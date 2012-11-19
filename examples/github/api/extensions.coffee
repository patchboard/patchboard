module.exports = (base_url) ->

  user:
    resource: "user"
    template: "/users/:login"

  organization:
    resource: "organization"
    template: "/orgs/:login"

  repository:
    resource: "repository"
    template: "/repos/:login/:name"

  user_repositories:
    resource: "repositories"
    association: "user"
    template: "/users/:user/repos"

  organization_repositories:
    resource: "repositories"
    association: "organization"
    template: "/orgs/:organization/repos"

  user_gists:
    resource: "gists"
    association: "user"
    template: "/users/:login/gists"

  contributors:
    resource: "contributors"
    association: "repository"
    template: "/repos/:login/:name/contributors"

  languages:
    resource: "languages"
    association: "repository"
    template: "/repos/:login/:name/languages"


