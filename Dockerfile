# syntax=docker/dockerfile:1

# Resolve and download dependencies.
FROM eclipse-temurin:21-jdk-jammy AS deps

WORKDIR /build

COPY --chmod=0755 mvnw mvnw
COPY .mvn/ .mvn/

RUN --mount=type=bind,source=pom.xml,target=pom.xml \
    --mount=type=cache,target=/root/.m2 ./mvnw dependency:go-offline -DskipTests

# Run the Java test suite in a dedicated build target.
FROM deps AS test

WORKDIR /build

COPY ./src src/
RUN --mount=type=bind,source=pom.xml,target=pom.xml \
    --mount=type=cache,target=/root/.m2 \
    ./mvnw test

# Build the application.
FROM deps AS package

WORKDIR /build

COPY ./src src/
RUN --mount=type=bind,source=pom.xml,target=pom.xml \
    --mount=type=cache,target=/root/.m2 \
    ./mvnw package -DskipTests && \
    mv target/$(./mvnw help:evaluate -Dexpression=project.artifactId -q -DforceStdout)-$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout).jar target/app.jar

# Extract Spring Boot layers for efficient image caching.
FROM package AS extract

WORKDIR /build

RUN java -Djarmode=tools -jar target/app.jar extract --layers --destination target/extracted

# Development image with a remote JVM debugger enabled.
FROM extract AS development

WORKDIR /application

RUN cp -r /build/target/extracted/dependencies/. ./ && \
    cp -r /build/target/extracted/spring-boot-loader/. ./ && \
    cp -r /build/target/extracted/snapshot-dependencies/. ./ && \
    cp -r /build/target/extracted/application/. ./

ENV JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"

EXPOSE 8080 8000

CMD ["java", "-jar", "app.jar"]

# Run the application as a non-root user.
FROM eclipse-temurin:21-jre-jammy AS final

WORKDIR /application

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

COPY --from=extract build/target/extracted/dependencies/ ./
COPY --from=extract build/target/extracted/spring-boot-loader/ ./
COPY --from=extract build/target/extracted/snapshot-dependencies/ ./
COPY --from=extract build/target/extracted/application/ ./

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
