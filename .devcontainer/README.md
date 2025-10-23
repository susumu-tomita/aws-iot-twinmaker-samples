# Development Container Setup

This directory contains the configuration for a development container that provides a consistent development environment for the AWS IoT TwinMaker Samples project.

## Features

The development container includes:

- **Python 3.11** - For running sample scripts and deploying content
- **Node.js 18** - For AWS CDK and other Node.js tools
- **AWS CLI** - Latest version for interacting with AWS services
- **AWS CDK** - Automatically installed via post-create script
- **Docker-in-Docker** - For building Lambda layers and containers
- **Git** - For version control
- **VS Code Extensions**:
  - Python support (linting, formatting)
  - AWS Toolkit
  - Docker support
  - ESLint and Prettier

## Prerequisites

1. **Docker Desktop** installed and running
2. **Visual Studio Code** with the "Dev Containers" extension installed
3. **AWS Credentials** configured in `~/.aws/` (automatically mounted)

## Getting Started

### Option 1: Using VS Code

1. Open this project in VS Code
2. Press `F1` or `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)
3. Select: **Dev Containers: Reopen in Container**
4. Wait for the container to build and start (first time takes longer)
5. The post-create script will automatically:
   - Install AWS CDK
   - Install Python dependencies
   - Install Node.js dependencies for modules

### Option 2: Using Command Line

```bash
# From the project root
devcontainer open .
```

## Post-Setup Configuration

After the container starts, configure your environment:

```bash
# Set your AWS account ID
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

# Set environment variables
export GETTING_STARTED_DIR=$PWD
export AWS_DEFAULT_REGION=us-east-1
export CDK_DEFAULT_REGION=$AWS_DEFAULT_REGION
export TIMESTREAM_TELEMETRY_STACK_NAME=CookieFactoryTelemetry
export WORKSPACE_ID=CookieFactory

# Bootstrap CDK (first time only)
cdk bootstrap aws://$CDK_DEFAULT_ACCOUNT/$AWS_DEFAULT_REGION

# Authenticate Docker for ECR
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
```

## Ports

- **Port 3000** - Grafana (forwarded automatically)

## AWS Credentials

Your local AWS credentials from `~/.aws/` are mounted into the container at `/home/vscode/.aws/`. This means:

- Any AWS CLI profiles you have configured locally will be available
- You don't need to reconfigure credentials inside the container
- Changes to credentials require rebuilding the container

## Troubleshooting

### Container fails to start

- Ensure Docker Desktop is running
- Check Docker Desktop has enough resources (CPU, Memory)
- Try rebuilding: **Dev Containers: Rebuild Container**

### AWS CLI not authenticated

- Verify `~/.aws/credentials` exists on your host machine
- Try running `aws sts get-caller-identity` to test authentication

### Python/Node dependencies missing

- The post-create script should install these automatically
- If something fails, rebuild the container
- Check the container logs for error messages

## Customization

Edit `.devcontainer/devcontainer.json` to:

- Add more VS Code extensions
- Change the base image
- Modify environment variables
- Add additional features

## Additional Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Features](https://containers.dev/features)
- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
