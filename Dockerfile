FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update system and install required packages
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    freeradius \
    freeradius-mysql \
    freeradius-utils \
    nginx \
    sudo \
    systemctl \
    cron \
    vim \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a user with sudo privileges for the scripts
RUN useradd -m -s /bin/bash watni && \
    echo "watni ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -a -G freerad watni

# Create necessary directories
RUN mkdir -p /var/log/freeradius/radacct && \
    chown -R freerad:freerad /var/log/freeradius && \
    chmod -R 755 /var/log/freeradius

# Copy the scripts to the container
COPY --chown=watni:watni . /home/watni/watni-radius/
WORKDIR /home/watni/watni-radius

# Make scripts executable
RUN chmod +x *.sh

# Initialize MariaDB and create necessary directories
RUN service mariadb start && \
    sleep 5 && \
    mysql -e "CREATE DATABASE IF NOT EXISTS radius;" && \
    mysql -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';" && \
    mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;" && \
    service mariadb stop

# Create startup script
RUN cat > /home/watni/start-services.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting MariaDB..."
service mariadb start
sleep 3

echo "Starting FreeRADIUS..."
service freeradius start || true
sleep 2

echo "Starting Nginx..."
service nginx start

echo "All services started. Keeping container running..."
tail -f /var/log/freeradius/radius.log /var/log/mariadb/error.log /var/log/nginx/access.log 2>/dev/null || sleep infinity
EOF

RUN chmod +x /home/watni/start-services.sh

# Switch to watni user
USER watni

# Expose RADIUS ports and HTTP
EXPOSE 1812/udp 1813/udp 80/tcp

# Start services
CMD ["/home/watni/start-services.sh"]