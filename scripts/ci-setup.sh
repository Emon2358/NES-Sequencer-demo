#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y cc65 jq unzip wget ca-certificates

# ======== FamiStudio 最新リリースを取得 ========
echo "Fetching latest FamiStudio release info..."
API_JSON=$(curl -s https://api.github.com/repos/BleuBleu/FamiStudio/releases/latest)

ASSET_URL=$(echo "$API_JSON" | jq -r '.assets[] | select(.name|test("Linux|linux|AppImage")) | .browser_download_url' | head -n1)

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "❌ FamiStudio Linux release not found!"
  exit 1
fi

echo "Downloading FamiStudio asset: $ASSET_URL"
curl -L "$ASSET_URL" -o /tmp/FamiStudio.AppImage

mkdir -p tools/bin
chmod +x /tmp/FamiStudio.AppImage
mv /tmp/FamiStudio.AppImage tools/bin/FamiStudio

echo "✅ FamiStudio setup complete at tools/bin/FamiStudio"

# ======== 動作確認 ========
if [ -f tools/bin/FamiStudio ]; then
  echo "Checking FamiStudio binary..."
  file tools/bin/FamiStudio
else
  echo "❌ FamiStudio binary missing!"
  exit 1
fi

echo "✅ ci-setup.sh completed successfully!"
