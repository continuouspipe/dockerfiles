# Highly available Redis 3

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/redis3-highly-available:stable
```

In a docker-compose.yml:
```yml
version: '3'
services:
  redis:
    image: quay.io/continuouspipe/redis3-highly-available:stable
```

## How to build
```bash
docker-compose build redis_highly_available
docker-compose push redis_highly_available
```

## About

Based on https://github.com/kubernetes/examples/blob/master/staging/storage/redis/ but supporting the customisation
of the timeout for triggering a master failover.

## How to use

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
REDIS_MASTER_DOWN_AFTER_MILLISECONDS | How many milliseconds to wait before starting a master failover (if two or more redis sentinels agree) | integer (milliseconds) | 5000

### Example Automatic Deployment via continuous-pipe.yml

The following are some example tasks for automating the deployment of a highly available cluster:

```yaml
variables:
  REDIS_REPLICAS: 3
  REDIS_SENTINEL_REPLICAS: 3

tasks:
  infrastructure:
    deploy:
      services:
        mysql: ~

  redis_ha_master_deployment:
    filter:
      expression: 'tasks.infrastructure.services.mysql.created'
    deploy:
      services:
        redis_initial_master:
          specification:
            source:
              image: quay.io/continuouspipe/redis3-highly-available:stable
            accessibility:
              from_cluster: true
            ports:
              - 6379
              - 26379
            resources:
              requests:
                cpu: 50m
                memory: 100Mi
              limits:
                cpu: 250m
                memory: 500Mi
            command:
              - /bin/bash
              - -c
              - '/usr/local/bin/redis_command run_master_and_sentinel'
            environment_variables:
              REDIS_SENTINEL_SERVICE_HOST: ''
          deployment_strategy:
            readiness_probe:
              type: tcp
              port: 6379

        redis_sentinel:
          specification:
            scalability:
              number_of_replicas: ${REDIS_SENTINEL_REPLICAS}
            source:
              image: quay.io/continuouspipe/redis3-highly-available:stable
            accessibility:
              from_cluster: true
            environment_variables:
              SENTINEL: 'true'
              REDIS_SENTINEL_SERVICE_HOST: 'redis-initial-master'
            ports:
              - 26379
            resources:
              requests:
                cpu: 50m
                memory: 50Mi
              limits:
                cpu: 250m
                memory: 250Mi
          deployment_strategy:
            readiness_probe:
              type: tcp
              port: 26379

  redis_ha_deployment:
    deploy:
      services:
        redis:
          specification:
            scalability:
              number_of_replicas: ${REDIS_REPLICAS}
            source:
              image: quay.io/continuouspipe/redis3-highly-available:stable
            accessibility:
              from_cluster: true
            ports:
              - 6379
            resources:
              requests:
                cpu: 50m
                memory: 50Mi
              limits:
                cpu: 250m
                memory: 250Mi
          deployment_strategy:
            readiness_probe:
              type: tcp
              port: 6379

        redis_sentinel:
          specification:
            scalability:
              number_of_replicas: ${REDIS_SENTINEL_REPLICAS}
            source:
              image: quay.io/continuouspipe/redis3-highly-available:stable
            accessibility:
              from_cluster: true
            environment_variables:
              SENTINEL: 'true'
            ports:
              - 26379
            resources:
              requests:
                cpu: 50m
                memory: 50Mi
              limits:
                cpu: 250m
                memory: 250Mi
          deployment_strategy:
            readiness_probe:
              type: tcp
              port: 26379

  redis_ha_master_remove:
    filter:
      expression: 'tasks.infrastructure.services.mysql.created'
    deploy:
      services:
        redis_initial_master:
          specification:
            scalability:
              number_of_replicas: 0
            source:
              image: quay.io/continuouspipe/redis3-highly-available:stable
            accessibility:
              from_cluster: true
            ports:
              - 6379
              - 26379
            resources:
              requests:
                cpu: 50m
                memory: 100Mi
              limits:
                cpu: 250m
                memory: 500Mi

  redis_ha_master_failover:
    filter:
      expression: 'tasks.infrastructure.services.mysql.created'
    run:
      image:
        image: quay.io/continuouspipe/redis3-highly-available:stable
      commands:
        - /bin/bash -c '/usr/local/bin/redis_command master_failover_and_sentinel_cleanup'
```
