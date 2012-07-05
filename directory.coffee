fs = require("fs")

directory =
  account:
    url: "http://api.quern.io/accounts/4EBBC93147C8"

  channel_collection:
    url: "http://api.quern.io/accounts/4EBBC93147C8/channels"
    capabilities:
      get: "347BC054FDDD"
      delete: "0ACE94C4C144"

fs.writeFileSync("directory.json", JSON.stringify(directory, null, 2))

