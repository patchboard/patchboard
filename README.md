# Rigger

Rigger is a set of libraries that allow you to construct an HTTP API around simple, sensible JSON descriptions of the resource types and of the HTTP interface.

**Rigger is currently pre-alpha.**

Rigger's client library uses these resource and interface descriptions to assemble
a working API client, with resources, properties, and API actions defined
at runtime.

In the near future, Rigger will provide:

* a server-side library for dispatching (a.k.a. routing) HTTP requests that uses the HTTP interface description.
* a server-side library for validating requests and marshalling responses using the resource schemas.
* All of the above in as many languages as reasonable.


### Use and abuse of the JSON schema draft spec

I have assumed two new primitive types: "resource" and "dictionary".  The
resource type is an object that has a mandatory "url" property.  The
dictionary type is an object where all the properties must be of the
type specified by dictionary's "items" property.

## How the client works

### Resource schema

A JSON object describing the data structures used by an API service.

### Interface description

A JSON object describing the HTTP requests used to interact with an API service.

    {
      "thingies": {
        "description": "A collection of thingies",
        "actions": {
          "search": {
            "method": "GET",
            "query": {
              "required": {
                "tag": {
                  "description": "Search for thingies by name",
                  "type": "string"
                }
              }
            },
            "response_entity": "thingie_list"
          }
        }
      },
      "thingie": {
        "description": "One single thingie",
        "actions": {
          "update": {
            "method": "PUT",
            "request_entity": "thingie",
          }
        }
      }
    }

### Code generation

Given a data schema, Rigger automatically defines wrapper classes for each of the keys at the top level. Top-level schemas are currently presumed to be one of two types: "resource" or "dictionary".

For resource wrappers, the associated schema is used to define getter/setter methods, so that all possible properties of the resource are themselves appropriately wrapped upon access.

Dictionary wrappers subject all properties to resource wrapping at
instantiation time.  They also do something smart for sub-properties with
defined schemas, so that objects deep in a data structure can be
wrapped as needed.

Using an HTTP interface description, Rigger defines action methods for the resource wrapper instances.  These methods handle all the work required to make an HTTP request to the API service.


## Example (using the spire.io API)

The example schema and interface are written in CoffeeScript and converted to JSON
using Rake (polyglossolalia FTW).  In normal usage, the API service would provide
both the schema and interface to the client via some sort of discovery request.

The data-description schema: https://github.com/automatthew/rigger/blob/master/examples/spire/resource_schema.coffee

This is very similar to the schema actually served by spire.io during discovery, but I have modified it where necessary to make it usable for automagical class generation.

The HTTP interface: 
https://github.com/automatthew/rigger/blob/master/examples/spire/interface.coffee

This file currently is in the form intended for use by the API
service: the top level keys represent path-patterns for use in the
request dispatching logic.  The API client will receive a filtered
version of this structure, lacking the URL path patterns.


All this is designed to provide seamless chaining:

    session.resources.account.capabilities.update

In that example, `session` is a resource wrapper, as defined by the
schema.  According to the session schema,  `session.resources` has
type "object".  BUT! it also defines properties which have types we
know how to handle (e.g. session.resources.account has type "account")

So `session.resources.account` is a resource wrapper.

`session.resources.account.capabilities` is a dictionary wrapper.  The
items in the dictionary in this case are type "string", so nothing
else interesting happens.

A more interesting example of a dictionary wrapper is found in the
spire.io response to a request for all channels:

    session.resources.channels.all (dict) ->
      console.log(dict)

All of the values in `dict` are resource wrappers for the "channel" type.


