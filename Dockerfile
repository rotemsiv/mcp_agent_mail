# syntax=docker/dockerfile:1.7
FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ca-certificates && \
    apt-get clean && rm -r /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml README.md ./
COPY src ./src

RUN pip install --no-cache-dir .

ENV HTTP_HOST=0.0.0.0 \
    STORAGE_ROOT=/data/mailbox \
    HTTP_PORT=8765

RUN mkdir -p /data/mailbox

EXPOSE 8765

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=5 \
  CMD curl -fsS http://127.0.0.1:8765/health/liveness || exit 1

CMD ["sh", "-c", "mkdir -p /data/mailbox && exec python -m mcp_agent_mail.cli serve-http"]
