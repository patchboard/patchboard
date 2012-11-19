module.exports =
  id: "github.com"
  type: "object"
  properties:

    resource:
      properties:
        url:
          type: "string"
          format: "uri"
          readonly: true
        id:
          type: "number"
          readonly: true

    repository:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string", required: true}
        description: {type: "string"}
        homepage: {type: "string"}
        private: {type: "boolean"}
        has_issues: {type: "boolean"}
        has_wiki: {type: "boolean"}
        has_downloads: {type: "boolean"}

        clone_url: {type: "string", readonly: true}
        git_url: {type: "string", readonly: true}
        ssh_url: {type: "string", readonly: true}
        mirror_url: {type: "string", readonly: true}
        full_name: {type: "string"}
        fork: {type: "boolean"}
        language: {type: "string"}
        forks: {type: "number"}
        watchers: {type: "number"}
        size: {type: "number"}
        master_branch: {type: "string"}
        open_issues: {type: "number"}
        owner: {$ref: "#user"}
        organization: {$ref: "#organization"}
        pushed_at: {type: "string"}
        created_at: {type: "string"}
        updated_at: {type: "string"}
        parent: {$ref: "#repository"}
        source: {$ref: "#repository"}

    repo_list:
      mediaType: "application/json"
      type: "array"
      items: {$ref: "#repository"}

    plan:
      type: "object"
      properties: {}
      
    owner:
      mediaType: "application/json"
      extends: {$ref: "#resource"}
      properties:
        name: {type: "string"}
        email: {type: "string"}
        blog: {type: "string"}
        company: {type: "string"}
        location: {type: "string"}
        hireable: {type: "string"}
        bio: {type: "string"}

        login: {type: "string", readonly: true}
        avatar_url: {type: "string"}
        gravatar_id: {type: "string"}

        public_repos: {type: "number"}
        public_gists: {type: "number"}
        followers: {type: "number"}
        following: {type: "number"}
        html_url: {type: "string"}
        created_at: {type: "string"}
        type: {type: "string"}
        total_private_repos: {type: "number"}
        owned_private_repos: {type: "number"}
        private_gists: {type: "number"}
        disk_usage: {type: "number"}
        collaborators: {type: "number"}
        plan: {$ref: "#plan"}

    user:
      mediaType: "application/json"
      extends: {$ref: "#owner"}


    organization:
      mediaType: "application/json"
      extends: {$ref: "#owner"}

    organization_list:
      type: "array"
      mediaType: "application/json"
      items: {$ref: "#organization"}


    contributor:
      extends: {$ref: "#user"}
      mediaType: "application/json"
      type: "object"
      properties:
        contributions: {type: "integer"}

    contributor_list:
      type: "array"
      mediaType: "application/json"
      items: {$ref: "#contributor"}


    language_dictionary:
      type: "object"
      mediaType: "application/json"
      additionalProperties: {type: "integer"}

    team:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      type: "object"
      properties:
        name: {type: "string"}
        id: {type: "integer"}

    team_list:
      type: "array"
      mediaType: "application/json"
      items: {$ref: "#team"}

    commit:
      type: "object"
      properties:
        sha: {type: "string"}
        url:
          type: "string"
          format: "uri"
    tag:
      mediaType: "application/json"
      type: "object"
      properties:
        name: {type: "string"}
        commit: {$ref: "#commit"}
        zipball_url:
          type: "string"
          format: "uri"
        tarball_url:
          type: "string"
          format: "uri"

    branch:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      type: "object"
      properties:
        name: {type: "string"}
        commit: {$ref: "#commit"}

    branch_list:
      type: "array"
      mediaType: "application/json"
      items: {$ref: "#branch"}


    gist:
      mediaType: "application/json"
      extends: {$ref: "#resource"}
      properties: {}

    gist_list:
      mediaType: "application/json"
      type: "array"
      items: {$ref: "#gist"}



