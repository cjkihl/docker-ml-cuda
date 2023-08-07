echo "**** syncing venv to workspace, please wait. This could take a while on first startup! ****"
rsync --remove-source-files -rlptDu --ignore-existing /venv/ /workspace/venv/

echo "**** syncing stable diffusion to workspace, please wait ****"
rsync --remove-source-files -rlptDu --ignore-existing /stable-diffusion-webui/ /workspace/stable-diffusion-webui/

# Check if the MODEL_NAME and MODEL_URL environment variables are set
# If the file does not exist, download it with wget
if [ -n "$MODEL_NAME" ] && [ -n "$MODEL_URL" ] && [ ! -f "/workspace/stable-diffusion-webui/models/Stable-diffusion/$MODEL_NAME" ]; then
    echo "Downloading model $MODEL_NAME from $MODEL_URL"
    wget -O "/workspace/stable-diffusion-webui/models/Stable-diffusion/$MODEL_NAME" "$MODEL_URL"
fi

if [[ $RUNPOD_STOP_AUTO ]]
then
    echo "Skipping auto-start of webui"
else
    echo "Started webui through relauncher script"
    cd /workspace/stable-diffusion-webui
    python relauncher.py &
fi
