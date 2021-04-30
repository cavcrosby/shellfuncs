FROM debian

ARG USER_NAME="reap2sow1"
ARG GROUP_NAME="reap2sow1"
ARG USER_ID="1000"
ARG GROUP_ID="1000"
ARG USER_HOME="/home/reap2sow1"
ARG BRANCH
ARG COMMIT
LABEL tech.conneracrosby.shellfuncs.branch="${BRANCH}"
LABEL tech.conneracrosby.shellfuncs.commit="${COMMIT}"
LABEL tech.conneracrosby.shellfuncs.vcs-repo="https://github.com/reap2sow1/shellfuncs"

# WD ==> WORKING_DIR...
ENV WD "/shellfuncs_container"
# y ==> yes
ENV SHELLFUNCS_AUTOMATED_INSTALL="y"
ENV GIT_REPOS_PATH="${USER_HOME}/git"
WORKDIR "$WD"

# NOTE: update container, fetch dependencies, and create user/group
# in which to run tests with
USER root
RUN apt-get update && apt-get dist-upgrade --assume-yes
RUN apt-get install git --assume-yes
RUN groupadd --gid "$GROUP_ID" "$GROUP_NAME"
RUN useradd --create-home --home-dir "$USER_HOME" --uid "$USER_ID" --gid "$GROUP_ID" --shell /bin/bash "$USER_NAME"

COPY "install" "$WD"
RUN "./install"
CMD ["/bin/bash"]
