load('env.js');
db = db.getSiblingDB('admin');

var users = [];

if (env.hasOwnProperty('MONGODB_USERS')) {
    users = JSON.parse(env.MONGODB_USERS);
}

if (env.hasOwnProperty('MONGODB_ADMIN_USER')) {
    users.unshift(
        {
            user: env.MONGODB_ADMIN_USER,
            pwd: env.MONGODB_ADMIN_PWD,
            roles: ["userAdminAnyDatabase"]
        }
    );
}

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
