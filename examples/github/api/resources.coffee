module.exports =

  repositories:
    actions:
      create:
        method: "POST"
        request_schema: "repository"
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "repo_list"
        query:
          optional:
            type:
              type:
                enum: ["all", "owner", "public", "private", "member"]
            sort:
              type:
                enum: ["created", "updated", "pushed", "full_name"]
            direction:
              type:
                enum: ["asc", "desc"]
        status: 200
  
  repository:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "repository"
        status: 200

  user:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "user"
        status: 200

  authenticated_user:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "user"
        status: 200

  organizations: {}

  gists:
    actions:
      create:
        method: "POST"
        authorization: "Basic"
        request_schema: "gist"
        response_schema: "gist"
        status: 201
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "gist_list"
        status: 200


  starred_gists:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "gist_list"
        status: 200

  user_gists:
    actions: {}
  public_gists:
    actions: {}

  gist:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "gist_list"
        status: 200


