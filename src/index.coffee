### 
# Common Contexts for JSON-LD / RDF

# TODO proper parsing of contexts, expansion of nested contexts, arrays of contexts etc.

###

Request = require 'superagent'

# maps concise names to paths to be required
predefinedContexts = {
	'prefix.cc':  './contexts/prefix.cc'
	'rdfa':       './contexts/rdfa11'
	'rdfa11':     './contexts/rdfa11'
	'basic':      './contexts/basic'
	'dcat':       './contexts/dcat'
	'dcat.io':    './contexts/dcat'
	'schema':     './contexts/schema.org'
	'schema.org': './contexts/schema.org'
}

_ctxCache = {}
module.exports = {

	# TODO this should be moved elsewhere
	loadContext : (ctx, callback) ->
		# If this is a string but not a URL
		if typeof ctx is 'string' 
			if ctx of predefinedContexts
				if not predefinedContexts[ctx]
					throw new Error "No such predefined context: #{ctx}"
				contextJson = require(predefinedContexts[ctx])
				ctx = contextJson['@context']
			else
				# Assume it's a URI
				if ctx of _ctxCache
					ctx = _ctxCache[ctx]
				else
					# require callback for uncached URIs
					if not callback
						throw new Error("Must provide callback when passing an uncached URI")
					Request
						.get(ctx)
						.set('Accept', 'application/ld+json')
						.end (err, resp) ->
							if not err and resp.status == 200 and resp.body
								_ctxCache[ctx] = resp.body
								callback err, resp.body
							else
								callback new Error("Error retrieving #{ctx} as JSON-LD")
		return ctx

	withContext : (ctx) ->
		throw new Error("Must give context") unless ctx
		self = @
		ctx = self.loadContext(ctx)
		revCtx = {}
		for prefix, uri of ctx
			revCtx[uri] = prefix
		return {
			shorten: (uri) ->
				[base, term] = self.destructureURI uri
				if base of revCtx
					uri = "#{revCtx[base]}:#{term}"
				return uri
			expand: (curie) ->
				[prefix, term] = self.destructureCURIE curie
				if prefix of ctx
					curie = ctx[prefix] + term
				return curie
		}

	destructureCURIE : (curie) ->
		base = ''
		last = curie
		if curie.indexOf(':') > -1
			base = curie.substr(0, curie.indexOf(':'))
			term = curie.substr(curie.indexOf(':') + 1)
		return [base, term]

	destructureURI : (uri) ->
		base = uri
		last = ''
		if uri.indexOf('#') > -1
			base = uri.substr(0, uri.indexOf('#') + 1)
			last = uri.substr(uri.indexOf('#') + 1)
		else
			base = uri.substr(0, uri.lastIndexOf('/') +  1)
			last = uri.substr(uri.lastIndexOf('/') + 1)
		return [base, last]

	# TODO remove unused prefixes
	# removeUnused = (doc) ->
	#
}


# ALT: test/test.coffee
