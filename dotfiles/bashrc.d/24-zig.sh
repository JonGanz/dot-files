# Zig environment (zig lives in /usr/local/bin); adds it to PATH only if missing.
if [ -d "/usr/local/bin" ] && [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    export PATH="/usr/local/bin:$PATH"
fi
