#!/bin/bash

set -e 
clear 
echo -e "Deploying development environment...\n"
echo "-----------------------------------"
cd ./server
echo -e '\nStarting server...'
npm run start &
SERVER_PID=$!

echo "-----------------------------------"
cd ..
echo -e '\nStarting client...'
npm run dev &
CLIENT_PID=$!

echo -e "\n-----------------------------------"
echo "Server PID: $SERVER_PID"
echo "Client PID: $CLIENT_PID"
echo "Press Ctrl+C to stop both processes"
echo "-----------------------------------\n"

# Trap Ctrl+C to kill both processes
trap "kill $SERVER_PID $CLIENT_PID 2>/dev/null; exit" INT TERM

# Wait for both processes
wait 

