# Goal: Reproduce problems building activity watch from source 
By building ActivityWatch in a docker container, I can ensure that the environment is consistent and that I have all the necessary dependencies installed. 
Then I can document the process and any errors I encounter, along with their solutions, in this document.

# Errors and attempted solutions

* "pyproject.toml changed significantly since poetry.lock was last generated. Run `poetry lock` to fix the lock file."
    I try exactly what the error message says, seems to work

* 



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
docker build --target builder -t activitywatch-build .
docker run activitywatch-build
```
To build the final image which only contains the built application:
```sh
docker build -t activitywatch .
docker run -p 5600:5600 activitywatch
```
