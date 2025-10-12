# Smithery Deployment Guide for Fathom MCP Server

This guide covers everything you need to deploy the Fathom MCP Server to [Smithery](https://smithery.ai), making it available for anyone to install and use.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deployment Methods](#deployment-methods)
3. [Configuration Files](#configuration-files)
4. [Deployment Steps](#deployment-steps)
5. [Testing](#testing)
6. [Publishing](#publishing)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required

- GitHub account
- GitHub repository (public or private)
- Smithery account (sign up at [smithery.ai](https://smithery.ai))
- Fathom API key (get from [Fathom Settings](https://app.fathom.video/settings/integrations))

### Optional (for CLI deployment)

- Node.js 18+ installed
- Smithery CLI: `npm install -g @smithery/cli`

## Deployment Methods

### Method 1: Web-Based Deployment (Recommended)

This is the easiest method - Smithery does all the work.

**Steps:**

1. Push your code to GitHub
2. Go to [smithery.ai](https://smithery.ai)
3. Sign in with your GitHub account
4. Click "Deploy" button
5. Select your repository
6. Smithery auto-detects configuration and deploys

**What Smithery does automatically:**

- Reads `smithery.yaml` for configuration
- Builds Docker container from `Dockerfile`
- Sets up the configuration schema
- Creates the installation page
- Makes your server available in the registry

### Method 2: CLI Deployment

For developers who prefer command-line tools.

**Steps:**

```bash
# 1. Install Smithery CLI
npm install -g @smithery/cli

# 2. Login to Smithery
smithery login

# 3. Navigate to your project directory
cd /path/to/fathom-mcp

# 4. Deploy
smithery deploy .
```

The CLI will:
- Validate your configuration files
- Build and push the Docker image
- Register your server on Smithery
- Provide a deployment URL

## Configuration Files

The Fathom MCP Server is already configured with all necessary files:

### 1. `smithery.yaml` (Required)

Defines how Smithery runs your server.

```yaml
startCommand:
  type: stdio                    # Uses standard input/output

  configSchema:                  # User configuration schema
    type: object
    required:
      - fathomApiKey
    properties:
      fathomApiKey:
        type: string
        description: "Your Fathom API key"

  exampleConfig:                 # Example for users
    fathomApiKey: "your_api_key_here"

  commandFunction: >             # Command to start server
    config => ({
      command: 'uv',
      args: ['run', 'fastmcp', 'run', 'server.py'],
      env: { FATHOM_API_KEY: config.fathomApiKey }
    })
```

**Key fields:**

- `type: stdio` - Server communicates via stdin/stdout (standard for MCP)
- `configSchema` - JSON Schema defining what users must configure
- `exampleConfig` - Shows users what config looks like
- `commandFunction` - JavaScript function that builds the startup command

### 2. `Dockerfile` (Required)

Defines the container environment.

```dockerfile
FROM python:3.12-slim
WORKDIR /app

# Install uv package manager
RUN pip install --no-cache-dir uv

# Copy project files
COPY pyproject.toml ./
COPY server.py ./
COPY README.md ./

# Install dependencies
RUN uv pip install --system fastmcp httpx pydantic python-dotenv

EXPOSE 8080

# Start command
CMD ["fastmcp", "run", "server.py"]
```

**Best practices applied:**

- Uses slim Python image (smaller, faster)
- Installs uv for faster dependency management
- Only copies necessary files (.dockerignore excludes others)
- Installs dependencies at build time (cached layer)

### 3. `package.json` (Recommended)

Provides metadata for Smithery registry.

```json
{
  "name": "fathom-mcp-server",
  "version": "1.0.0",
  "description": "A Model Context Protocol server for Fathom AI",
  "keywords": ["mcp", "fathom", "meetings", "transcripts"],
  "author": "Alvin Cheung",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/YOUR_USERNAME/fathom-mcp.git"
  }
}
```

**Update before deploying:**
- Replace `YOUR_USERNAME` with your GitHub username
- Update author name if forking
- Add any additional keywords for discoverability

### 4. `.dockerignore` (Recommended)

Prevents unnecessary files from bloating the Docker image.

```
__pycache__/
*.pyc
.env
.venv/
.git/
*.md
tests/
```

## Deployment Steps

### Step-by-Step: Web Deployment

#### Step 1: Prepare Repository

```bash
# 1. Update package.json with your info
# Edit package.json, replace YOUR_USERNAME

# 2. Commit all changes
git add .
git commit -m "Prepare for Smithery deployment"

# 3. Push to GitHub
git push origin main
```

#### Step 2: Deploy on Smithery

1. Visit [smithery.ai](https://smithery.ai)
2. Click "Sign In" (authenticate with GitHub)
3. Click "Deploy" or "New Server"
4. Select your repository from the list
5. Click "Deploy"

Smithery will:
- Clone your repository
- Detect `smithery.yaml`
- Build the Docker container
- Validate configuration
- Deploy the server

#### Step 3: Verify Deployment

After deployment completes:

1. You'll see your server on your Smithery dashboard
2. Get a shareable installation link
3. Test installation (see Testing section)

### Step-by-Step: CLI Deployment

```bash
# Navigate to project directory
cd /path/to/fathom-mcp

# Ensure you're logged in
smithery login

# Deploy (interactive mode)
smithery deploy .

# Follow prompts:
# - Confirm project details
# - Choose deployment options
# - Wait for build to complete

# Get deployment URL
smithery info
```

## Testing

### Test Local Build (Before Deploying)

Test your Docker configuration locally:

```bash
# Build the Docker image
docker build -t fathom-mcp-test .

# Run the container with your API key
docker run -it --rm \
  -e FATHOM_API_KEY="your_api_key_here" \
  fathom-mcp-test

# You should see the MCP server start
```

### Test with Smithery Playground

After deploying to Smithery:

```bash
# Install Smithery CLI if not already installed
npm install -g @smithery/cli

# Launch playground with your server
npx @smithery/cli playground

# This opens an interactive testing environment
# You can call tools and see responses
```

### Test Installation

Install your server as an end-user would:

```bash
# Install from Smithery
smithery install fathom-mcp-server

# You'll be prompted for your Fathom API key
# Enter your key when prompted

# Verify it's installed
smithery list
```

### Test with Claude Desktop

After installation via Smithery:

1. Restart Claude Desktop
2. Smithery automatically adds config to Claude
3. Try these prompts in Claude:
   - "List my recent Fathom meetings"
   - "Get the summary for recording [ID]"
   - "Show me meetings from the past week"

## Publishing

### Make Your Server Public

By default, Smithery servers are private. To make public:

1. Go to your server on Smithery dashboard
2. Click "Settings"
3. Set visibility to "Public"
4. Add tags and description
5. Save changes

### Promote Your Server

Share your server:

- **Direct link**: `https://smithery.ai/server/@your-username/fathom-mcp-server`
- **Installation command**: `smithery install @your-username/fathom-mcp-server`
- Share on social media, developer communities
- Add badge to your README:

```markdown
[![Deploy on Smithery](https://smithery.ai/badge/deploy)](https://smithery.ai/server/@your-username/fathom-mcp-server)
```

## Troubleshooting

### Common Issues

#### Issue: Docker Build Fails

**Error:** `failed to solve with frontend dockerfile.v0`

**Solutions:**
1. Check Docker is running: `docker ps`
2. Verify Dockerfile syntax
3. Ensure all COPY paths exist
4. Check network connectivity

```bash
# Test locally first
docker build -t test .
```

#### Issue: Configuration Not Recognized

**Error:** `smithery.yaml not found or invalid`

**Solutions:**
1. Ensure `smithery.yaml` is in project root
2. Validate YAML syntax: https://www.yamllint.com/
3. Check indentation (use spaces, not tabs)
4. Verify all required fields present

```bash
# Validate smithery.yaml structure
cat smithery.yaml
```

#### Issue: Server Won't Start

**Error:** `Server failed to start` or `Command not found`

**Solutions:**
1. Verify dependencies are installed in Dockerfile
2. Check CMD in Dockerfile matches commandFunction
3. Test command locally:

```bash
# Inside container
docker run -it fathom-mcp-test /bin/bash
fastmcp run server.py  # Should work
```

#### Issue: API Key Not Working

**Error:** `Authentication failed` or `401 Unauthorized`

**Solutions:**
1. Verify API key is correct
2. Check key format (should include period)
3. Ensure key is passed via environment variable
4. Test API key directly:

```bash
curl -H "X-Api-Key: YOUR_KEY" https://api.fathom.ai/external/v1/meetings
```

### Get Help

If you encounter issues:

1. **Check Smithery Docs**: https://smithery.ai/docs
2. **GitHub Issues**: Open issue on your repo
3. **Smithery Discord**: Join community for support
4. **Check Logs**: View deployment logs on Smithery dashboard

## Advanced Configuration

### Custom Docker Image

If you need a different base image:

```dockerfile
# Use a specific Python version
FROM python:3.11-slim

# Or use Alpine for smaller size
FROM python:3.12-alpine
```

### Environment Variables

Add more environment variables in `commandFunction`:

```yaml
commandFunction: >
  config => ({
    command: 'uv',
    args: ['run', 'fastmcp', 'run', 'server.py'],
    env: {
      FATHOM_API_KEY: config.fathomApiKey,
      LOG_LEVEL: config.logLevel || 'info',
      CUSTOM_VAR: config.customVar
    }
  })
```

Then update `configSchema` to accept these new options.

### HTTP Mode

To run in HTTP mode instead of stdio:

```yaml
startCommand:
  type: http
  port: 8080
  # ... rest of config
```

Update Dockerfile CMD:
```dockerfile
CMD ["fastmcp", "run", "server.py", "--transport", "http"]
```

## Deployment Checklist

Before deploying, verify:

- [ ] All files committed and pushed to GitHub
- [ ] `package.json` updated with your repository URL
- [ ] `smithery.yaml` is valid and complete
- [ ] `Dockerfile` builds successfully locally
- [ ] `.dockerignore` excludes sensitive files
- [ ] README.md has clear installation instructions
- [ ] Fathom API key tested and working
- [ ] Server runs locally with `fastmcp run server.py`
- [ ] No `.env` file in repository (gitignored)

## Next Steps

After successful deployment:

1. **Monitor Usage**: Check Smithery dashboard for installation stats
2. **Gather Feedback**: Encourage users to open issues
3. **Update Regularly**: Keep dependencies current
4. **Add Features**: Enhance based on user requests
5. **Document**: Keep README updated with new features

## Resources

- [Smithery Documentation](https://smithery.ai/docs)
- [FastMCP Documentation](https://gofastmcp.com/)
- [Fathom API Reference](https://developers.fathom.ai/api-overview)
- [Model Context Protocol Spec](https://modelcontextprotocol.io)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Ready to deploy?** Follow the deployment steps above and your Fathom MCP Server will be live on Smithery in minutes!
