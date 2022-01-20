#https://guides.grails.org/grails-as-docker-container/guide/index.html
#https://www.jetbrains.com/help/idea/running-a-java-app-in-a-container.html
#https://stackoverflow.com/questions/65431299/how-do-i-install-grails-in-a-docker-image

#FROM adoptopenjdk/openjdk8
#MAINTAINER Brandon Paxton "bpaxton@talentplus.com"
#
#EXPOSE 8080
#
#WORKDIR /app
#COPY C:/Repo/tbcore/grails-app/init/com/talentbank/core/Application.groovy /app/Application.groovy
#
##CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "/app/tbcore-7.23-SNAPSHOT.jar"]
#CMD ["java","-Dgrails.env=dev","-jar", "/app/Application.groovy"]


# Image to start project and initialize dependencies.
FROM openjdk:8 AS initializer
ENV GRAILS_VERSION 3.3.14
EXPOSE 18080
# Install Grails
WORKDIR /usr/lib/jvm
RUN ls -l
RUN wget https://github.com/grails/grails-core/releases/download/v$GRAILS_VERSION/grails-$GRAILS_VERSION.zip && \
    unzip grails-$GRAILS_VERSION.zip && \
    rm -rf grails-$GRAILS_VERSION.zip && \
    ln -s grails-$GRAILS_VERSION grails
# Setup Grails path.
ENV GRAILS_HOME /usr/lib/jvm/grails
ENV PATH $GRAILS_HOME/bin:$PATH
ENV GRADLE_USER_HOME /app/.gradle
# Create minimal structure to trigger grails build with specified profile.
RUN mkdir /app \
    && mkdir /app/grails-app \
    && mkdir /app/grails-app/conf 
# Set Workdir
WORKDIR /app
# Copy minimun files to trigger grails download of wrapper and dependencies.
COPY gradle.properties build.gradle settings.gradle  gradlew.bat grailsw.bat /app/
COPY gradle /app/gradle
# Trigger gradle build
RUN [ "grails", "stats" ]

# Implemented to improve cache in CI
FROM initializer as development
# Copy source code
COPY grails-app /app/grails-app
COPY src /app/src
#ENTRYPOINT [ "./gradlew.bat", "build" ]
# Set Default Behavior
ENV DOCKER_GET_LOCAL_HOST_IP="host.docker.internal"
ENTRYPOINT [ "grails","dev", "run-app", "--stacktrace-verbose"]
CMD [ "" ]
