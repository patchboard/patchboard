# Rigger

Rigger is (or will be) a set of libraries that allow you to construct an HTTP API around simple, sensible JSON descriptions of the resource types and of the HTTP interface.  The initial implementation will be Javascript for Node.js and browsers.

**Rigger is currently pre-alpha.**

The Big Idea is that if you define the surfaces of an HTTP API using JSON (a schema to describe resources and a special structure to define the HTTP actions), almost the entire API client and a substantial chunk of the API backend can emerge, ready-to-use, through runtime code generation in any language with such facilities.

On the client side, this would mean that once you've written the resource schemas and HTTP interface, you can immediately begin using self-assembling HTTP clients in any language Rigger has implemented.  These will be very basic clients; resource composition, blocking operations, etc. would need to be implemented according to the needs of the application.  But the basic needs of an API client constitute the majority of the work, and the more languages you try to support, the more work it is to keep everything in sync.

On the server side, Rigger can provide libraries that use the HTTP interface spec to generate routing/dispatching logic.  The resource schemas can be used to validate request data, and possibly to automate the process of marshalling and masking resources.

In the API backends I've previously worked on, dispatching, validating, and marshalling were the areas which suffered the most from the need for repetitiveness and the brittleness that inevitably accompanies it.  Any distributed backend can benefit from a shared definition of resources; backends that use HTTP forward caches can benefit from the shared definition of the interface.


### Use and abuse of the JSON schema draft spec

I have assumed two new primitive types: "resource" and "dictionary".  The
resource type is an object that has a mandatory "url" property.  The
dictionary type is an object where all the properties must be of the
type specified by dictionary's "items" property.

## How the client works

### Resource schema

A JSON object describing the data structures used by an API service. Top level keys are used as the resource type names.

The resource schema loosely follows the parts of JSON schema drafts 03 and 04 that I like; a sort of pidgin or slang that makes the documents more easily readable and writable than those that slavishly follow the spec.


### Interface description

A JSON object describing the HTTP requests used to interact with an API service.

The interface is not a JSON schema.  It could be described by one, or perhaps it could become an extension of the base schema, but that's premature abstraction at this point.  The interface document should make immediate sense to anyone who knows the basics of HTTP requests, with the exception of the `request_entity`, `response_entity`, and `authorization` fields.

* `request_entity` and `response_entity` contain the names of resource types (defined in the schema) which will be sent in the request and received in the response.  Resource schemas are expected to define the appropriate media types, which will be used in the `Content-Type` and `Accept` headers.
* the `authorization` field for an action contains the authorization scheme to be used in a request, e.g. "Basic" or "Digest".


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

This is very similar to the schema actually served by spire.io during discovery, but I have modified it where necessary to make it usable for automagical wrapper generation.

The HTTP interface: 
https://github.com/automatthew/rigger/blob/master/examples/spire/interface.coffee

This file currently is in the form intended for use by the API
service: i.e., the top level keys represent path-patterns for use in the
request dispatching logic.  The API client will receive a filtered
version of this structure, lacking the URL path patterns.

All this is designed to provide seamless chaining:

    session.resources.account.capabilities.update

In that example, `session` is a resource wrapper, as defined by the
schema.  According to the session schema,  `session.resources` has
type "object".  BUT! it also defines properties which have types we
know how to handle (e.g. session.resources.account has type "account")

Thus `session.resources.account` is a resource wrapper.

`session.resources.account.capabilities` is a dictionary wrapper.  The
items in the dictionary in this case are type "string", so nothing
else interesting happens.

A more interesting example of a dictionary wrapper is found in the
spire.io response to a request for all channels:

    session.resources.channels.all (dict) ->
      console.log(dict)

All of the values in `dict` are resource wrappers for the "channel" type.


