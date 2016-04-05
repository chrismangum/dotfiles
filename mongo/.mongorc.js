login();

EDITOR = '/bin/vim';
DBQuery.prototype._prettyShell = true;

function Favorite(collection, query) {
    this.collection = db[collection];
    this.query = query;
}

['find', 'update'].forEach(function (method) {
    Favorite.prototype[method] = function (arg) {
        return this.collection[method](this.query, arg);
    };
});

function Favorites(options) {
    Object.assign(this, options);
    this.acct = new Favorite('account', {accountId: this.acctid});
    this.hub = this.app('hub');
    this.mdev = this.app('mdev');
    this.sasa = this.app('sasa');
    this.user = new Favorite('account', {accountId: this.acctid, 'users.userId': this.userid});
}

Favorites.prototype.appid = function (appName) {
    return [appName, this.version, this.year, this.username].join('-');
};

Favorites.prototype.app = function (appName) {
    return new Favorite('app', {apolloAppId: this.appid(appName)});
};

var my = new Favorites({
    acctid: '23232',
    userid: 'cmagnum',
    username: 'chris',
    version: '2-0-0',
    year: new Date().getFullYear()
});

function removeOldApps() {
    var currentAppRegex = RegExp(my.appid('\\w+'));
    var apps = db.app
        .find({apolloAppId: {$regex: RegExp('-' + my.username + '$')}})
        .toArray()
        .filter(function (app) {
            return !currentAppRegex.test(app.apolloAppId);
        });
    if (!apps.length) {
        print('No old apps found.');
    } else {
        apps.forEach(function (app) {
            print('Removing:', app.apolloAppId);
            db.app.remove({apolloAppId: app.apolloAppId});
        });
    }
}
