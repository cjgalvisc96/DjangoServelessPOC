# FROM python:3.12-alpine3.19
FROM python:3.12-slim-bullseye

# Prevent creating pyc files
ENV PYTHONDONTWRITEBYTECODE=1 \
    # Prevent failing installing poetry
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    # Prevent buffering std out
    PYTHONUNBUFFERED=1

# Prevent user prompt interaction
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app
COPY . /app

# Poetry
RUN python3 -m pip install -U pip && pip3 install poetry==1.8.2 \
    && poetry config virtualenvs.create false || true \
	&& poetry install
