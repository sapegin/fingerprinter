/**
 * Generic assests fingerprint generator.
 *
 * @author Artem Sapegin (http://sapegin.me)
 */

// @todo Hash caching

'use strict';

var fs = require('fs');
var Q = require('q');
var crypto = require('crypto');
var url = require('url');

var hashAlgo = 'md5';

function Fingerprinter() {
	this.hash = crypto.createHash(hashAlgo);
	this.promises = [];
	this.hashes = [];
	this.fingerprint = null;
	this.promise = null;
	this.locked = false;
}

var fn = Fingerprinter.prototype;

/**
 * Add string.
 *
 * @param {String} string
 */
fn.add = function(string) {
	// Fingerprint already calculated
	if (this.locked) {
		throw new Error('Fingerprint already calculated.');
	}

	this.hash.update(string);
};

/**
 * Add file(s).
 *
 * @param {String|Array} file File name(s)
 */
fn.addFile = fn.addFiles = function(file) {
	// Fingerprint already calculated
	if (this.locked) {
		throw new Error('Fingerprint already calculated.');
	}

	// Handle arrays
	if (Array.isArray(file)) {
		file.forEach(this.addFile.bind(this));
		return;
	}

	// Check file
	if (!fs.existsSync(file)) {
		throw new Error('File ' + file + ' not found.');
	}

	// Add hash for sigle file
	var deferred = Q.defer();
	this.promises.push(deferred.promise);
	fileHash(file, function(err, hash) {
		if (err) {
			deferred.reject(err);
			return;
		}
		this.hash.update(hash);
		this.hashes.push(hash);
		deferred.resolve();
	}.bind(this));
};

/**
 * Get hash.
 *
 * @param {Function} callback function(err, fingerprint) {}
 */
fn.get = function(callback) {
	this.locked = true;

	// Fingerprint already calculated
	if (this.fingerprint) {
		callback(null, this.fingerprint);
		return;
	}

	// Only one piece, no need to calculate combined hash
	if (this.hashes.length === 1) {
		callback(null, this.hashes[0]);
		return;
	}

	// Calculate combined hash
	if (this.promise) {
		// Called second time: we need to wait unitll fingerpint is calculated and return it
		this.promise.then(function() {
			callback(null, this.fingerprint);
		}.bind(this));
	}
	else {
		// Called first time
		this.promise = Q.all(this.promises);
		this.promise.then(function() {
			var fingerprint = this.fingerprint = this.hash.digest('hex');
			callback(null, fingerprint);
		}.bind(this));
	}
	this.promise.fail(callback);
};

/**
 * Append hash to URL.
 *
 * @param {String} uri Base URL.
 * @param {Function} callback function(err, uri) {}
 */
fn.makeUrl = function(uri, callback) {
	this.get(function(err, fingerprint) {
		if (err) {
			callback(err);
			return;
		}

		var parts = url.parse(uri, true);
		if (parts.search) {
			parts.search = null;
			parts.query.v = fingerprint;
		}
		else {
			parts.search = fingerprint;
		}

		callback(null, url.format(parts));
	});
};

module.exports = Fingerprinter;


/**
 * Calculate hash for a file.
 *
 * @param {String} filepath [description]
 * @param {Function} callback [description]
 */
function fileHash(filepath, callback) {
	var hash = crypto.createHash(hashAlgo);
	var stream = fs.createReadStream(filepath);

	stream.on('error', callback);

	stream.on('data', hash.update.bind(hash));

	stream.on('end', function() {
		callback(null, hash.digest('hex'));
	});
}
