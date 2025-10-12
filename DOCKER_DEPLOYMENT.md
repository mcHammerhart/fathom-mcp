# Docker Deployment (Alternative)

The Fathom MCP Server can be deployed using Docker as an alternative to the default stdio deployment.

## Docker Files

- `Dockerfile.container` - Container configuration for Docker deployment
- `.dockerignore.container` - Build exclusions for Docker

## Why Stdio by Default?

Smithery deployments use stdio mode by default because:
- Faster deployment (no container build required)
- Simpler configuration
- Direct command execution
- Better for most MCP use cases

## Using Docker Deployment

If you prefer Docker deployment:

### 1. Rename Files

```bash
mv Dockerfile.container Dockerfile
mv .dockerignore.container .dockerignore
```

### 2. Update smithery.yaml

Replace the contents with:

```yaml
runtime: "container"
build:
  dockerfile: "Dockerfile"
  dockerBuildPath: "."
startCommand:
  type: "http"
  configSchema:
    type: object
    required:
      - fathomApiKey
    properties:
      fathomApiKey:
        type: string
        description: Your Fathom API key
```

### 3. Update server.py

Add HTTP transport support at the bottom:

```python
if __name__ == "__main__":
    # Use HTTP transport for Docker deployment
    import os
    port = int(os.getenv("PORT", 8080))
    mcp.run(transport="http", host="0.0.0.0", port=port)
```

### 4. Deploy

Push to GitHub and deploy via Smithery.

## Local Docker Testing

Test the Docker build locally:

```bash
# Build
docker build -t fathom-mcp .

# Run
docker run -p 8080:8080 \
  -e FATHOM_API_KEY="your_api_key" \
  fathom-mcp
```

## Recommendation

**Use the default stdio deployment** unless you specifically need containerization for:
- Custom system dependencies
- Specific Python version isolation
- Multi-stage builds
- Complex deployment requirements
