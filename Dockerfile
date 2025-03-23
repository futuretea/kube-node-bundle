FROM --platform=linux/amd64 python:3.9-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Create necessary directories and set permissions
RUN mkdir -p /root/.kube /root/.ssh

# Default command
CMD ["bash"]