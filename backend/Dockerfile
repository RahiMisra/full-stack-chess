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

# copy compiled jar
COPY --from=build /app/target/*.jar app.jar

# execute
ENTRYPOINT ["java", "-jar", "app.jar"]