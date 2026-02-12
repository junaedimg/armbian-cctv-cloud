#!/bin/bash

chmod +x record.sh
chmod +x upload.sh

./record.sh &
./upload.sh &

wait
