# Dockerfile for Fathom AI MCP Server
# For Smithery container deployment

FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install uv package manager
RUN pip install --no-cache-dir uv

# Copy project files
COPY pyproject.toml ./
COPY server.py ./
COPY README.md ./

# Install dependencies using uv
RUN uv pip install --system fastmcp httpx pydantic python-dotenv

# Expose port for HTTP mode (if needed)
EXPOSE 8080

# Default command - runs the MCP server in stdio mode
# The FATHOM_API_KEY should be provided as an environment variable
CMD ["fastmcp", "run", "server.py"]
