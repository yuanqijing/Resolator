#!/bin/bash

# Check if the IP argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <ip> [cluster-mode]"
    echo "<ip> - IP address of the Redis container"
    echo "[cluster-mode] - Optional. If provided, benchmark will be run in cluster mode"
    exit 1
fi

# Get the IP address from the argument
ip=$1

# Check if cluster mode should be enabled
if [ "$2" == "cluster-mode" ]; then
    cluster_mode="--cluster-mode"
else
    cluster_mode=""
fi

# Run the benchmark
docker run --rm harbor.middleware.com/middleware/memtier_benchmark:1.4.0 -s "$ip" "$cluster_mode" --key-prefix=memtier-test- --data-size=100 --ratio=1:10 --expiry-range=7200000-720000000 --requests=10000000000 --threads=16 --clients=40