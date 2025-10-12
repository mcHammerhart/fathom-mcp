# Simple, BuildKit-compatible image for Smithery deployment
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py README.md pyproject.toml ./

# Environment variable placeholder (Smithery injects real value)
ENV FATHOM_API_KEY=""

ENTRYPOINT ["fastmcp", "run", "server.py"]
