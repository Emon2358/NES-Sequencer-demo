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
if file /tmp/
