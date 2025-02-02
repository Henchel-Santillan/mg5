# Docker

To install docker on your system, execute the `setup_docker.sh` script, which follows exactly the installation steps using `apt` for [Ubuntu](https://docs.docker.com/engine/install/ubuntu/):

```
chmod +x scripts/setup_docker.sh
sudo ./setup_docker.sh
```

To avoid always using `sudo` with `docker` commands, add your user to the `docker` group. Note that the above script will automatically create the docker group.

```
sudo usermod -aG docker $USER
newgrp docker
```

Test with the `hello-world` image:

```
docker run hello-world
```


## Docker Image
**Pull** the docker image from the public DockerHub repository [here](https://hub.docker.com/repository/docker/sandvichedibledevice/mg5/general), which can be done without authentication or a DockerHub account (subject to rate limiting):

```
docker pull sandvichedibledevice/mg5:<TAG>
docker run -it -v <ABSOLUTE_PATH_TO_THIS_REPOSITORY>:/workspace/mg5 sandvichedibledevice/mg5:<TAG>
```

`sandvichedibledevice` is my DockerHub username. `docker run` is used with the `-v` option to mount the local repository into the container instance.

Changes made to the Dockerfile must be captured by building, tagging, and pushing the new changes to the image. **This step will require a DockerHub account.** When setting up your DockerHub account, it is recommended to use a passkey for more convenient authentication. Assuming you are in the `docker` directory:

```
docker login -u <USERNAME>
docker build -t <USERNAME>/mg5:<TAG> .
docker push <USERNAME>/mg5:<TAG>
```

To test changes made to the Dockerfile (during development):

```
docker build -t <USERNAME>/mg5:<TAG> .
docker run <USERNAME>/mg5:<TAG>
```

N.B. Please always use the image name `mg5` for `<IMAGE>`, and always use an incrementing integer for `<TAG>` (preferably +1 from the previous tag), i.e. the first tag is 1, the second tag would be 2, etc. Note that the first `mg5` is the name of the DockerHub repository.

N.B.++ The container contains simulation and debug tools (such as the PX4 SITL) and is intended for developer use only. The setup script for the companion computer can be found at the root of this repository. If developing on a virtual machine or partition, it is recommended to reserve at least 40 GB of disk space.

<br>
TODO: Integrate docker image management and distribution into a CI/CD system
