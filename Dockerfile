ARG BASE_IMAGE=nvidia/cuda:11.6.1-cudnn8-runtime-ubuntu20.04
# ARG BASE_IMAGE=ubuntu:20.04

FROM ${BASE_IMAGE} as dev-base

WORKDIR /

RUN mkdir /workspace

ENV DEBIAN_FRONTEND noninteractive\
    SHELL=/bin/bash
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends\
    git\
    wget\
    curl\
    git\
    bash\
    nano\
    openssh-server\
    python3\
    python3-venv\
    python3-pip\
    libglib2.0-0\
    libsm6\
    libxrender1\
    libxext6\
    ffmpeg

RUN pip3 install jupyterlab

RUN apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

WORKDIR /workspace

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /workspace/stable-diffusion-webui
RUN git pull

ADD webui-user.sh /workspace/stable-diffusion-webui/webui-user.sh

#WORKDIR /workspace/stable-diffusion-webui/models/Stable-diffusion

RUN wget -O models/Stable-diffusion/openjourney.ckpt https://civitai.com/api/download/models/96

WORKDIR /workspace/stable-diffusion-webui/extensions

RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git
RUN git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git

WORKDIR /workspace

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV PATH="${PATH}:/workspace/venv"

ADD start.sh /

RUN chmod +x /start.sh

CMD [ "/start.sh" ]
