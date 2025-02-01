# Disclaimer: This doesn't work yet
As of 1/31/25 I can only build the first stage so far,
not actually sure if this is possible or not

# ActivityWatch Docker Setup

This repository contains the Docker setup for building and running ActivityWatch. The Dockerfile is divided into multiple stages to handle dependencies, building, and running the application.

## Stages

1. **Dependencies Stage**: Installs all necessary dependencies and runs a custom Python script to check the environment.
2. **Build Stage**: Builds the project using `make build` and logs the output.
3. **Final Stage**: Prepares the final image to run ActivityWatch.

## How to use different stages

To build the Docker image up to the dependencies stage and check the environment:
```sh
docker build --target dependencies -t activitywatch-deps .
docker run activitywatch-deps
```
To run up to the build stage and see the output from Make build:
```sh
docker build --target build -t activitywatch-build .
docker run activitywatch-build
```
To build the final image which only contains the built application:
```sh
docker build -t activitywatch .
docker run -p 5600:5600 activitywatch
```
