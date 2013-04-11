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
        status: 201
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "repo_list"
        query:
          sort:
            type:
              enum: ["created", "updated", "pushed", "full_name"]
          direction:
            type:
              enum: ["asc", "desc"]
          type:
            type:
              enum: ["all", "owner", "public", "private", "member"]
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


  issues:
    actions:
      list:
        method: "GET"
        authorization: "Basic"
        query:
          filter:
            type:
              enum: ["assigned", "created", "mentioned", "subscribed", "all"]
          state:
            type:
              enum: ["open", "closed"]
          labels:
            type: "string"
          sort:
            type:
              enum: ["created", "updated", "comments"]
          direction:
            type:
              enum: ["asc", "desc"]
          since:
            type: "string"
        response_schema: "issue_list"
        status: 200


  repository_issues:
    actions:
      create:
        method: "POST"
        authorization: "Basic"
        request_schema: "issue"
        response_schema: "issue"
        status: 201
      edit:
        method: "PATCH"
        authorization: "Basic"
        request_schema: "issue"
        response_schema: "issue"
        status: 200
      list:
        method: "GET"
        authorization: "Basic"
        query:
          milestone:
            type: ["integer", "string"]
          state:
            type:
              enum: ["open", "closed"]
          assignee:
            type: "string"
          creator:
            type: "string"
          mentioned:
            type: "string"
          labels:
            type: "string"
          sort:
            type:
              enum: ["created", "updated", "comments"]
          direction:
            type:
              enum: ["asc", "desc"]
          since:
            type: "string"
        response_schema: "issue_list"
        status: 200


  issue:
    actions:
      get:
        method: "GET"
        authorization: "Basic"
        response_schema: "issue"
        status: 200

  gists:
    actions:
      create:
        description: "Create a gist"
        method: "POST"
        authorization: "Basic"
        request_schema: "gist"
        response_schema: "gist"
        status: 201
      list:
        method: "GET"
        authorization: "Basic"
        response_schema: "gist_list"
        query:
          since:
            type: "string"
            format: "date-time"
            description: """
              a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ
              Only gists updated at or after this time are returned.
              """
        status: 200
      edit:
        description: "Edit a gist"
        method: "PATCH"
        authorization: "Basic"
        request_schema: "gist"
        response_schema: "gist"
        status: 200


  gist:
    actions:
      get:
        description: "Get a single gist"
        method: "GET"
        authorization: "Basic"
        response_schema: "gist_list"
        status: 200
      edit:
        method: "PATCH"
        authorization: "Basic"
        request_schema: "gist"
        response_schema: "gist"
        status: 200
      #delete:
        #method: "DELETE"
        #authorization: "Basic"
        #status: 204

  gist_star:
    actions:
      check:
        method: "GET"
        authorization: "Basic"
        status: 204
      set:
        method: "PUT"
        authorization: "Basic"
        status: 204
      delete:
        method: "DELETE"
        authorization: "Basic"
        status: 204

  gist_fork:
    actions:
      create:
        method: "POST"
        authorization: "Basic"
        response_schema: "gist"
        status: 201

