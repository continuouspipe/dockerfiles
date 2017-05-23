FROM gcr.io/google_containers/redis:v1

MAINTAINER "Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>"

ENV REDIS_MASTER_DOWN_AFTER_MILLISECONDS=5000
RUN sed -i'' 's/sentinel down-after-milliseconds mymaster 60000/sentinel down-after-milliseconds mymaster ${REDIS_MASTER_DOWN_AFTER_MILLISECONDS}/' /run.sh
