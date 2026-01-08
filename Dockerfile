# ---- Build stage ----
FROM eclipse-temurin:21-jdk-noble AS build
WORKDIR /app

# Copie juste ce qu'il faut pour "cacher" les dépendances
COPY pom.xml .
COPY mvnw .
COPY .mvn ./.mvn

# Le wrapper doit être exécutable dans Linux
RUN chmod +x mvnw && ./mvnw -q -DskipTests dependency:go-offline

# Copie du code puis build
COPY src ./src
RUN ./mvnw -q -DskipTests package

# ---- Run stage ----
FROM eclipse-temurin:21-jre-noble
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
