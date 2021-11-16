dbName = 'admin';
switch (dbName) {
case 'folsom':
case 'shared':
	conn = new Mongo('ic-db/ic-db-1.cisco.com,ic-db-2.cisco.com,ic-db-3.cisco.com');
	break;
default:
	conn = new Mongo('apollo/swtg-qa-mongo-2a.cisco.com,swtg-qa-mongo-2b.cisco.com,swtg-qa-mongo-2c.cisco.com');
}
db = conn.getDB(dbName);
login(dbName);

EDITOR = '/bin/vim';
DBQuery.prototype._prettyShell = true;
