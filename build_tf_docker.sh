#!/bin/sh

# The script will first build tf:00,
# then if the $tf_rebuild variable is set it will
# recompile tensorflow (dropping container cont_tf_00 if exists).
# Further it will continue building tf:02 (form tf:01 
# that should have been a result of compiling tensorflow 
# on top oftf:00).
# At the end it will start a container tf (from tf:02),
# and run nvidia-smi to check if everything worked fine.
# In the end it will launch the container with bash.
#
# The tf container is launched with mapped local passwd and shadow
# folders so user can login to JupyterHub using local user credentials
# from the host machine. For safety reasons they are set to be read-only
# as everything in container is run as root (for now). This way
# user is not able to modify the content of files, without sudo.

# if [ ! -z  ${tf_rebuild+x} ] || [ ! docker images | awk {'print$1":"$2'} | grep tf:01 > /dev/null]; then
#it should check hash of tf:00 if it changed then init tf_rebuild
nvidia-docker build -f Dockerfile.tf_00 -t tf:00 . && \
nvidia-docker run -d --ipc=host -v /etc/passwd:/etc/passwd:ro -v /etc/shadow:/etc/shadow:ro -v /home/$USER:/home/$USER --name tf tf:00 && \
nvidia-docker exec -it -u root tf bash -c "nvidia-smi" && \
nvidia-docker inspect $(docker ps -a | grep tf:00 | awk {'print$1'}) | grep \"IPAddress && \
nvidia-docker exec -it -u root tf bash
