#!/bin/bash

docker exec -it \
    $(docker ps --format '{{.Names}}' | grep longvu_pg_longvu) \
    /opt/conda/bin/conda run -n app_env /bin/bash -c \
    "export CUDA_VISIBLE_DEVICES=0 && \
    export PYTHONPATH=/workspace/app:$PYTHONPATH && \
    cd app && \
    python -u my_ext/inference.py \
    --video_path 'storage/2x/3b/2x3bz9om18gjbr1gklei7rb1rbbj' \
    --question 'Describe this video in detail' \
    2>&1 | tee /dev/tty"


# video_path = "storage/29/9g/299gqghqhzscgf11qyew58hvvuuz"
# qs = "Describe this video in detail"