# Generated pattern based on smithery.ai examples
# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS uv

# Install the project into /app
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from files to install dependencies
COPY pyproject.toml /app/pyproject.toml
COPY requirements.txt /app/requirements.txt

# Install the project's dependencies using uv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system -r /app/requirements.txt

# Then, add the rest of the project source code
COPY server.py /app/server.py
COPY README.md /app/README.md

# Environment variable placeholder
ENV FATHOM_API_KEY=""

# Entry point for fastmcp
ENTRYPOINT ["fastmcp", "run", "server.py"]
