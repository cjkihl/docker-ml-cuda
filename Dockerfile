FROM runpod/stable-diffusion:web-automatic-base-4.0.0 AS runtime

WORKDIR /workspace/stable-diffusion-webui

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt install git-lfs
RUN pip install gdown

RUN gdown 1LIt5d03xtvGjyfR0eC6MLl3Zz0SBGysg -O embeddings --folder \
    gdown 1fl-LueLLqCYg55L49JGuK_TLRsOhZulJ -O models/Lora --folder

WORKDIR /workspace/stable-diffusion-webui/models/Stable-diffusion
RUN wget -O urpm.safetensors https://civitai.com/api/download/models/15640

WORKDIR /workspace/stable-diffusion-webui