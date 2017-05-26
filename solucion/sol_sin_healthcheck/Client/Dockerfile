# Base image
FROM httpd:2.2 

# Copy the public key from host machine
ADD keys/public.asc /tmp
# Add the entrypoint
ADD /conf/Entrypoint.sh /scripts/Entrypoint.sh

# Import and delete the public key 
RUN apt-key add /tmp/public.asc \
    && rm -f /tmp/public.asc \

# Change privileges
    && chmod +x /scripts/Entrypoint.sh \

# Updated and installed 
    && apt-get update && apt-get install -y \
    curl

# Set directory
WORKDIR /scripts

# Entry point command
CMD ["./Entrypoint.sh"]
