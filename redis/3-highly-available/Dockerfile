FROM gcr.io/google_containers/redis:v1

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade | grep "^Inst" | \
      grep -i securi | awk -F " " '{print $2}' | \
      xargs apt-get -qq -y --no-install-recommends install \
 \
 # Clean the image \
 && apt-get autoremove -qq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV REDIS_MASTER_DOWN_AFTER_MILLISECONDS=5000
RUN sed -i'' 's/sentinel down-after-milliseconds mymaster 60000/sentinel down-after-milliseconds mymaster ${REDIS_MASTER_DOWN_AFTER_MILLISECONDS}/' /run.sh
