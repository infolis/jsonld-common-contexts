test = require 'tapes'
jcc = require '../src'

# test "URL destructuring", (t) ->
#     [base, last] = ['http://schema.org/', 'Action']
#     t.equals jcc.destructureURI(base+last)[0], base
#     t.equals jcc.destructureURI(base+last)[1], last

#     [base, last] = ['http://example.org/onto/v1#', 'Foo']
#     t.equals jcc.destructureURI(base+last)[0], base
#     t.equals jcc.destructureURI(base+last)[1], last
#     t.end()

# test "Remote context loading", (t) ->
#     jcc.loadContext 'http://dcat.io', (err, ctx) -> 
#         t.notOk err, "No Error"
#         t.ok ctx['@context'], "Has Context"
#         t.equals jcc.loadContext('http://dcat.io'), ctx, "Context was cached can be used sync now"
#         t.end()

test "withContext", (t) ->
	exp = {
		'dc:type': 'http://purl.org/dc/elements/1.1/type'
	}
	for curie, uri of exp
		t.equals jcc.withContext('basic').shorten(uri), curie
		t.equals jcc.withContext('basic').expand(curie), uri
		t.equals jcc.withContext('prefix.cc', 'basic').expand(curie), uri

	exp = {
		'foobar:baz': 'urn:quux/baz'
	}
	for curie, uri of exp
		t.equals jcc.withContext({'foobar': 'urn:quux/'}).expand(curie), uri
	t.end()

# ALT: src/index.coffee
