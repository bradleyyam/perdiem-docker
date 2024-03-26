# docker build -t build-test --build-arg HOST_SSH_KEY="$(cat ~/.ssh/id_rsa)" .

FROM debian:latest

ARG HOST_SSH_KEY

# Install git
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git openssh-client

# Prepare SSH directory and add the keys
RUN mkdir -p ~/.ssh/ && \
    echo "$HOST_SSH_KEY" > ~/.ssh/id_rsa && \
    chmod 600 ~/.ssh/id_rsa && \
    ssh-keyscan github.com > ~/.ssh/known_hosts


# Clone the repository
RUN git clone git@github.com:JoaoCardoso193/perdiem.git && \
    cd perdiem && \
    git checkout docker-test && \
    git pull

# The tag here should match the Meteor version of your app, per .meteor/release
FROM geoffreybooth/meteor-base:2.11.0

# Copy app package.json and package-lock.json into container
COPY --from=0 ./perdiem/ $APP_SOURCE_FOLDER/perdiem/

RUN cd $APP_SOURCE_FOLDER/perdiem && \
    meteor npm install && \
    meteor reset && \
    meteor build --directory $APP_BUNDLE_FOLDER --server-only



FROM meteor/node:14.21.4-alpine3.17

ENV APP_BUNDLE_FOLDER /opt/bundle
ENV ROOT_URL localhost

COPY --from=1 $APP_BUNDLE_FOLDER/bundle ./bundle/
COPY ./config/.env ./bundle
COPY ./config/credentials.json ./bundle
COPY ./config/token.json ./bundle

RUN cd ./bundle/programs/server && \
    npm install

CMD [ "node", "./bundle/main.js"]