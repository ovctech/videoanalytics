FROM python:3.11.0-slim-bullseye AS builder

WORKDIR /app

COPY poetry.lock pyproject.toml ./

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir poetry==1.7.1 \
    && poetry config virtualenvs.in-project true \
    && poetry install --no-interaction --no-ansi --without dev,test

FROM python:3.11.0-slim-bullseye

COPY --from=builder /app /app
COPY . /app/

WORKDIR /app

CMD ["/app/.venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]
