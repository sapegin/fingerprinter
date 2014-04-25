# fingerprinter

[![Build Status](https://travis-ci.org/sapegin/fingerprinter.png)](https://travis-ci.org/sapegin/fingerprinter)

Generic assests fingerprint generator. Generates md5 hash for a set of files or strings that you can append to URL to flush browser cache.


## Installation

```
npm install --save fingerprinter
```


## Example

```js
var Fingerprinter = require('fingerprinter');
var fp = new Fingerprinter();
fp.addFiles(['build/scripts.js', 'build/styles.css']);
fp.get(function(err, fingerprint) {
	if (!err) {
		console.log(fingerprint);
	}
});
```


## API

### add(string)

Add string.

```js
fp.add('body { color:red; }');
```

### fn.addFile(file) / fn.addFiles([file1, file2...])

Add file(s).

```js
fp.addFile('build/scripts.js');
fp.addFiles(['build/scripts.js', 'build/styles.css']);
```

### get(callback)

Get hash.

```js
fp.get(function(err, fingerprint) {
	// fingerprint = '73287dcc3d1ba241d7556412b7201af6'
});
```

### makeUrl(uri, callback)

Append hash to URL.

```js
fp.makeUrl('build/scripts.js', function(err, uri) {
	// uri = 'build/scripts.js?73287dcc3d1ba241d7556412b7201af6'
});
```


## Changelog

The changelog can be found in the [Changelog.md](Changelog.md) file.

## Author

* [Artem Sapegin](http://sapegin.me/)

---

## License

The MIT License, see the included [License.md](License.md) file.
