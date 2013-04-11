module.exports =

  authenticated_user:
    resource: "user"
    path: "/user"

  user:
    resource: "user"
    template: "/users/:login"

  organizations:
    resource: "organizations"
    path: "/user/orgs"

  organization:
    resource: "organization"
    template: "/orgs/:login"

  ## Repositories
  repositories:
    resource: "repositories"
    path: "/user/repos"

  user_repositories:
    resource: "repositories"
    association: "user"
    template: "/users/:login/repos"

  organization_repositories:
    resource: "repositories"
    association: "organization"
    template: "/orgs/:organization/repos"

  repository:
    resource: "repository"
    template: "/repos/:login/:name"

  contributors:
    resource: "contributors"
    association: "repository"
    template: "/repos/:login/:name/contributors"

  languages:
    resource: "languages"
    association: "repository"
    template: "/repos/:login/:name/languages"



  ## Issues
  issues:
    resource: "issues"
    path: "/issues"

  all_issues:
    resource: "issues"
    path: "/user/issues"

  repository_issues:
    resource: "repository_issues"
    association: "repository"
    template: "/repos/:login/:name/issues"

  organization_issues:
    resource: "issues"
    association: "organization"
    template: "/orgs/:organization/issues"


  ## Gists
  gists:
    description: """
      List the authenticated user’s gists, or if called anonymously, this will return all public gists
    """
    resource: "gists"
    path: "/gists"

  starred_gists:
    description: """
      List the authenticated user’s starred gists
    """
    resource: "gists"
    path: "/gists/starred"

  public_gists:
    description: """
      List all public gists
    """
    resource: "gists"
    path: "/gists/public"

  user_gists:
    resource: "gists"
    association: "user"
    template: "/users/:login/gists"






