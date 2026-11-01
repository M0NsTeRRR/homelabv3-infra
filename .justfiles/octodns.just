# Validate internal records
[working-directory: '../octodns']
validate-internal:
    uv run octodns-validate --config-file=./internal/config.yaml --all

# Sync internal records
[working-directory: '../octodns']
sync-internal:
    uv run octodns-sync --config-file=./internal/config.yaml --doit --force

# Validate external records
[working-directory: '../octodns']
validate-external:
    uv run octodns-validate --config-file=./external/config.yaml --all

# Sync external records
[working-directory: '../octodns']
sync-external:
    uv run octodns-sync --config-file=./external/config.yaml --doit --force
