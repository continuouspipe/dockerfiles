load('env.js');
db = db.getSiblingDB('admin');

db.dropAllUsers();

if (env.hasOwnProperty('MONGODB_ADMIN_USER')) {
    db.createUser(
      {
        user: env.MONGODB_ADMIN_USER,
        pwd: env.MONGODB_ADMIN_PWD,
        roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
      }
    );
}

if (env.hasOwnProperty('MONGODB_USERS')) {
    JSON.parse(env.MONGODB_USERS).forEach(function (user) {
        if (user.hasOwnProperty('database')) {
            userDb = db.getSiblingDB(user.database);
            delete user.database;
        } else {
            userDb = db;
        }
        userDb.createUser(user);
    });
}
