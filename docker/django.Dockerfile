FROM python:3.12-slim-bullseye

# Prevent buffering std out
ENV PYTHONUNBUFFERED 1 
# Prevent creating pyc files
ENV PYTHONDONTWRITEBYTECODE 1
# Prevent user prompt interaction 
ENV DEBIAN_FRONTEND noninteractive
# Prevent failing installing poetry
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1 
# Set the custom PYTHONPATH
# ENV PYTHONPATH=${PYTHONPATH}:/django_serverless_poc
ENV PYTHONPATH=${PYTHONPATH}:/app

WORKDIR /app
COPY django_serverless_poc/ /app/
COPY pyproject.toml poetry.lock /app/

# Install dependencies using Poetry
RUN python3 -m pip install -U pip && pip3 install poetry==1.8.2 \
    && poetry config virtualenvs.create false || true \
	&& poetry install
