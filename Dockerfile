# Stage 1: Install Dependencies
FROM ubuntu:20.04 AS dependencies

# Set environment variables to non-interactive for apt

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies that (probably) don't need a version pinnedm some are just to build old python from source
RUN apt-get update && apt-get install -y \
    git \
    curl \
    gnupg \
    make \
    wget build-essential libreadline-dev libsqlite3-dev \
    zlib1g-dev libbz2-dev libffi-dev libssl-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*   

# Download and install Python 3.9.21 exactly
RUN cd /usr/src \
    && wget https://www.python.org/ftp/python/3.9.21/Python-3.9.21.tgz \
    && tar xvf Python-3.9.21.tgz \
    && cd Python-3.9.21 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall 


# Install Poetry 1.3.2 exactly
RUN pip3 install poetry==1.3.2


# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && /root/.cargo/bin/rustup update nightly \
    && /root/.cargo/bin/rustup default nightly

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone my fork of the ActivityWatch repository and its submodules
RUN git clone --recursive https://github.com/MaxKessler5/activitywatch.git /activitywatch

# Set working directory
WORKDIR /activitywatch

# Venv activation the Docker way: set the same env vars activate does
# Need to repeat this if a stage doesn't start with FROM as previous-stage
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
# Use the pinned version of python to create the venv
RUN /usr/src/Python-3.9.21/python -m venv $VIRTUAL_ENV

# Copy the custom test script
COPY test_commands.py /activitywatch/test_commands.py

# Run test script and log output
RUN python3 test_commands.py > dependency_check.log

# Set the entry point to display the dependency check log
ENTRYPOINT ["cat", "dependency_check.log"]

# ------------------------------
# Stage 2: Build Project
# ------------------------------
FROM dependencies AS builder

# Set working directory
WORKDIR /activitywatch
RUN python3 test_commands.py > dependency_check.log

# CD into aw-qt and run poetry lock
WORKDIR /activitywatch/aw-qt
RUN poetry lock

WORKDIR /activitywatch
# Install project dependencies and build the project
RUN make build > build.log || { echo 'Build failed, check build.log for details'; cat build.log; exit 1; }
# Set the entry point to display the build log
RUN cat dependency_check.log && cat build.log
ENTRYPOINT ["cat", "dependency_check.log", "build.log"]

# ------------------------------
# Stage 3: Final Image
# ------------------------------
FROM ubuntu:20.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3.9 \
    && rm -rf /var/lib/apt/lists/*

# Copy the built project from the builder stage
COPY --from=builder /activitywatch /activitywatch

# Set working directory
WORKDIR /activitywatch

# Expose the port used by ActivityWatch
EXPOSE 5600

# Define the entry point to run ActivityWatch
ENTRYPOINT ["/activitywatch/venv/bin/aw-qt"]