# container to build
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app

# copy project into container
COPY pom.xml .
COPY src ./src

# compile
RUN mvn clean package -DskipTests

# container to run
FROM eclipse-temurin:25-jre
WORKDIR /app

# Install SWI-Prolog
RUN apt-get update \
    && apt-get install -y --no-install-recommends swi-prolog-nox \
    && rm -rf /var/lib/apt/lists/*

# copy compiled jar
COPY --from=build /app/target/*.jar app.jar

# copy the prolog scripts
COPY prolog ./prolog

# execute
ENTRYPOINT ["java", "-jar", "app.jar"]