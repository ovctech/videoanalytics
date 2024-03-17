FROM python:3.11.0-slim-bullseye AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    curl \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock ./
RUN python -m pip install --no-cache-dir poetry==1.7.1 \
    && poetry config virtualenvs.in-project true \
    && poetry config installer.max-workers 10 \
    && poetry install --no-interaction --no-ansi --without dev,test

FROM python:3.11.0-slim-bullseye

WORKDIR /app

RUN mkdir -p /data

RUN mkdir -p /var/www/static
COPY --from=builder /app /app
COPY . /app/
COPY entrypoint.sh  /app/

ENV PATH="/app/.venv/bin:$PATH"
