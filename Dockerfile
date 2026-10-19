
# GIAI DOAN 1: BUILD MAVEN WAR
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Tai dependencies
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source code va build
COPY src ./src
RUN mvn -B clean package -DskipTests


# GIAI DOAN 2: CHAY TOMCAT 10.1
FROM tomcat:10.1-jdk17

# Xoa ung dung mac dinh
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy WAR thanh ung dung goc
COPY --from=build /build/target/apartment-web.war /usr/local/tomcat/webapps/ROOT.war

# Cong HTTP
EXPOSE 8080

# Khoi dong Tomcat
CMD ["catalina.sh", "run"]
