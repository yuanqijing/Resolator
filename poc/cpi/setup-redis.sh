#!/bin/bash

# Check if the container already exists
if [ "$(docker ps -aq -f name=myredis)" ]; then
    # If it does, stop and remove it
    docker stop myredis
    docker rm myredis
fi

# Start the Redis container
docker run --name myredis -p 6379:6379 -d redis

# Sleep for a few seconds to make sure the container starts
sleep 5

# Get the container's ID
container_id=$(docker ps -aqf "name=myredis")

# Get the PID of the Redis process running inside the Docker container
pid=$(docker inspect --format '{{.State.Pid}}' "$container_id")

# Print out the PID
echo "The PID of the Redis process is: $pid"

# current ip
echo "Redis is running at $(hostname -I):6379"

# Cleanup function to remove the container when the script is interrupted
cleanup() {
    echo "Removing the Redis container..."
    docker rm -f $container_id
    exit
}

# Trap the SIGINT signal (Ctrl+C) and call the cleanup function
trap cleanup SIGINT

# Wait indefinitely until the script is interrupted
while true; do
    sleep 1
done
