import subprocess
import sys

if sys.prefix != sys.base_prefix:
    print("Running inside a virtual environment")
else:
    print("Not inside a virtual environment")
    with open("dependency_check.log", "w") as log_file:
        log_file.write("Not running inside a virtual environment)\n")
    # throw an error if not running inside a virtual environment
    sys.exit(1)



commands = [
    "git --version",
    "python3 --version",
    "poetry --version",
    "node --version",
    "npm --version",
    "rustc --version",
    "cargo --version",
    "make --version"
]

with open("dependency_check.log", "w") as log_file:
    for command in commands:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        log_file.write(f"Command: {command}\n")
        log_file.write(f"Output: {result.stdout.strip()}\n")
        log_file.write(f"Error: {result.stderr.strip()}\n")
        log_file.write("-" * 40 + "\n")
