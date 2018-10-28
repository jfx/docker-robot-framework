FROM python:3-alpine

LABEL name="robot framework"
LABEL maintainer="soubirou@yahoo.fr"
LABEL website="https://hub.docker.com/r/jfxs/robot-framework/"
LABEL description="A lightweight docker image to run Robot Framework tests"

ENV ROBOT_VERSION=3.0.4
ENV SELENIUM_VERSION=3.2.0
ENV REQUESTS_VERSION=0.5.0

RUN pip install --no-cache-dir -U \
    robotframework==$ROBOT_VERSION \
    robotframework-seleniumlibrary==$SELENIUM_VERSION \
    robotframework-requests==$REQUESTS_VERSION && \
    rm -rf ~/.cache/pip

RUN addgroup nobody root && \
    mkdir -p /tests /reports && \
    chgrp -R 0 /reports && \
    chmod -R g=u /etc/passwd /reports

WORKDIR /tests

COPY uid-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["uid-entrypoint.sh"]

USER 65534
CMD ["robot", "--version"]
