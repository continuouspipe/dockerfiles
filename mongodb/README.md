# MongoDB 3.4 or 3.6

In a docker-compose.yml for mongodb3.6:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mongodb3.6:latest
    environment:
      MONGODB_AUTH_ENABLED: 1
      MONGODB_ADMIN_USER: "myAdminUser"
      MONGODB_ADMIN_PWD: "A secret password for myAdminUser"
```

In a docker-compose.yml for mongodb3.4:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mongodb3.4:latest
    environment:
      MONGODB_AUTH_ENABLED: 1
      MONGODB_ADMIN_USER: "myAdminUser"
      MONGODB_ADMIN_PWD: "A secret password for myAdminUser"
```

In a Dockerfile for 3.6:
```Dockerfile
FROM quay.io/continuouspipe/mongodb3.6:latest
```
or for 3.4:
```Dockerfile
FROM quay.io/continuouspipe/mongodb3.4:latest
```

## How to build
```bash
./build.sh
docker-compose build --pull mongodb36 mongodb34
docker-compose push mongodb36 mongodb34
```

## About

This is a Docker image for MongoDB which tracks the upstream official image.

## How to use

As this is based on the library MongoDB image, see their README on
[The Docker Hub](https://hub.docker.com/_/mongo/).

### Authentication

Authentication can be enabled by setting the environment variable MONGODB_AUTH_ENABLED=1

In order for authentication to work, you will need to define an admin user or a
set of users:

#### Admin user

You can create an admin user that has a userAdminAnyDatabase role via setting
the environment variables:

* MONGODB_ADMIN_USER=<admin user name>
* MONGODB_ADMIN_PWD=<admin user password>

Note this Admin user with it's roll can only add other users to databases, not
operate on the db collections.

If you need the admin user to have further roles like `root`, then create it
using the [Set of users](#set-of-users) method instead.

#### Set of users

You can create one or more users with additional roles, and in specific
databases using JSON set in the environment variable MONGODB_USERS.

The JSON takes the form of an array of user objects, with the user objects following
the specification that MongoDB's [db.createUser()](https://docs.mongodb.com/manual/reference/method/db.createUser/)
takes, with a minor addition of a `database` field, which defines what database
the user is created in. If not supplied, the user will be added to the `admin`
database.

e.g.

```bash
MONGODB_USERS='[
  {
    "user": "fred"
    "pwd": "123"
    "roles": [
      "readWrite",
      {
          "role": "read",
          "db": "janesdb"
      }
    ],
    "database": "fredsdb"
  },
]'
```

```bash
MONGODB_USERS='[
  {
    "user": "admin"
    "pwd": "123"
    "roles": [
      "root",
    ]
  },
]'
```


The reason for the additional database field is that MongoDB authentication is
run against the db that the connection authenticates with, which for applications
needn't be the admin db. A role's db however applies on operations in a db after
authentication.

### Environment variables

Variable | Description | Expected values | Default
--- | --- | --- | ----
MONGODB_ADMIN_USER | The admin user to create. Not created if not specified | string |
MONGODB_ADMIN_PWD  | The password for the admin user | string |
MONGODB_BIND_IP | The IP to bind the server to (default all container network adapter IPs) | ip address | 0.0.0.0
MONGODB_USERS | Users to create/update in MongoDB | a json string
