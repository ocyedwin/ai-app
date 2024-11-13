FROM nvidia/cuda:12.3.2-cudnn9-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y nfs-common iputils-ping sudo \
    git git-lfs curl wget bzip2 build-essential \
    ffmpeg portaudio19-dev libgl1-mesa-glx \
    # https://github.com/karpathy/llm.c
    openmpi-bin openmpi-doc libopenmpi-dev

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    echo "export PATH=/opt/conda/bin:$PATH" > /etc/profile.d/conda.sh
ENV PATH /opt/conda/bin:$PATH

WORKDIR /workspace

RUN groupadd -g 1000 user && \
    useradd -m -u 1000 -g 1000 -s /bin/bash user && \
    chown -R user:user /workspace

USER user
ENV PATH /home/user/.local/bin:$PATH

# Set up conda for the user
RUN conda init bash && \
    echo 'export PATH=/opt/conda/bin:$PATH' >> ~/.bashrc && \
    . ~/.bashrc && \
    conda create -n app_env python=3.10 -y && \
    echo "conda activate app_env" >> ~/.bashrc

# Use SHELL command to ensure conda is initialized for each RUN command
SHELL ["conda", "run", "-n", "app_env", "/bin/bash", "-c"]

RUN git clone https://github.com/Vision-CAIR/LongVU app && \
    cd app && \
    pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir notebook matplotlib wandb websockets

ENV PYTHONPATH /workspace/app:$PYTHONPATH
ENV PYTHONUNBUFFERED=1
COPY my_ext /workspace/app/my_ext

WORKDIR /workspace/app
CMD ["conda", "run", "--no-capture-output", "-n", "app_env", "python", "-u", "my_ext/server.py"]