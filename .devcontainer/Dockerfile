FROM python:3.11-slim

ARG TZ
ENV TZ="${TZ:-America/Los_Angeles}"

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install basic development tools
RUN apt-get update && apt-get install -y \
    less \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    gh \
    jq \
    curl \
    wget \
    vim \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Create vscode user
RUN useradd -m -s /bin/zsh -u 1000 vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode

# Ensure vscode user has access to npm global
RUN mkdir -p /usr/local/share/npm-global && \
    chown -R vscode:vscode /usr/local/share

# Persist bash/zsh history
RUN mkdir -p /commandhistory && \
    touch /commandhistory/.bash_history /commandhistory/.zsh_history && \
    chown -R vscode:vscode /commandhistory

# Create workspace and config directories
RUN mkdir -p /workspace /home/vscode/.claude /home/vscode/.aws && \
    chown -R vscode:vscode /workspace /home/vscode/.claude /home/vscode/.aws

WORKDIR /workspace

# Set `DEVCONTAINER` environment variable
ENV DEVCONTAINER=true

# Switch to vscode user
USER vscode

# Install global npm packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh
ENV SHELL=/bin/zsh

# Install Oh My Zsh with plugins and theme
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -p git \
    -p fzf \
    -p aws \
    -p docker \
    -p kubectl \
    -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
    -a "source /usr/share/doc/fzf/examples/completion.zsh" \
    -a "export HISTFILE=/commandhistory/.zsh_history" \
    -x

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.1.38"
ENV BUN_INSTALL="/home/vscode/.bun"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"
RUN echo 'export BUN_INSTALL="$HOME/.bun"' >> /home/vscode/.zshrc && \
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /home/vscode/.zshrc

# Install AWS CDK
RUN npm install -g aws-cdk@latest

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Install OpenAI Codex CLI
RUN npm install -g @openai/codex

# Install Python development tools and Amazon Q CLI
RUN pip3 install --user --no-cache-dir \
    black \
    pylint \
    pytest \
    boto3 \
    awscli-local \
    amazon-q-developer-cli

CMD ["/bin/zsh"]
