before running "docker-compose up" execute the following command:

docker volume create jenkins_data

do not forget to create an in bound firewall rule to allow tcp connection on port 8080