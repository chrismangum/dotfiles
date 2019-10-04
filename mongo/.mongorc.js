dbName = 'ironbank-dev';
switch (dbName) {
case 'folsom':
case 'attica':
case 'shared':
	conn = new Mongo('ic-db/ic-db-1.cisco.com,ic-db-2.cisco.com,ic-db-3.cisco.com');
	break;
case 'ironbank-stage':
case 'performance':
case 'production':
case 'stage':
// case 'admin':
	conn = new Mongo('braavos-db-03.cisco.com');
	break;
case 'ironbank-eu':
case 'ironbank-eu-stage':
case 'ironbank-eu-perf':
case 'admin':
	conn = new Mongo('dragon-db-04.cisco.com');
	break;
default:
	conn = new Mongo('apollo/swtg-qa-mongo-2a.cisco.com,swtg-qa-mongo-2b.cisco.com,swtg-qa-mongo-2c.cisco.com');
}
db = conn.getDB(dbName);
login(dbName);

EDITOR = '/bin/vim';
DBQuery.prototype._prettyShell = true;
