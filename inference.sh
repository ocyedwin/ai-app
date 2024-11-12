#!/bin/bash

docker exec -it \
    $(docker ps --format '{{.Names}}' | grep longvu) \
    /opt/conda/bin/conda run -n app_env /bin/bash -c \
    "cd app && python -u inference.py 2>&1 | tee /dev/tty"
