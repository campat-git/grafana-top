#!/bin/bash

hostname=$(hostname)

while true; do
    metrics=""

    # Parse 'ps aux' output
    ps aux | awk 'NR > 1 && $0 !~ /ps aux|bash/ {
        pid=$2;
        cpu=$3;
        mem=$4;
        process=$11;
        if (process == "") process="Unknown";
        printf("cpu_usage{process=\"%s\", pid=\"%s\"} %s\n", process, pid, cpu);
        printf("mem_usage{process=\"%s\", pid=\"%s\"} %s\n", process, pid, mem);
    }' > /tmp/metrics.txt

    metrics=$(cat /tmp/metrics.txt)

    # Print metrics
    echo "$hostname $metrics"

    # Send metrics to Prometheus Pushgateway
    url="http://localhost:9091/metrics/job/system_metrics/instance/$hostname"
    curl -X POST --data-binary "$metrics" "$url"

    # Sleep for 30 seconds
    sleep 30
done
