db = db.getSiblingDB('admin');

var users = JSON.parse(cat('/tmp/users.json'));

users.forEach(function (user) {
    var userDb = db;
    var userName = user.user;

    if (user.hasOwnProperty('database')) {
        userDb = db.getSiblingDB(user.database);
        delete user.database;
    }

    if (userDb.getUser(userName) === null) {
        userDb.createUser(user);
    } else {
        delete user.user;
        userDb.updateUser(userName, user);
    }
});
