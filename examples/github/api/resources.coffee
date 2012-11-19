module.exports =

  user:
    aliases: ["contributor"]
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "user"
        status: 200
      edit:
        method: "PATCH"
        authorization: "Basic"
        request_schema: "user"
        response_schema: "user"
        status: 200

  organizations:
    actions:
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "organization_list"
        status: 200

  organization:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "organization"
        status: 200
      edit:
        method: "PATCH"
        authorization: "Basic"
        request_schema: "organization"
        response_schema: "organization"
        status: 200


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
      edit:
        method: "PATCH"
        authorization: "Basic"
        request_schema: "repository"
        response_schema: "repository"
        status: 200
      #delete:
        #method: "DELETE"
        #authorization: "Basic"
        #status: 204


  contributors:
    actions:
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "contributor_list"
        status: 200

  languages:
    actions:
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "language_dictionary"
        status: 200

  teams:
    actions:
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "team_list"
        status: 200

  branches:
    actions:
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "branch_list"
        status: 200

  branch:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "branch"
        status: 200

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

  gist:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "gist_list"
        status: 200


