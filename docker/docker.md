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
**Pull** the docker image [here](), which can be done without authentication or a DockerHub account (subject to rate limiting):

```
docker pull sandvichedibledevice/mg5
```

`sandvichedibledevice` is my DockerHub username. The DockerHub repository is public and can be found [here](https://hub.docker.com/repository/docker/sandvichedibledevice/mg5/general).

Changes made to the Dockerfile must be captured by building, tagging, and pushing the new changes to the image. **This step will require a DockerHub account.** When setting up your DockerHub account, it is recommended to use a passkey for more convenient authentication. Assuming you are in the `docker` directory:

```
docker login
docker tag <your_docker_username>/mg5:<TAG>
docker push <your_docker_username>/mg5:<TAG>
```

To test changes made to the Dockerfile (during development):

```
docker build -t <your_docker_username>/mg5:<TAG> .
docker run <your_docker_username>/mg5:<TAG>
```

N.B. Please always use the image name `mg5` for `<IMAGE>`, and always use an incrementing integer for `<TAG>` (preferably +1 from the previous tag), i.e. the first tag is 1, the second tag would be 2, etc. Note that the first `mg5` is the name of the DockerHub repository.

<br>
TODO: Integrate docker image management and distribution into a CI/CD system
