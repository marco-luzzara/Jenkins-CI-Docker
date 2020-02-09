run the following command before creating the container

docker volume create versioning_projects





To build the image:

docker build -t versioning_server .
docker run -p 9001:9001 -v versioning_projects:/usr/src/app/projects versioning_server





do not forget to create an in bound firewall rule to allow tcp connection on port 9001