module.exports =

  authenticated_user:
    resource: "user"
    url: "https://api.github.com/user"

  organizations:
    resource: "organizations"
    url: "https://api.github.com/user/orgs"

  repositories:
    resource: "repositories"
    url: "https://api.github.com/user/repos"


  ## Issues
  issues:
    resource: "issues"
    url: "https://api.github.com/issues"

  all_issues:
    resource: "issues"
    url: "https://api.github.com/user/issues"


  ## Gists
  gists:
    description: """
      List the authenticated user’s gists, or if called anonymously, this will return all public gists
    """
    resource: "gists"
    url: "https://api.github.com/gists"

  starred_gists:
    description: """
      List the authenticated user’s starred gists
    """
    resource: "gists"
    url: "https://api.github.com/gists/starred"

  public_gists:
    description: """
      List all public gists
    """
    resource: "gists"
    url: "https://api.github.com/gists/public"



