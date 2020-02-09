FROM mcr.microsoft.com/dotnet/core/sdk:2.2

# https://stackoverflow.com/questions/31196567/installing-java-in-docker-image#answer-44058196
# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN apt-get -y update && \
	apt-get -y install curl

# read here: https://pagure.io/fork/simo/gssntlmssp to configure NTLM_USER_FILE
RUN apt-get -y install gss-ntlmssp && \
	touch /etc/gss/mech.d/credentials && \
	chmod 777 /etc/gss/mech.d/credentials && \
	echo :user:pwd > /etc/gss/mech.d/credentials
	
ENV NTLM_USER_FILE /etc/gss/mech.d/credentials
RUN export NTLM_USER_FILE

RUN apt-get -y install curl software-properties-common && \
	curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
	apt-get -y install nodejs
	
RUN npm install -g newman
RUN npm install -g postman-combine-collections

# to run xmllint
RUN apt-get -y install libxml2-utils

COPY /install_files/agent.jar /agent.jar

COPY /install_files/NuGet.Config /root/.config/NuGet/

ENTRYPOINT ["java", "-jar", "/agent.jar"]
CMD ["-jnlpUrl", "http://host.docker.internal:8080/computer/unix00/slave-agent.jnlp", "-secret", "yoursecret", "-workDir", "'/home/jenkins'"]