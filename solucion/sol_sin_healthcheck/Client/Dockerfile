FROM httpd:2.2 # Base Image 
# Copy the public key from host machine
ADD keys/public.asc /tmp
# Import and delete the public key 
RUN apt-key add /tmp/public.asc
RUN rm -f /tmp/public.asc
# Add the entrypoint
ADD /conf/Entrypoint.sh /scripts/Entrypoint.sh
# Change privileges
RUN chmod +x /scripts/Entrypoint.sh
# Updated 
RUN apt-get update
# Install 
RUN apt-get install curl -y
# Set directory
WORKDIR /scripts
# Entry point command
CMD ["./Entrypoint.sh"]
