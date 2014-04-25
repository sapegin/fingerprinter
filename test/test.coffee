expect = (require 'chai').expect
Fingerprinter = require '../index'

DEBUG = false

files = {
	scriptsJs: 'test/src/scripts.js'
	stylesCss: 'test/src/styles.css'
}
strings = {
	css1: 'body { color:red; }'
	css2: 'h1 { color:blue; }'
}
hashes = {
	scriptJs: '73287dcc3d1ba241d7556412b7201af6'
	scriptJsAndStylesCss: '9f9efcf9aa92912f011f40a57025167c'
	stringCss1: '2602617f9e255be4b83cedaa13cb2e14'
	stringCss1AndStringCss2: '9f496b56678c3b620e6a8328f0814d45'
	stringCss1AndStylesCss: '6e0725f6592da5fc415a108790437b7b'
}

log = ->
	args = Array.prototype.slice.call(arguments)
	args.unshift('Fingerprinter')
	console.log.apply(null, args)  if DEBUG


describe 'basic', ->

	it 'one file', (done) ->
		fp = new Fingerprinter()
		fp.addFile(files.scriptsJs)
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.scriptJs)
				done()
			)
		)

	it 'few files, one addFiles call', (done) ->
		fp = new Fingerprinter()
		fp.addFiles([files.scriptsJs, files.stylesCss])
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.scriptJsAndStylesCss)
				done()
			)
		)

	it 'few files, few addFile calls', (done) ->
		fp = new Fingerprinter()
		fp.addFile(files.scriptsJs)
		fp.addFile(files.stylesCss)
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.scriptJsAndStylesCss)
				done()
			)
		)

	it 'one string', (done) ->
		fp = new Fingerprinter()
		fp.add(strings.css1)
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.stringCss1)
				done()
			)
		)

	it 'few strings', (done) ->
		fp = new Fingerprinter()
		fp.add(strings.css1)
		fp.add(strings.css2)
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.stringCss1AndStringCss2)
				done()
			)
		)

	it 'combine strings and files', (done) ->
		fp = new Fingerprinter()
		fp.add(strings.css1)
		fp.addFile(files.stylesCss)
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.stringCss1AndStylesCss)
				done()
			)
		)

	it 'get can be called few times', (done) ->
		fp = new Fingerprinter()
		fp.addFile(files.scriptsJs)
		fp.addFile(files.stylesCss)
		calls = 2
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.scriptJsAndStylesCss)
				calls -= 1
				done()  unless calls
			)
		)
		fp.get((err, fingerprint) ->
			log(err, fingerprint)
			setTimeout(->
				expect(err).to.not.exists
				expect(fingerprint).to.equal(hashes.scriptJsAndStylesCss)
				calls -= 1
				done()  unless calls
			)
		)

	it 'make URLs', (done) ->
		fp = new Fingerprinter()
		fp.addFile(files.scriptsJs)
		calls = 2
		fp.makeUrl('build/scripts.js', (err, url) ->
			log(err, url)
			setTimeout(->
				expect(err).to.not.exists
				expect(url).to.equal("build/scripts.js?#{hashes.scriptJs}")
				calls -= 1
				done()  unless calls
			)
		)
		fp.makeUrl('build/scripts.js?foo=1&bar=2', (err, url) ->
			log(err, url)
			setTimeout(->
				expect(err).to.not.exists
				expect(url).to.equal("build/scripts.js?foo=1&bar=2&v=#{hashes.scriptJs}")
				calls -= 1
				done()  unless calls
			)
		)

	it 'can’t add files after finish', (done) ->
		fp = new Fingerprinter()
		fp.addFile(files.scriptsJs)
		fp.get((err, fingerprint) ->)
		expect(-> fp.addFile(files.stylesCss)).to.throw(Error)
		expect(-> fp.add('test')).to.throw(Error)
		done()

	it 'non-existent file', (done) ->
		fp = new Fingerprinter()
		expect(-> fp.addFile('noooo')).to.throw(Error)
		done()
