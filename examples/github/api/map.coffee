module.exports =

  repositories:
    paths: ["/user/repos"]
    publish: true

  #user_repositories:
    #paths: ["/users/:user/repos"]


  authenticated_user:
    paths: ["/user"]
    publish: true

  organizations:
    paths: ["/user/orgs"]
    publish: true

  #organization:
    #paths: ["/orgs/:org"]

  #user:
    #paths: ["/users/:user"]

  #organization_repositories:
    #paths: ["/orgs/:org/repos"]

