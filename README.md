
# Task-2 KUBERNETES

This guide explains how to containerize and run your **full-stack Task Manager application** using Docker and Docker Compose. The stack includes:

* **Spring Boot** for the backend
* **React** for the frontend
* **MongoDB** as the database

---

## Project Structure

```
.
├── backend/                # Spring Boot Backend (Java, Maven)
│   └── src/, pom.xml, etc.
├── frontend/               # React Frontend
│   └── public/, src/, package.json, etc.
├── Dockerfile              # Multi-stage build for frontend + backend
├── docker-compose.yml      # Docker Compose configuration
```

---

##  Dockerfile (Multi-stage Build)

```Dockerfile
# Stage 1: Build React app
FROM node:22 AS frontend-builder
WORKDIR /app
COPY frontend/ /app/
RUN npm install && npm run build

# Stage 2: Build Spring Boot app
FROM eclipse-temurin:21 AS backend-builder
WORKDIR /app
COPY backend/ /app/
COPY --from=frontend-builder /app/build /app/src/main/resources/static
RUN apt-get update && apt-get install -y maven && \
    mvn clean package -DskipTests

# Stage 3: Run the final Spring Boot app
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=backend-builder /app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

---

##  `docker-compose.yml`

```yaml
version: "3.8"

services:
  backend:
    build:
      context: .
    ports:
      - "8080:8080"
    depends_on:
      - mongodb
    environment:
      SPRING_DATA_MONGODB_URI: mongodb://mongodb:27017/rabin-db
    networks:
      - app-network

  mongodb:
    image: mongo:latest
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    networks:
      - app-network

networks:
  app-network:

volumes:
  mongo-data:
```

---

##  How to Run the Application

### 1. Build and Start All Services

```bash
docker-compose up --build
```

>  This will build the React frontend, Spring Boot backend, and start MongoDB in containers.

---

##  Access Points

* **Web Application:**
  [http://localhost:8080](http://localhost:8080)

* **Test API (example: fetch tasks):**

  ```bash
  curl http://localhost:8080/tasks
  ```

* **MongoDB GUI (Optional):**
  Use [MongoDB Compass](https://www.mongodb.com/products/compass) or any MongoDB client to connect to:

  ```
  mongodb://localhost:27017
  ```

---
