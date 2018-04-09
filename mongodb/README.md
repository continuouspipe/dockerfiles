# MongoDB 3.4 or 3.6

In a docker-compose.yml for mongodb3.6:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mongodb3.6:stable
    environment:
      MONGO_INITDB_ROOT_USERNAME: "myAdminUser"
      MONGO_INITDB_ROOT_PASSWORD: "A secret password for myAdminUser"

In a docker-compose.yml for mongodb3.4:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mongodb3.4:stable
    environment:
      MONGO_INITDB_ROOT_USERNAME: "myAdminUser"
      MONGO_INITDB_ROOT_PASSWORD: "A secret password for myAdminUser"
```

In a Dockerfile for 3.6:
```Dockerfile
FROM quay.io/continuouspipe/mongodb3.6:stable
```
or for 3.4:
```Dockerfile
FROM quay.io/continuouspipe/mongodb3.4:stable
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

#### Authentiation and Admin user

You can enable authentication and create an admin user that has a root role via setting
the environment variables:

* MONGO_INITDB_ROOT_USERNAME=<admin user name>
* MONGO_INITDB_ROOT_PASSWORD=<admin user password>

#### Set of users

You can create one or more users with additional roles, and in specific
databases using JSON set in the environment variable MONGODB_USERS.

Authentication for these users will only be performed if an admin user is created as above.

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

Upstream environment variables (not currently documented upstream):

Variable | Description | Expected values | Default
--- | --- | --- | ----
MONGO_INITDB_ROOT_USERNAME | The admin user to create on initialisation and enable authentication | string |
MONGO_INITDB_ROOT_PASSWORD | The password for the admin user

Additional environment variables provided by this image:

Variable | Description | Expected values | Default
--- | --- | --- | ----
MONGODB_AUTH_ENABLED | An alternative to supplying a admin user/password, which generates one with a random password to enable authentication | 0/1 | 0
MONGODB_ADMIN_USER | The admin user to create. (deprecated, see upstream MONGO_INITDB_ROOT_USERNAME) | string |
MONGODB_ADMIN_PWD  | The password for the admin user (deprecated, see upstream MONGO_INITDB_ROOT_PASSWORD) | string |
MONGODB_USERS | Users to create on first init in MongoDB | a json string
