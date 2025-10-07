#!/bin/bash
# Download AI models for Everyday Christian app

echo "📥 Downloading Phi-3 Mini INT4 model..."
echo "This will download ~500 MB of model files."
echo ""

# Check if Hugging Face CLI is installed
if ! command -v huggingface-cli &> /dev/null; then
    echo "❌ Hugging Face CLI not found."
    echo "Install with: pip install -U 'huggingface_hub[cli]'"
    exit 1
fi

# Navigate to models directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/../assets/models" || exit 1

echo "📂 Working directory: $(pwd)"
echo ""

# Download model
echo "Downloading from microsoft/Phi-3-mini-4k-instruct-onnx..."
huggingface-cli download microsoft/Phi-3-mini-4k-instruct-onnx \
  --include "cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/*" \
  --local-dir . \
  --local-dir-use-symlinks False

# Verify files
echo ""
echo "✅ Download complete! Verifying files..."
REQUIRED_FILES=(
    "phi-3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx"
    "tokenizer.json"
    "tokenizer_config.json"
    "genai_config.json"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(du -h "$file" | cut -f1)
        echo "  ✅ $file ($SIZE)"
    else
        echo "  ❌ $file (missing)"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo ""
    echo "🎉 All model files downloaded successfully!"
    echo "You can now run the app with real AI inference."
    echo ""
    echo "To test: flutter run"
else
    echo ""
    echo "⚠️  $MISSING file(s) missing. Please check the download."
fi
