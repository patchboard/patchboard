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
    template: "/users/:login/repos"

  organization_repositories:
    resource: "repositories"
    association: "organization"
    template: "/orgs/:organization/repos"


  repository_issues:
    resource: "repository_issues"
    association: "repository"
    template: "/repos/:login/:name/issues"

  organization_issues:
    resource: "issues"
    association: "organization"
    template: "/orgs/:organization/issues"


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


