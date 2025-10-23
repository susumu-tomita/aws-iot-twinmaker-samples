#!/bin/bash

set -e

echo "🚀 Running post-create setup..."

# Wait for node/npm to be available (installed by features)
echo "⏳ Waiting for Node.js and npm to be available..."
max_attempts=30
attempt=0
while ! command -v npm &> /dev/null; do
    if [ $attempt -ge $max_attempts ]; then
        echo "❌ Error: npm not found after waiting. Please check devcontainer features."
        exit 1
    fi
    echo "Waiting for npm... (attempt $((attempt + 1))/$max_attempts)"
    sleep 2
    attempt=$((attempt + 1))
    # Reload PATH to pick up newly installed tools
    export PATH="/usr/local/share/nvm/current/bin:/usr/local/bin:$PATH"
done

echo "✅ Node.js and npm are available"

# Verify installations
echo ""
echo "✅ Verifying installations..."
echo "Python version: $(python3 --version)"
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "AWS CLI version: $(aws --version)"
echo "CDK version: $(cdk --version)"
echo "Docker version: $(docker --version)"
echo "Bun version: $(bun --version)"
echo ""
echo "Development CLIs:"
command -v claude-code &> /dev/null && echo "✅ Claude Code CLI installed" || echo "⚠️  Claude Code CLI not found"
command -v codex &> /dev/null && echo "✅ Codex CLI installed" || echo "⚠️  Codex CLI not found"
echo "ℹ️  Amazon Q: Available via VS Code extension (amazonwebservices.amazon-q-vscode)"

# Install Python dependencies for CookieFactory workspace
echo "📦 Installing Python dependencies..."
if [ -f "src/workspaces/cookiefactory/requirements.txt" ]; then
    pip3 install -r src/workspaces/cookiefactory/requirements.txt
    echo "✅ Python dependencies installed"
else
    echo "⚠️  requirements.txt not found, skipping Python dependencies"
fi

# Install CDK dependencies for timestream_telemetry module
echo "📦 Installing Timestream Telemetry CDK dependencies..."
if [ -d "src/modules/timestream_telemetry/cdk" ]; then
    cd src/modules/timestream_telemetry/cdk
    echo "🔄 Updating to latest CDK version..."
    npm install
    cd ../../../..
    echo "✅ Timestream Telemetry dependencies installed (CDK 2.168.0+)"
else
    echo "⚠️  Timestream Telemetry CDK directory not found"
fi

# Set up environment variables hints
echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Configure AWS credentials (already mounted from ~/.aws)"
echo "2. Set environment variables:"
echo "   export CDK_DEFAULT_ACCOUNT=<your-aws-account-id>"
echo "   export AWS_DEFAULT_REGION=us-east-1"
echo "   export CDK_DEFAULT_REGION=\$AWS_DEFAULT_REGION"
echo "   export GETTING_STARTED_DIR=\$PWD"
echo "   export TIMESTREAM_TELEMETRY_STACK_NAME=CookieFactoryTelemetry"
echo "   export WORKSPACE_ID=CookieFactory"
echo ""
echo "3. Bootstrap CDK:"
echo "   cdk bootstrap aws://<account-id>/us-east-1"
echo ""
echo "4. Follow the README.md or README.ja.md for detailed instructions"
echo ""
