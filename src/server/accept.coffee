###
Copyright (c) 2012 Niclas Hoyer, Fiona Schmidtke, Ben Blank
Copyright (c) 2014 Niclas Hoyer, Pavel Strashkin

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
###


###
Modified by Panda Strike in 2015
###

# ## Util Functions
# Split a string and trim its splitted pieces.
trimsplit = (str, delimiter) ->
  strs = str.split delimiter
  str.trim() for str in strs

# ## Parse Functions

# Parse parameters including quality `q` from `Accept` header field.
parseParams = (str) ->

  paramToObj = (str,obj) ->
    param = trimsplit str, '='
    obj[param[0]] = param[1]

  strs = trimsplit str, ';'
  paramstrs = strs.slice 1

  params = {}
  paramToObj param, params for param in paramstrs

  if params.q?
    q = Number params.q
  else
    q = 1

  value: strs[0], params: params, quality: q

# Parse mediatype from object.
parseMediaType = (obj) ->
  mediarange = trimsplit obj.value, '/'
  type: mediarange[0]
  subtype: mediarange[1]
  params: obj.params
  mediarange: obj.value
  quality: obj.quality

# Just return value from object.
parseStandard = (obj) ->
  obj.value

# Parse custom `Accept` header field.
parseHeaderField = (str, map, sort, match) ->

  if not str?
    return

  strs = trimsplit str, ','
  objects = (parseParams str for str in strs)

  map = map ? parseStandard
  sort = sort ? sortQuality

  objects = (map obj for obj in objects)

  objects.sort sort

  Object.defineProperty objects, 'getBestMatch',
    value: match ? getBestMatch

# Parse `Accept` header field.
parseAccept = (str) ->
  str = str ? '*/*'
  parseHeaderField str, parseMediaType, sortMediaType, getBestMediaMatch

parseCharset = (string) ->
  parseHeaderField(string)

parseEncodings = (string) ->
  parseHeaderField(string)

parseLanguages = (string) ->
  parseHeaderField(string, null, null, getBestLanguageMatch)

parseRanges = (string) ->
  parseHeaderField(string)

parseHeaders = (headers) ->
  types:     parseAccept(headers.accept)
  charsets:  parseCharset(headers['accept-charset'])
  encodings: parseEncodings(headers['accept-encoding'])
  languages: parseLanguages(headers['accept-language'])
  ranges:    parseRanges(headers['accept-ranges'])

# ## Sort functions

# Sort objects by quality.
sortQuality = (a, b) ->
  if a.quality < b.quality
    return 1
  if a.quality > b.quality
    return -1

# Sort objects by media type and quality.
sortMediaType = (a, b) ->
  if a.quality < b.quality
    return 1
  if a.quality > b.quality
    return -1
  if a.type is '*' and b.type isnt '*'
    return 1
  if a.type isnt '*' and b.type is '*'
    return -1
  if a.subtype is '*' and b.subtype isnt '*'
    return 1
  if a.subtype isnt '*' and b.subtype is '*'
    return -1
  if Object.keys(a.params).length < Object.keys(b.params).length
    return 1
  if Object.keys(a.params).length > Object.keys(b.params).length
    return -1
  0

# ## Match functions

# Get the best full-string match.
getBestMatch = (candidates) ->
  acceptable = (accepted for accepted in this when accepted in candidates)
  acceptable[0] ? (candidates[0] if "*" in this)

# Get the best language match, as per RFC 2616 section 14.4.
getBestLanguageMatch = (candidates) ->
  acceptable = ({value: candidate, q: -1, length: 0} for candidate in candidates)

  for candidate in acceptable
    value = candidate.value + "-"

    for accepted, i in this
      if (value.indexOf accepted + "-") is 0
        length = (accepted.split "-").length

        if length > candidate.length
          candidate.q = i
          candidate.length = length

  acceptable.sort (a, b) ->
    # Sort q = -1 to the bottom
    if a.q is -1 and b.q isnt -1
      return 1
    if a.q isnt -1 and b.q is -1
      return -1

    # "q" comes from an array index, so sort 0 to the top.
    if a.q > b.q
      return 1
    if a.q < b.q
      return -1

    # If all else is equal, longer matches are better.
    if a.length < b.length
      return 1
    if a.length > b.length
      return -1
    0

  if acceptable[0].q isnt -1
    acceptable[0].value
  else
    candidates[0] if "*" in this

# Get the best media-type match, as per RFC 2616 section 14.1.
getBestMediaMatch = (candidates) ->
  acceptable = (parseMediaType parseParams candidate for candidate in candidates)

  for candidate, i in acceptable
    candidate.index = i
    candidate.quality = 0
    candidate.prec = -1

    for accepted in this
      prec = -1

      if accepted.type is candidate.type
        if accepted.subtype is candidate.subtype
          prec = 2

          for param, value of accepted.params when param isnt "q"
            if candidate.params[param] is value
              prec++
        else if accepted.subtype is "*"
          prec = 1
        # If type matches, but subtype does not and isn't a wildcard, leave
        # the precedence at -1.
      else if accepted.type is "*" and accepted.subtype is "*"
        # Lower than the precedence of any non-wildcard match, but higher
        # than that of a non-match.
        prec = 0

      if prec > candidate.prec
        candidate.prec = prec
        candidate.quality = accepted.quality

  acceptable.sort (a, b) ->
    if a.quality < b.quality
      return 1
    if a.quality > b.quality
      return -1
    if a.prec < b.prec
      return 1
    if a.prec > b.prec
      return 1

    # If all else is equal, prefer earlier candidates.
    if a.index < b.index
      return -1
    if a.index > b.index
      return 1

  candidates[acceptable[0].index] if acceptable[0].quality

# Build middleware with parsers for several accept header fields.
middleware = (req, res, next) ->
  req.accept = parseHeaders(req.headers)
  next()

module.exports = {
  middleware
  parseHeaders
  parseAccept
  parseHeaderField
  parseCharset
  parseEncodings
  parseLanguages
  parseRanges
}

