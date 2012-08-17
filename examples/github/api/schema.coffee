module.exports =
  id: "github.com"
  properties:

    resource:
      extends: {$ref: "patchboard#resource"}
      properties:
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

    gist:
      mediaType: "application/json"
      properties:


    gist_list:
      mediaType: "application/json"
