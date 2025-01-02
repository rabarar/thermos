# Use a more recent and secure Python base image
FROM python:3.11-slim AS base

# Set a non-root user for better security
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc build-essential libssl-dev libffi-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Use a virtual environment to isolate dependencies
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install dependencies early to leverage caching
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Multi-stage build for a smaller final image
FROM python:3.11-slim AS app

# Copy the virtual environment from the base stage
COPY --from=base /app/venv /app/venv

# Set working directory and environment
WORKDIR /app
ENV PATH="/app/venv/bin:$PATH"

# Copy application files
COPY main.py devices.py ./

# Specify the default command
CMD ["python", "-u", "main.py"]
