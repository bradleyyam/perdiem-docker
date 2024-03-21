# docker build -t build-test --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" .

FROM debian:latest

ARG ssh_prv_key

# Install git
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git openssh-client

# Prepare SSH directory and add the keys
RUN mkdir -p /root/.ssh/ && \
    echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Clone the repository
RUN git clone git@github.com:JoaoCardoso193/perdiem.git



# The tag here should match the Meteor version of your app, per .meteor/release
FROM geoffreybooth/meteor-base:2.11.0


# Copy app package.json and package-lock.json into container
COPY --from=0 ./perdiem/ $APP_SOURCE_FOLDER/perdiem/

RUN cd $APP_SOURCE_FOLDER/perdiem && \
    meteor npm install && \
    meteor reset && \
    meteor build --directory $APP_BUNDLE_FOLDER --server-only

FROM debian:latest

ENV APP_BUNDLE_FOLDER /opt/bundle

COPY --from=1 $APP_BUNDLE_FOLDER/bundle $APP_BUNDLE_FOLDER/bundle/
COPY ./config/.env $APP_BUNDLE_FOLDER/bundle
COPY ./config/credentials.json $APP_BUNDLE_FOLDER/bundle
COPY ./config/token.json $APP_BUNDLE_FOLDER/bundle

RUN cd $APP_BUNDLE_FOLDER/bundle && \
    $@

CMD ["node", "main.js"]