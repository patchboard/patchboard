# Patchboard

Patchboard is a pair of libraries that significantly ease the development of an HTTP REST API by using simple, sensible, serializable descriptions of the resources, schemas, and URLs. It comes in two basic parts:

* Patchboard Client is an HTTP client that uses such a specification at runtime to self-assemble the logic needed to interact with your API.
* Patchboard Server is a library that uses that same specification to handle most of the HTTP-specific needs of a REST service: request validation, classification, and dispatching, as well as content marshalling and URL generation for responses.

Patchboard Server and Client are both implemented in Javascript for Node.js and browsers, but clients can be written in any sufficiently dynamic language.


## Why Patchboard?

Patchboard allows you to define a REST API using a set of serializable descriptions and schemas that are easy to write and easy to read.

Given a Patchboard API specification, you can immediately begin using self-assembling HTTP clients in any language Patchboard has implemented.  On the server side, you need only define handlers for each resource action in your API.  Patchboard virtually eliminates the repetition and brittleness involved in writing and maintaining an API.




### Schemas

An object describing the data structures used by an API service. The resource schema follows the principles in JSON schema draft 03, and should be usable by JSON schema validation libraries, such as JSV (which is actually used in Patchboard Server). Top level keys serve as associations to the type names in the resource specification.


### Resource descriptions

An object describing how HTTP requests map to resources and actions.

* `request_schema` and `response_schema` contain the names of schemas which describe the entities that are sent in the request and received in the response.  Schemas define the appropriate media types, which will be used in the `Content-Type` and `Accept` headers.
* the `authorization` field for an action contains the name of an authorization scheme to be used in a request, e.g. "Basic" or "Digest".

