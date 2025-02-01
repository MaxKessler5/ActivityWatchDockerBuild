# Goal: Reproduce problems building activity watch from source 
By building ActivityWatch in a docker container, I can ensure that the environment is consistent and that I have all the necessary dependencies installed. 
Then I can document the process and any errors I encounter, along with their solutions, in this document.

# Errors and attempted solutions

* "pyproject.toml changed significantly since poetry.lock was last generated. Run `poetry lock` to fix the lock file."
    I try exactly what the error message says, get another error: 
    "
    The current project's supported Python range (>=3.8,<4.0) is not compatible with some of the required packages Python requirement:
    21.33   - pyinstaller requires Python <3.13,>=3.8, so it will not be satisfied for Python >=3.13,<4.0" 
    But the suggestion in this second error does work and allows me to build!

*   PEP517 build of a dependency failed
    I will try running poetry lock in /activitywatch/aw-watcher-afk and see if that helps.



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
I'm pretty sure this part works, looks like it can run all the terminal comands it's supposed to.

To run up to the build stage and see the output from Make build:
```sh
docker build --target builder -t activitywatch-build .
docker run activitywatch-build
```
I haven't been able to build the project yet, so if this works, the problem 
is my machine, and this repo is a success!

To build the final image which only contains the built application:
```sh
docker build -t activitywatch .
docker run -p 5600:5600 activitywatch
```
This is just something to try to see if the project can run from a container, and see what happens. I don't expect it to work, it's like a stretch goal
