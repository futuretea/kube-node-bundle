#!/bin/bash

CONTAINERD_ROOT=${CONTAINERD_ROOT:-"/var/lib/containerd"}

# Output CSV header
echo "# pod_namespace,pod_name,volume_path,size"

# Get all information in one go
pods_info=$(crictl pods | grep -v "POD ID")
containers_info=$(crictl ps -a | grep -v "CONTAINER ID")
stats_info=$(crictl stats | grep -v "CONTAINER")

# Process all containers and their stats
echo "$stats_info" | while read -r container_id rest_stats; do
    # Get disk usage
    size=$(echo "$rest_stats" | awk '{print $(NF-1)}')
    
    # Find container info
    container_line=$(echo "$containers_info" | grep "^$container_id")
    if [ -n "$container_line" ]; then
        pod_id=$(echo "$container_line" | awk '{print $(NF-1)}')
        
        # Find pod info
        pod_line=$(echo "$pods_info" | grep "^$pod_id")
        if [ -n "$pod_line" ]; then
            # Extract namespace and name
            pod_namespace=$(echo "$pod_line" | awk '{print $(NF-2)}')
            pod_name=$(echo "$pod_line" | awk '{print $(NF-3)}')
            
            # Output CSV line
            echo "$pod_namespace,$pod_name,container,$size"
        fi
    fi
done