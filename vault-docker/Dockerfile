FROM --platform=$BUILDPLATFORM hashicorp/vault:1.8.0

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG DOCKER_USERNAME
ARG DOCKER_PASSWORD


# Install necessary dependencies
RUN apk update && apk add --no-cache \
    wget \
    git \
    docker \
    build-base

# Use the build-time variables to authenticate with the registry
RUN echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Clone the V programming language repository
RUN git clone https://github.com/vlang/v \
    && cd v \
    && make

# Symlink the V binary
RUN ln -s /v/v /usr/local/bin/v

# Clone the ct-plugin-string2files repository
RUN git clone https://github.com/dubizzle/ct-plugin-string2files.git \
    && cd ct-plugin-string2files \
    && v string2files.v \
    && chmod +x string2files \
    && mv string2files /usr/local/bin/

# Clean up build dependencies and temporary files
RUN apk del build-base && \
    rm -rf /var/cache/apk/* /ct-plugin-string2files-0.1.1

# Set the execution permissions for the v binary
RUN chmod +x /usr/local/bin/v
