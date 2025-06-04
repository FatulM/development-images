# syntax=docker/dockerfile:1
FROM ghcr.io/FatulM/development-images:latest

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ENV PYTHONUNBUFFERED=1

WORKDIR example/

COPY * .

RUN python3 --version; \
    python3 -m venv venv; \
    venv/bin/python --version; \
    venv/bin/pip --version; \
    venv/bin/python example.py; \
    java --version; \
    javac --version; \
    mvn --version; \
    javac Example.java; \
    java Example;
