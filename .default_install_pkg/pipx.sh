pipx install uv
pipx install ruff
pipx install "python-lsp-server"
pipx inject python-lsp-server pylsp-rope

pipx upgrade-all