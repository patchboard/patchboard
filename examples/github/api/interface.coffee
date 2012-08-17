module.exports =

  repositories:
    actions:
      create:
        method: "POST"
        request_entity: "repository"
      list:
        method: "GET"
        authorization: "Basic"
        response_entity: "repo_list"
        query:
          optional:
            sort:
              type:
                enum: ["created", "updated", "pushed", "full_name"]
            type:
              type:
                enum: ["all", "owner", "public", "private", "member"]
            direction:
              type:
                enum: ["asc", "desc"]
        status: 200
  
  repository:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_entity: "repository"
        status: 200

  user:
    actions:
      get:
        method: "GET"
        response_entity: "user"
        status: 200

  authenticated_user:
    actions:
      get:
        method: "GET"
        response_entity: "user"
        status: 200

  organizations: {}
