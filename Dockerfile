# Hermes Agent + voice support (overlay image)
#
# Starts from the official Hermes release image and adds only what voice needs:
#   - [voice]    -> faster-whisper (local STT fallback), sounddevice, numpy
#   - [edge-tts] -> free Edge text-to-speech
#   - libportaudio2 / libopus0 / libgomp1 system libraries
# Everything else (entrypoint, s6 supervision, user, /opt/data layout) is
# inherited unchanged from the base image.
#
# To upgrade Hermes later: change HERMES_TAG to a newer release tag
# (https://github.com/NousResearch/hermes-agent/tags) and push.

ARG HERMES_TAG=v2026.9.24
FROM nousresearch/hermes-agent:${HERMES_TAG}

# The base image already ends as root (its entrypoint drops to the
# `hermes` user via s6), so no USER switching is needed here.

RUN apt-get -o Acquire::Retries=3 update && \
    apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
        libopus0 libportaudio2 libgomp1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hermes

# Same lockfile, same extras as upstream, plus voice + edge-tts.
# --frozen    : use upstream uv.lock exactly (keeps the PyNaCl 1.6 override)
# --inexact   : add packages only, never remove anything already installed
RUN uv sync --frozen --inexact --no-install-project --no-cache \
        --extra all --extra messaging --extra otlp --extra anthropic \
        --extra bedrock --extra azure-identity --extra matrix --extra google-chat \
        --extra voice --extra edge-tts && \
    uv pip install --no-cache-dir --no-deps -e "."

# Keep downloaded Whisper models on the persistent /opt/data volume.
ENV HF_HOME=/opt/data/.cache/huggingface
