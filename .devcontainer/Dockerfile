FROM ubuntu:22.04

ARG TZ
ENV TZ="${TZ:-America/Los_Angeles}" \
    DEVCONTAINER=true \
    NPM_CONFIG_PREFIX=/usr/local/share/npm-global \
    SHELL=/bin/zsh

# System packages, Python 3.13, Node.js 20, GitHub CLI, AWS CLI
RUN apt-get update && apt-get install -y \
    less git procps sudo zsh man-db unzip gnupg2 jq curl wget vim \
    ca-certificates apt-transport-https build-essential software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update && apt-get install -y python3.13 python3.13-dev python3.13-venv python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1 \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y gh nodejs \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscli.zip \
    && unzip /tmp/awscli.zip -d /tmp && /tmp/aws/install && rm -rf /tmp/awscli.zip /tmp/aws \
    && git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/share/fzf \
    && /usr/local/share/fzf/install --all --no-update-rc \
    && ln -s /usr/local/share/fzf/bin/fzf /usr/local/bin/fzf \
    && rm -rf /var/lib/apt/lists/*

# Create vscode user and directories
RUN useradd -m -s /bin/zsh -u 1000 vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode && chmod 0440 /etc/sudoers.d/vscode \
    && mkdir -p /usr/local/share/npm-global /commandhistory /workspace /home/vscode/.claude /home/vscode/.aws \
    && touch /commandhistory/.bash_history /commandhistory/.zsh_history \
    && chown -R vscode:vscode /usr/local/share /commandhistory /workspace /home/vscode/.claude /home/vscode/.aws

WORKDIR /workspace
USER vscode

ENV PATH="/home/vscode/.local/bin:/home/vscode/.bun/bin:/usr/local/share/npm-global/bin:${PATH}" \
    BUN_INSTALL="/home/vscode/.bun"

# Oh My Zsh, Bun, npm packages, Python tools
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -p git -p fzf -p aws -p docker -p kubectl \
    -a "[ -f /usr/local/share/fzf/shell/key-bindings.zsh ] && source /usr/local/share/fzf/shell/key-bindings.zsh" \
    -a "[ -f /usr/local/share/fzf/shell/completion.zsh ] && source /usr/local/share/fzf/shell/completion.zsh" \
    -a "export HISTFILE=/commandhistory/.zsh_history" -x \
    && curl -fsSL https://bun.sh/install | bash -s "bun-v1.1.38" \
    && echo 'export BUN_INSTALL="$HOME/.bun"' >> /home/vscode/.zshrc \
    && echo 'export PATH="$HOME/.local/bin:$BUN_INSTALL/bin:/usr/local/share/npm-global/bin:$PATH"' >> /home/vscode/.zshrc \
    && echo 'export NPM_CONFIG_PREFIX=/usr/local/share/npm-global' >> /home/vscode/.zshrc \
    && npm install -g aws-cdk@latest @anthropic-ai/claude-code @openai/codex \
    && pip3 install --user --no-cache-dir black pylint pytest boto3 awscli-local

CMD ["/bin/zsh"]
