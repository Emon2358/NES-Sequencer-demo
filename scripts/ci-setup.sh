#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update -y
# cc65 (ca65/ld65) と jq, unzip, wget を入れる
sudo apt-get install -y cc65 jq unzip wget ca-certificates

# FamiStudio の最新リリースを GitHub から取得（Linux x64 asset を探す）
API_JSON=$(curl -s https://api.github.com/repos/BleuBleu/FamiStudio/releases/latest)
ASSET_URL=$(echo "$API_JSON" | jq -r '.assets[] | select(.name|test("Linux|linux|AMD64|amd64|AppImage")) | .browser_download_url' | head -n1)

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "FamiStudio release asset not found via API. Aborting."
  exit 1
fi

echo "Downloading FamiStudio asset: $ASSET_URL"
curl -L "$ASSET_URL" -o /tmp/famistudio_asset.zip

mkdir -p tools/famistudio
# try unzip / tar
if file /tmp/famistudio_asset.zip | grep -i zip >/dev/null 2>&1; then
  unzip -q /tmp/famistudio_asset.zip -d tools/famistudio
else
  # fallback: try tar
  tar -xf /tmp/famistudio_asset.zip -C tools/famistudio || true
fi

# Locate executable (FamiStudio binary name can vary)
# prefer a file named 'FamiStudio' or '*.AppImage'
FS_BIN=$(find tools/famistudio -maxdepth 2 -type f -executable -name 'FamiStudio*' | head -n1 || true)
if [ -z "$FS_BIN" ]; then
  FS_BIN=$(find tools/famistudio -maxdepth 2 -type f -name '*.AppImage' | head -n1 || true)
fi

if [ -z "$FS_BIN" ]; then
  echo "Could not find FamiStudio binary in downloaded archive. Listing contents:"
  ls -R tools/famistudio
  exit 1
fi

# make wrapper path
mkdir -p tools/bin
cp "$FS_BIN" tools/bin/FamiStudio
chmod +x tools/bin/FamiStudio
echo "FamiStudio installed to tools/bin/FamiStudio"
export PATH="$PWD/tools/bin:$PATH"
