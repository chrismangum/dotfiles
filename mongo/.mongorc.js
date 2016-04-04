login();

EDITOR = '/bin/vim';
DBQuery.prototype._prettyShell = true;

var year = new Date().getFullYear();
var version = '2-0-0';
var my = {
    acct: new Favorite('account', {accountId: '23232'}),
    app: _myApp,
    appid: _myAppId,
    hub: _myApp('hub'),
    mdev: _myApp('mdev'),
    user: new Favorite('account', {accountId: '23232', 'users.userId': 'cmagnum'})
};

function appId(appName, user) {
    return [appName, version, year, user].join('-');
}

function _myAppId(appName) {
    return appId(appName, 'chris');
}

function _myApp(appName) {
    return new Favorite('app', {apolloAppId: _myAppId(appName)});
}

function Favorite(collection, query) {
    this.collection = db[collection];
    this.query = query;
}

['find', 'update'].forEach(function (method) {
    Favorite.prototype[method] = function (arg) {
        return this.collection[method](this.query, arg);
    };
});
