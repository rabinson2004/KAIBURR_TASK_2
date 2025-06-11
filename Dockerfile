# Stage 1: Build React app (Create React App assumed)
FROM node:22 AS frontend-builder

WORKDIR /app
COPY frontend/ /app/
RUN npm install && npm run build

# Stage 2: Build Spring Boot app
FROM eclipse-temurin:21 AS backend-builder

WORKDIR /app
COPY backend/ /app/
COPY --from=frontend-builder /app/dist /app/src/main/resources/static

RUN apt-get update && apt-get install -y maven && \
    mvn clean package -DskipTests

# Stage 3: Run Spring Boot app
FROM eclipse-temurin:21-jre

WORKDIR /app
COPY --from=backend-builder /app/target/rabin-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
