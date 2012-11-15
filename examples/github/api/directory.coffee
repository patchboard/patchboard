module.exports =

  authenticated_user:
    resource: "user"
    url: "https://api.github.com/user"

  repositories:
    resource: "repositories"
    url: "https://api.github.com/user/repos"

  organizations:
    resource: "organizations"
    url: "https://api.github.com/user/orgs"

  gists:
    resource: "gists"
    url: "https://api.github.com/gists"

  starred_gists:
    resource: "gists"
    url: "https://api.github.com/gists/starred"

  public_gists:
    resource: "gists"
    url: "https://api.github.com/gists/public"



