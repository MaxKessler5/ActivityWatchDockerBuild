# Goal: Reproduce problems building activity watch from source 
By building ActivityWatch in a docker container, I can ensure that the environment is consistent and that I have all the necessary dependencies installed. 
Then I can document the process and any errors I encounter, along with their solutions, in this document.

My most recent build output from running docker run activitywatch-build is in most_recent_build_output.txt

## Stages

1. **Dependencies Stage**: Installs all necessary dependencies and runs a custom Python script to verify the commands associated with those dependencies are working
2. **Build Stage**: Builds the project using `make build` and logs the output.
3. **Final Stage**: Prepares the final image to run ActivityWatch: won't work, but a starting point for trying to get the project to run in a container

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

To build the final image which only contains the built application (if the goal is to work on making the project run inside a container):
```sh
docker build -t activitywatch .
docker run -p 5600:5600 activitywatch
```

# Errors and attempted solutions

* "pyproject.toml changed significantly since poetry.lock was last generated. Run `poetry lock` to fix the lock file."
    I try exactly what the error message says, get another error: 
    "
    The current project's supported Python range (>=3.8,<4.0) is not compatible with some of the required packages Python requirement:
    21.33   - pyinstaller requires Python <3.13,>=3.8, so it will not be satisfied for Python >=3.13,<4.0" 
    But the suggestion in this second error does work and allows me to build!

*   PEP517 build of a dependency failed
    I will try running poetry lock in /activitywatch/aw-watcher-afk and see if that helps.


