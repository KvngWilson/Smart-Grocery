#!/bin/bash

# Quick access script for port forwarding

echo "Starting port forwarding..."
echo "Frontend will be available at: http://localhost:8080"
echo "API will be available at: http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run port forwards in parallel
kubectl port-forward -n smart-grocery svc/client 8080:80 &
PF1=$!

kubectl port-forward -n smart-grocery svc/server 5000:5000 &
PF2=$!

# Trap Ctrl+C to kill both port forwards
trap "kill $PF1 $PF2 2>/dev/null; exit" INT TERM

# Wait for both processes
wait $PF1 $PF2
