dbName = 'dev2';
if (dbName === 'folsom' || dbName === 'attica' || dbName === 'shared') {
	conn = new Mongo('ic-db/ic-db-1.cisco.com,ic-db-2.cisco.com,ic-db-3.cisco.com');
} else if (dbName === 'stage' || dbName === 'production') {
	conn = new Mongo('braavos-db-02.cisco.com');
} else {
	conn = new Mongo('apollo/swtg-qa-mongo-2a.cisco.com,swtg-qa-mongo-2b.cisco.com,swtg-qa-mongo-2c.cisco.com');
}
db = conn.getDB(dbName);
login(dbName);

EDITOR = '/bin/vim';
DBQuery.prototype._prettyShell = true;
