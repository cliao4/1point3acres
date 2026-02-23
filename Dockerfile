# syntax=docker/dockerfile:1
FROM python:3.12-slim

# basic runtime env
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=America/Chicago 

WORKDIR /app

# TLS certs + timezone (tiny but important)
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install python deps first for better layer caching
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy only source code (DO NOT copy configure/ which contains cookies)
COPY src/ /app/src/

WORKDIR /app/src
# Default: run the script once
# Expect config to be mounted at /app/configure (cookie.json, data.json)
CMD ["sh", "-lc", "echo \"===== $(date -Is) =====\" >> /app/run.log && python service.py >> /app/run.log 2>&1"]
#CMD ["sh", "-c", "echo \"===== $(date) =====\" >> /app/run.log && python service.py >> /app/run.log 2>&1"]
#CMD ["sh", "-c", "python service.py >> /app/run.log 2>&1"]
