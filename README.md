# MLDocker
This is a copy of my dockerized machine learning environment. As I have been reinstalling my system recenlty quite often I decided to put it into docker for the ease of deployment.

By default docker does not support any HDW passthrough, so GPU cannot be used from within, but using nvidia-docker wrapper one can start utilizing GPU using docker. I predominantly use python, so as for now jupyter notebook does not contain any kernels for other languages.

This allowed me to move my whole ML environment to the docker. The aim here was to have most imporatant libraries compiled from the source, so if new version gets released you can easily update without waiting for binaries. As for now that includes:
- Tensorflow
- Keras
- VTK
- OpenCV (with GPU support and contrib modules)
- Protobuf (C++ implementation for Python)
- Pillow-SIMD (wheel)
- JupyterHub
- JupyterLab
- JupyterNotebook
- GLog
- GFlags
- GTest
- Boost
- OpenBLAS
- XGBoost

Probably in the future I will extend it with a couple more ML libraries, but as for now I mainly utilize Tensorflow. All versions of libraries can be set through environemnt variables (those should be located in the beginning of reach Dockerfile). 

# Prerequisites
## Docker/nVidia-Docker
    [Docker-CE](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/) - at the moment I am using Edge branch, as Docker 17.06 available in stable has a bug that does not remove some unnecessary files from /etc/lib/docker/diffs, which can grow quite fast. Also I have switched from Aufs to OverlayFS2. Change is very simple, please see (the docs)[https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/#configure-docker-with-the-overlay-or-overlay2-storage-driver"], but be aware that you will lose all containers and images when switching between filesystems. So it is better to do before starting any work. 

    Having the docker up and running, you may go to (nVidia-docker)[https://github.com/NVIDIA/nvidia-docker] repository and install their wrapper, that will let you use GPU within a docker container.
    
# How To
To build the images simply run
```
git clone https://github.com/mpekalski/MLDocker && \
cd MLDocker && \
chmod 755 build_tf_docker.sh && \
./build_tf_docker.sh
```
That will build three images `tf:00`, `tf:01`, `tf:02`. First image is based on `nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04`. The reasons for having multiple images instead of only one are simple. Firstly, during the build you have no access to the GPU, even when using `nvidia-docker`. So I build some image first, then start a container, launch tensorflow compilation within it, then stop the container, commit it (i.e, create an image from container) and continue with adding more libraries. In particular I first build protobuf, OpenCV and Tensorflow before installing Anaconda, because the latter when added to paths screws a lot of stuff with libraries during compilation. So, it is just easier not to have it at all and then just install the compiled packages after installing Anaconda.

The container you will run spawns all necessary processes using supervisor on top of tiny - the reason for tiniy is not to have any dangling processes after removing the container, and supervisor is used to be able to run more than one process within the container.

After the build finishes the last docker image will be launched and also you will see the terminal with bash (runnin within container). The container exposes two ports `8000` and `6006`, the first one lets you access `JupyterHub`, and the latter `Tensorboard`. Just above the bash prompt within the container you should see the ip address of the just launched container, so you would know where to point your browser to in order to connect to JupyterHub or Tensorboard.

You can get the IP address anytime by running:
```
docker inspect $(docker ps -a | grep tf:02 | awk {'print$1'}) | grep \"IPAddress
```
It assumes you run image `tf:02`.

The command used for running the final image 
```
nvidia-docker run -d --ipc=host -v /etc/passwd:/etc/passwd:ro -v /etc/shadow:/etc/shadow:ro -v /home/$USER:/home/$USER --name tf tf:02
```
maps `passwd` and `shadow` form the host machine to the container, so you could use your regular username and password. They are mapped as read-only, so although everything in the container is run as root the content of those cannot be altered. Also, the working dir has been set to the logged-in user's home folder, that has been mapped as writable. It also will be the default directory for jupyter notebook.

Tensorboard by default will read model's data from `/models`, which can be mapped to a host folder (similiarily to passwd and shadow folders) or changed to a different direcotry, please see `start-tensorboard.sh`.

It probably will take a couple of hours for everything to get build.
# To do
- change ENV to ARG, so versions of packages could be set by passing env variables to docker during the build
- make sure CUDA version is propagated eveywhere throught the ENV variable
- add more kernels, R, scala
- install local instance of Spark 
- make it more secure, because as for now everything in docker runs as root, and the docker process on the host machine also runs as root
- add https, self signed certificates (?) to run on local
- add jupyter notebook extensions
- add opencv_contrib to opencv (DOPENCV_EXTRA_MODULES_PATH)
- add GDCM to opencv
- remove pip3 install six numpy wheel from tf_00
- add CAFFE 2.0 (before OpenCV) when it starts supporting python 3
- add PyTorch
- check MKLROOT
- PYLINT before OpenCV
- Glog not found by OpenCV
- add FFM
- add snappy