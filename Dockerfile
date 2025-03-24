# Use the latest Ubuntu image as the base
FROM ubuntu:latest

# Update package lists and install necessary dependencies
RUN apt-get update && apt-get install -y wget gpg apt-transport-https sudo

# Add Microsoft VS Code repository
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg

# Update package cache and install VS Code without recommended packages
RUN apt-get update && apt-get install --no-install-recommends -y code

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create config directory
RUN mkdir /config

# Create vscode user, set homedir to /config, and add to sudo group without password
RUN useradd -ms /bin/bash -d /config vscodeuser && \
    usermod -aG sudo vscodeuser && \
    echo "vscodeuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscodeuser

# Expose the port
EXPOSE 8080

# Run the command.
CMD ["code", "serve-web", "--host", "0.0.0.0", "--port", "8080"]
