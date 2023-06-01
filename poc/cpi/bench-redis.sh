#!/bin/bash


# Define the Docker container name
container_name="myredis-bench"

# Function to stop and remove the Docker container
stop_container() {
    echo "Stopping and removing the Docker container..."
    docker stop $container_name
    docker rm $container_name
    exit
}

# Default values
ip=""
cluster_mode=""
data_size=100
ratio="1:10"
expiry_range="7200000-720000000"
requests=10000000000
threads=16
clients=40

# Handle the SIGINT signal (Ctrl+C)
trap stop_container SIGINT

# Parse command-line options
options=$(getopt -o hi:c:d:r:e:q:t:l: --long help,ip:,cluster-mode:,data-size:,ratio:,expiry-range:,requests:,threads:,clients: -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}
eval set -- "$options"

while true; do
    case "$1" in
    -h|--help)
        echo "Usage: $0 --ip=<ip> [--cluster-mode] [--data-size=<data-size>] [--ratio=<ratio>] [--expiry-range=<expiry-range>] [--requests=<requests>] [--threads=<threads>] [--clients=<clients>]"
        echo "<ip> - IP address of the Redis container"
        echo "[cluster-mode] - Optional. If provided, benchmark will be run in cluster mode"
        echo "[data-size] - Optional. Size of the data to use for the benchmark. Default: 100"
        echo "[ratio] - Optional. Ratio for the benchmark. Default: 1:10"
        echo "[expiry-range] - Optional. Expiry range for the benchmark. Default: 7200000-720000000"
        echo "[requests] - Optional. Number of requests for the benchmark. Default: 10000000000"
        echo "[threads] - Optional. Number of threads for the benchmark. Default: 16"
        echo "[clients] - Optional. Number of clients for the benchmark. Default: 40"
        exit 0 ;;
    -i|--ip)
        ip=$2; shift 2 ;;
    -c|--cluster-mode)
        cluster_mode="--cluster-mode"; shift 2 ;;
    -d|--data-size)
        data_size=$2; shift 2 ;;
    -r|--ratio)
        ratio=$2; shift 2 ;;
    -e|--expiry-range)
        expiry_range=$2; shift 2 ;;
    -q|--requests)
        requests=$2; shift 2 ;;
    -t|--threads)
        threads=$2; shift 2 ;;
    -l|--clients)
        clients=$2; shift 2 ;;
    --)
        shift; break ;;
    esac
done

# Run the benchmark
# logfile with timestamp
logfile="benchmark-$(date +%Y%m%d).log"
docker run --name $container_name harbor.middleware.com/middleware/memtier_benchmark:1.4.0 -s "$ip" "$cluster_mode" --key-prefix=memtier-test- --data-size="$data_size" --ratio="$ratio" --expiry-range="$expiry_range" --requests="$requests" --threads="$threads" --clients="$clients" > "$logfile" &

wait $!

