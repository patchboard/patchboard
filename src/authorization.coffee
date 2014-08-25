
parse_auth_params = (string) ->
  params = {}
  string = string.replace(/\s/g, "")
  parts = string.split(/,\s?/)
  for part in parts
    [key, value] = part.split("=")

    # values may be tokens or quoted strings
    if (match = value.match /^"(.*)"$/)?
      params[key] = match[1]
    else
      params[key] = value

  params

#parse_auth_params = (string) ->
  #parsed = {}
  #tokens = string.split /[, ]/
  #console.log tokens

module.exports =
  parse: (string) ->
    [scheme, credentials...] = string.split(/\s+/)
    credentials = credentials.join("")
    if scheme == "Basic"
      decoded = Buffer(credentials, "base64").toString("ascii")
      [login, password] = decoded.split(":")
      params = {login, password}
    else
      params = parse_auth_params(credentials)
    {scheme, params}

