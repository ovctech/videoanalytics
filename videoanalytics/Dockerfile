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

RUN mkdir -p /data
COPY --from=builder /app /app
COPY . /app/

WORKDIR /app

ENV PATH="/app/.venv/bin:$PATH"

CMD ["/app/.venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]
