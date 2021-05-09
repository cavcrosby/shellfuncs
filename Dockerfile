FROM debian:latest

# create user that will run project tests
ARG USER_NAME="reap2sow1"
ARG GROUP_NAME="${USER_NAME}"
ARG USER_ID="1000"
ARG GROUP_ID="1000"
ARG USER_HOME="/home/${USER_NAME}"

# NOTES: mainly needed to construct container filesystem path to tests
# dir, as this may not be the same as the host. Defaults here should be
# else where, in a centralized place.
# TODO(conner@conneracrosby.tech): build-args here and else where could use some form of docker build wrapper with a build-args file format...maybe
ARG REPO_NAME
ARG REPO_TESTS_DIR_NAME

# NOTE: even though this project sets this env var on the host
# this does not mean the container has to use the same dotfile.
ARG SHELL_DOTFILE_NAME

ARG BRANCH
ARG COMMIT
LABEL tech.conneracrosby.shellfuncs.branch="${BRANCH}"
LABEL tech.conneracrosby.shellfuncs.commit="${COMMIT}"
LABEL tech.conneracrosby.shellfuncs.vcs-repo="https://github.com/reap2sow1/shellfuncs"

# y ==> yes, below env vars are needed for project automated install
ENV SHELLFUNCS_AUTOMATED_INSTALL "y"
ENV GIT_REPOS_PATH "${USER_HOME}/git"
# set here as well to have install write to the correct shell dotfile
ENV SHELL_DOTFILE_NAME "${SHELL_DOTFILE_NAME}"
# NOTE: these env vars are used for setting up the project repo,
# allowing tests to run at container runtime
ENV REPO_TESTS_DIR_PATH "${GIT_REPOS_PATH}/${REPO_NAME}/${REPO_TESTS_DIR_NAME}"
ENV INSTALL_PROGRAM_NAME "install"
ENV SHUNIT_PROGRAM_NAME "shunit2"
ENV SUDOER_PASSWORD 'Passw0rd!'
ENV SUDOER_PASSWORD_CRYPT '$6$ZKvnNYIGchgNi76o$oP2vnnPSkCHfwuslCxVH0shhbsMFhDJwVBBpZp2Fw7AQzuQU65mCAqJ7z9i/1ns6qYowFRi5iG6oUQ6YawhjB1'
# WD ==> WORKING_DIR...
ENV WD "/${REPO_NAME}"
WORKDIR "$WD"

# NOTE: update image, fetch project dependencies, and create 
# user/group in which to run tests with
USER root
# libgl1-mesa-glx needed running install_tortoisehg, reference:
# https://stackoverflow.com/questions/55313610/importerror-libgl-so-1-cannot-open-shared-object-file-no-such-file-or-directo
RUN apt-get update && apt-get install --assume-yes \
    build-essential \
    git \
    libgl1-mesa-glx \
    python3 \
    sudo
RUN groupadd --gid "$GROUP_ID" "$GROUP_NAME" \
    && useradd --create-home --home-dir "$USER_HOME" --uid "$USER_ID" --gid "$GROUP_ID" --shell /bin/bash "$USER_NAME" --password "$SUDOER_PASSWORD_CRYPT" \
    && echo "$USER_NAME ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USER_NAME}"
COPY "$INSTALL_PROGRAM_NAME" "$WD"

# NOTE: setups the project repo, and runs tests at container runtime
USER "$USER_NAME"
RUN "./${INSTALL_PROGRAM_NAME}"
COPY --chown="${USER_NAME}:${GROUP_NAME}" "$SHUNIT_PROGRAM_NAME" "$REPO_TESTS_DIR_PATH"
WORKDIR "$REPO_TESTS_DIR_PATH"
# TODO(conner@conneracrosby.tech): should probably not be hard coded this way, but this is project implementation specfic and I don't think the driver script is called out else where 
# NOTES: USER_HOME will not be available at container runtime, 
# so just use HOME. This is because ARG env vars are only available
# during the building of an image. 
CMD ["/bin/bash", "-c", ". ${HOME}/${SHELL_DOTFILE_NAME} && ./shellfuncs_driver && ./shellfuncs_driver"]
