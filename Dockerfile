# Stage 1: Install Dependencies
FROM ubuntu:20.04 AS dependencies

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.9 \
    python3.9-venv \
    python3-pip \
    curl \
    gnupg \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && /root/.cargo/bin/rustup update nightly \
    && /root/.cargo/bin/rustup default nightly

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone the ActivityWatch repository and its submodules
RUN git clone --recursive https://github.com/ActivityWatch/activitywatch.git /activitywatch

# Set working directory
WORKDIR /activitywatch

# Venv activation the Docker way: set the same env vars activate does
ENV VIRTUAL_ENV=/opt/venv
RUN python3.9 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Poetry into the venv
RUN pip install poetry

# Copy the custom test script
COPY test_commands.py /activitywatch/test_commands.py

# Run test script and log output
RUN python3 test_commands.py > dependency_check.log

# Set the entry point to display the dependency check log
ENTRYPOINT ["cat", "dependency_check.log"]

# Stage 2: Build Project
FROM dependencies AS builder

# Set working directory
WORKDIR /activitywatch

# CD into aw-qt and run poetry lock
WORKDIR /activitywatch/aw-qt
RUN poetry lock

# Install project dependencies and build the project
RUN make build > build.log || { echo 'Build failed, check build.log for details'; cat build.log; exit 1; }
# Set the entry point to display the build log

ENTRYPOINT ["cat", "build.log"]

# Stage 3: Final Image
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