# syntax=docker/dockerfile:1
FROM ghcr.io/FatulM/development-images:latest

ENV PYTHONUNBUFFERED=1

WORKDIR example/

COPY * .

RUN set -eux; \
    python3 --version; \
    python3 -m venv venv; \
    venv/bin/python --version; \
    venv/bin/pip --version; \
    venv/bin/python example.py; \
    java --version; \
    javac --version; \
    mvn --version; \
    javac Example.java; \
    java Example;
