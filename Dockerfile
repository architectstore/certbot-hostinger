FROM certbot/certbot:latest

# Install Hostinger DNS plugin
RUN pip install --no-cache-dir certbot-dns-hostinger

# Add entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
