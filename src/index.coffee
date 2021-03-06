### 
# Common Contexts for JSON-LD / RDF

# TODO proper parsing of contexts, expansion of nested contexts, arrays of contexts etc.

###

{deepmerge, fetch} = require('@kba/node-utils')

# maps concise names to paths to be required
predefinedContexts = {
	'prefix.cc':  './contexts/prefix.cc'
	'anno':       './contexts/anno.jsonld'
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
					fetch(ctx, {
						headers:
							'Accept': 'application/ld+json'
					}).then((resp) => resp.json()).then((body) ->
						_ctxCache[ctx] body
						callback err, body
					).catch (err) ->
						callback new Error("Error retrieving #{ctx} as JSON-LD")
		return ctx

	withContext : (contexts...) ->
		throw new Error("Must give context") unless contexts.length

		if Array.isArray contexts[0]
			contexts = contexts[0]

		ctx = {}
		for thisCtx in contexts
			ctx = deepmerge(ctx, @loadContext(thisCtx))

		revCtx = {}
		for prefix, uri of ctx
			if uri not of revCtx
				revCtx[uri] = prefix

		self = @
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
			shorten_expand: (str) ->
				return @shorten @expand str
			namespaces : (type = 'jsonld') ->
				switch type
					when 'jsonld'
						return ctx
					when 'rapper-args'
						ret = []
						ret.push("-f", "xmlns:#{prefix}=\"#{url}\"") for prefix, url of ctx
						return ret
					when 'turtle', 'n3', 'trig'
						("@prefix #{prefix}: <#{url}> ." for prefix, url of ctx).join('\n')
					when 'rdfxml'
						(" xmlns:#{prefix}=\"#{url}\"" for prefix, url of ctx).join(' ')
					when 'sparql'
						("PREFIX #{prefix}: <#{url}>" for prefix, url of ctx).join('\n')
					else
						throw new Error("Not implemented for type #{type}")
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
