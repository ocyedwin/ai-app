# Use Nvidia CUDA as base base its more complex
FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04 as base

# Install essential build dependencies
RUN apt-get update && apt-get install -y \
    # Rails dependencies
    git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev \
    # My dependencies
    nfs-common iputils-ping sudo wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    echo "export PATH=/opt/conda/bin:$PATH" > /etc/profile.d/conda.sh
ENV PATH /opt/conda/bin:$PATH

RUN conda init bash && \
    echo 'export PATH=/opt/conda/bin:$PATH' >> ~/.bashrc && \
    . ~/.bashrc && \
    conda create -n app_env python=3.12 -y && \
    echo "conda activate app_env" >> ~/.bashrc

# Use SHELL command to ensure conda is initialized for each RUN command
SHELL ["conda", "run", "-n", "app_env", "/bin/bash", "-c"]

COPY sigclip/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir notebook matplotlib wandb

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Add rbenv to PATH in both ~/.bashrc and ~/.bash_profile for runtime
RUN echo 'export PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    echo 'export PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# Make sure the final PATH includes rbenv paths at runtime
ENV PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"

RUN rbenv install 3.3.6 && rbenv global 3.3.6 && gem install bundler
