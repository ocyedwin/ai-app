#!/bin/bash

docker exec -it \
    $(docker ps --format '{{.Names}}' | grep longvu) \
    /opt/conda/bin/conda run -n app_env /bin/bash -c \
    "export CUDA_VISIBLE_DEVICES=0 && \
    export PYTHONPATH=/workspace/app:$PYTHONPATH && \
    cd app && \
    python -u my_ext/inference.py 2>&1 | tee /dev/tty"
