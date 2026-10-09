# hermes-voice

Official [Hermes Agent](https://github.com/NousResearch/hermes-agent) release image plus voice support
(faster-whisper local STT, Edge TTS, Opus/PortAudio libraries). Built for ARM64 (Oracle free tier).

## Use in Coolify

In the Hermes service's compose file, replace

```
image: nousresearch/hermes-agent:latest
```

with

```
image: ghcr.io/csing7/hermes-voice:v2026.9.24
```

then redeploy. `/opt/data` (config, memory, logs) is untouched.

**Rollback:** put the old `image:` line back and redeploy.

## Upgrade Hermes

Change `ARG HERMES_TAG=` in the `Dockerfile` to a newer
[release tag](https://github.com/NousResearch/hermes-agent/tags), commit, and use the new tag in Coolify.

## After deploying

Set `GROQ_API_KEY` in Coolify's environment variables, then configure STT/TTS
(`stt.provider: groq`, `stt.local.model: base`, `tts.provider: edge`).
