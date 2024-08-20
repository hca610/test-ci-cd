#!/bin/bash

# Replace 'my_container' with the actual name or ID of your container
container_name="app-master"

# Get the container's port mapping information
port_mapping=$(docker port $container_name 5000)

echo $port_mapping

# Extract the published port number using cut and awk
published_port=$(echo "$port_mapping" | grep -oP '\d{5,5}' | head -n 1)


echo "Published port: $published_port"