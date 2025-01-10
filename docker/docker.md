# Docker

To install docker on your system, execute the `setup_docker.sh` script:

```
chmod +x scripts/setup_docker.sh
./setup_docker.sh
```

## Docker Image
**Pull** the docker image [here](), which can be done without authentication or a DockerHub account (subject to rate limiting):

```
docker pull mg5
```

Changes made to the Dockerfile must be captured by building, tagging, and pushing the new changes to the image. **This step will require a DockerHub account.**

```
docker build mg5 -t <TAG>
docker push
```

N.B. Please use the image name `mg5`, and use an incrementing integer for \<TAG\> (preferably +1 from the previous tag). 

<br>
TODO: Integrate docker image management and distribution into a CI/CD system
