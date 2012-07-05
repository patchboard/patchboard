fs = require("fs")

api =
  account_collection:
    url: "{service_url}/accounts"
    actions:
      create:
        method: "POST"
        request_schema: "account"
        response_schema: "account"
      search:
        method: "GET"
        query:
          required:
            email: {type: "glob"}
            limit: {type: "integer"}
        response_schema: "account_collection"

  account:
    url: "{service_url}/accounts/{id}"
    actions:
      update:
        method: "PUT"
        request_schema: "account"
        response_schema: "account"
        authorization: "Capability"
      delete:
        method: "DELETE"
        authorization: "Basic"

  channel_collection:
    url: "{service_url}/channels"
    actions:
      search:
        method: "GET"
        query:
          required:
            name:
              description: "Search for channels by name"
              type: ["glob"]
        response_schema: "channel_collection"
        authorization: "Capability"

      list:
        method: "GET"
        query:
          required:
            limit: {type: "integer"}
          optional:
            offset: {type: "integer"}
            sort: {type: "string"}
        response_schema: "channel_collection"

      create:
        method: "POST"
        request_schema: "channel"
        response_schema: "channel"
        authorization: "Capability"

  channel:
    url: "{service_url}/channels/{id}"
    actions:
      get:
        method: "GET"
        authorization: "Capability"
      delete:
        method: "DELETE"
        authorization: "Capability"


fs.writeFileSync("api.json", JSON.stringify(api, null, 2))
