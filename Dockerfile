FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ARG WEBUI_VERSION=v1.5.1
ARG DREAMBOOTH_VERSION=1.0.14

ENV DEBIAN_FRONTEND noninteractive
ENV SHELL=/bin/bash
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu
ENV PATH="/workspace/venv/bin:$PATH"
ENV TORCH_COMMAND="pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"

WORKDIR /workspace

# Set up shell and update packages
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy the Python dependencies
COPY requirements*.txt .
COPY install-automatic.py ./

# Package installation and setup
RUN apt update --yes && \
    apt upgrade --yes && \
    apt install --yes --no-install-recommends \
    git openssh-server libglib2.0-0 libsm6 libgl1 libxrender1 libxext6 ffmpeg wget curl psmisc rsync vim nginx \
    pkg-config libffi-dev libcairo2 libcairo2-dev libgoogle-perftools4 libtcmalloc-minimal4 apt-transport-https \
    software-properties-common ca-certificates
RUN update-ca-certificates
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install python3.10-dev python3.10-venv -y --no-install-recommends
# Create Symbolic links for python
RUN ln -s /usr/bin/python3.10 /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.10 /usr/bin/python3
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \python get-pip.py && \
    pip install -U --no-cache-dir pip
RUN python -m venv /workspace/venv && \
    export PATH="/workspace/venv/bin:$PATH"
RUN pip install -U --no-cache-dir jupyterlab jupyterlab_widgets ipykernel ipywidgets
RUN git clone --branch v1.5.1 --single-branch https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

RUN mv /workspace/install-automatic.py /workspace/stable-diffusion-webui/ && \
    mv /workspace/requirements.txt /workspace/stable-diffusion-webui/requirements.txt && \
    mv /workspace/requirements_versions.txt /workspace/stable-diffusion-webui/requirements_versions.txt
RUN cd /workspace/stable-diffusion-webui/ && python -m install-automatic --skip-torch-cuda-test

RUN cd /workspace/stable-diffusion-webui/ && \
    pip cache purge && \
    apt clean


# NGINX Proxy
COPY nginx.conf /etc/nginx/nginx.conf
COPY readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

# Start Scripts
COPY pre_start.sh /pre_start.sh
COPY relauncher.py webui-user.sh /stable-diffusion-webui/
COPY start.sh /start.sh
RUN chmod +x /start.sh && chmod +x /pre_start.sh

SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
