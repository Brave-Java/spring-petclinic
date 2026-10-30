# Spring PetClinic Sample Application

[![Maven build](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml)
[![Gradle build](https://github.com/spring-projects/spring-petclinic/actions/workflows/gradle-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/gradle-build.yml)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/spring-projects/spring-petclinic) [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=7517918)

Spring PetClinic is a sample veterinary clinic application built with Spring Boot. Use it to explore the Spring ecosystem, or run it locally and manage owners, pets, visits, and veterinarians.

**Get started:** install Java 17 or newer, clone the repository, run the app with Maven or Gradle, then open <http://localhost:8080/>.

## Contents

- [Run the application](#run-the-application)
- [Use a database](#use-a-database)
- [Build and run a container](#build-and-run-a-container)
- [Develop and test](#develop-and-test)
- [Find your way around the code](#find-your-way-around-the-code)
- [Contribute](#contribute)
- [License](#license)

## Understanding the Spring Petclinic application with a few diagrams

See the presentation here:  
[Spring Petclinic Sample Application (legacy slides)](https://speakerdeck.com/michaelisvy/spring-petclinic-sample-application?slide=20)

> **Note:** These slides refer to a legacy, pre–Spring Boot version of Petclinic and may not reflect the current Spring Boot–based implementation.  
> For up-to-date information, please refer to this repository and its documentation.


## Run the application

You need [Java 17 or newer](https://adoptium.net/) and Git. The project includes Maven and Gradle wrappers, so you do not need to install either build tool.

1. Clone the repository and enter its directory:

```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
```

2. Start the application with either build tool:

**Maven**

```bash
./mvnw spring-boot:run
```

**Gradle**

```bash
./gradlew bootRun
```

3. Open <http://localhost:8080/> in your browser. The app uses an in-memory H2 database by default and loads sample data at startup.

<img width="1042" alt="petclinic-screenshot" src="https://cloud.githubusercontent.com/assets/838318/19727082/2aee6d6c-9b8e-11e6-81fe-e889a5ddfded.png">

You can also run the app from your IDE; see [Develop and test](#develop-and-test).

## Build and run a container

This repository includes a [Dockerfile](Dockerfile) and a Compose setup for PetClinic with PostgreSQL. The database data is stored in a named volume. Start the application and database from the repository root:

```bash
docker compose up --build server postgres
```

Open <http://localhost:8080/> to use the application. Press `Ctrl+C` to stop it. To run the app and PostgreSQL in the background instead, use `docker compose up --build -d server postgres`; stop the services with `docker compose down`. The named database volume is retained unless you explicitly remove volumes. The `mysql` service is available separately and is not needed for this setup.

If port 8080 is already in use, set an alternate host port, for example `PETCLINIC_PORT=8081 docker compose up --build server postgres`, then open <http://localhost:8081/>.

### Develop with Docker Compose

The Compose app service targets the Dockerfile's `development` stage, which enables a remote JVM debugger on port 8000. Start the app and PostgreSQL with automatic rebuilds when source or build files change:

```bash
PETCLINIC_PORT=8081 docker compose watch server postgres
```

Open <http://localhost:8081/>. To attach a remote debugger in your IDE, use host `localhost` and port `8000`. Press `Ctrl+C` to stop Compose Watch, or run `docker compose down` in another terminal. The PostgreSQL data volume is retained when you run `down`.

## Use a database

By default, PetClinic uses an in-memory [H2](https://www.h2database.com/) database. It is populated with sample data at startup and resets when the app stops. To inspect it, open <http://localhost:8080/h2-console> and use the `jdbc:h2:mem:<uuid>` URL printed in the application startup log.

MySQL and PostgreSQL profiles are also available. Start the database, then run PetClinic with the matching Spring profile.

### MySQL

Start a local MySQL server with your preferred installer, or run it in Docker:

```bash
docker run -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:9.7
```

In another terminal, start the application with the MySQL profile:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=mysql
```

### PostgreSQL

```bash
docker run -e POSTGRES_USER=petclinic -e POSTGRES_PASSWORD=petclinic -e POSTGRES_DB=petclinic -p 5432:5432 postgres:18.4
```

In another terminal, start the application with the PostgreSQL profile:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=postgres
```

The Gradle equivalent is `./gradlew bootRun --args='--spring.profiles.active=mysql'` (replace `mysql` with `postgres` as needed). For profile configuration details, see the [Spring Boot documentation](https://docs.spring.io/spring-boot/how-to/properties-and-configuration.html#howto.properties-and-configuration.set-active-spring-profiles).

Database setup guides: [MySQL](src/main/resources/db/mysql/petclinic_db_setup_mysql.txt) · [PostgreSQL](src/main/resources/db/postgres/petclinic_db_setup_postgres.txt).

Alternatively, use the included Docker Compose file to start a database:

```bash
docker compose up mysql
```

or

```bash
docker compose up postgres
```

## Develop and test

### Run from an IDE

Import the project into your preferred IDE. Java 17 or newer, Git, and a full JDK are required.

- **Eclipse or Spring Tools Suite:** Import the root directory as an existing Maven project. Run `./mvnw generate-resources` to generate CSS, then run `PetClinicApplication` as a Java application.
- **IntelliJ IDEA:** Open the root [pom.xml](pom.xml). Run `./mvnw generate-resources` to generate CSS, then run `PetClinicApplication`.
- **VS Code:** Open the repository folder and use the Java extensions to run the application.

### Run integration tests

The test applications also have `main()` methods for quick IDE feedback: `PetClinicIntegrationTests` uses H2 and Spring Boot Devtools, while the MySQL and PostgreSQL integration tests exercise their respective databases. MySQL tests use Testcontainers; PostgreSQL tests use Docker Compose. Docker must be running for those database integration tests.

Run the full test suite with Maven or Gradle:

```bash
./mvnw test
```

```bash
./gradlew test
```

### Compile CSS changes

There is a `petclinic.css` in `src/main/resources/static/resources/css`. It was generated from the `petclinic.scss` source, combined with the [Bootstrap](https://getbootstrap.com/) library. If you make changes to the `scss`, or upgrade Bootstrap, you will need to re-compile the CSS resources using the Maven profile "css", i.e. `./mvnw package -P css`. There is no build profile for Gradle to compile the CSS.

## Find your way around the code

|Spring Boot Configuration | Class or Java property files  |
|--------------------------|---|
|The Main Class | [PetClinicApplication](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java) |
|Properties Files | [application.properties](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources) |
|Caching | [CacheConfiguration](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/system/CacheConfiguration.java) |

## Other PetClinic implementations

The Spring Petclinic "main" branch in the [spring-projects](https://github.com/spring-projects/spring-petclinic)
GitHub org is the "canonical" implementation based on Spring Boot and Thymeleaf. There are
[quite a few forks](https://spring-petclinic.github.io/docs/forks.html) in the GitHub org
[spring-petclinic](https://github.com/spring-petclinic). If you are interested in using a different technology stack to implement the Pet Clinic, please join the community there.

## Open-source contributions

One of the best parts about working on the Spring Petclinic application is that we have the opportunity to work in direct contact with many Open Source projects. We found bugs/suggested improvements on various topics such as Spring, Spring Data, Bean Validation and even Eclipse! In many cases, they've been fixed/implemented in just a few days.
Here is a list of them:

| Name | Issue |
|------|-------|
| Spring JDBC: simplify usage of NamedParameterJdbcTemplate | [SPR-10256](https://github.com/spring-projects/spring-framework/issues/14889) and [SPR-10257](https://github.com/spring-projects/spring-framework/issues/14890) |
| Bean Validation / Hibernate Validator: simplify Maven dependencies and backward compatibility |[HV-790](https://hibernate.atlassian.net/browse/HV-790) and [HV-792](https://hibernate.atlassian.net/browse/HV-792) |
| Spring Data: provide more flexibility when working with JPQL queries | [DATAJPA-292](https://github.com/spring-projects/spring-data-jpa/issues/704) |

## Contribute

Use the [issue tracker](https://github.com/spring-projects/spring-petclinic/issues) for bug reports and feature requests. Pull requests are welcome.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <https://editorconfig.org>. All commits must include a __Signed-off-by__ trailer at the end of each commit message to indicate that the contributor agrees to the Developer Certificate of Origin.
For additional details, please refer to the blog post [Hello DCO, Goodbye CLA: Simplifying Contributions to Spring](https://spring.io/blog/2025/01/06/hello-dco-goodbye-cla-simplifying-contributions-to-spring).

## License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
