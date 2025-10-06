# AI Models Directory

This directory contains the Phi-3 Mini ONNX model for local AI inference.

## Model Information

**Model:** Microsoft Phi-3 Mini 3.8B INT4 Quantized
**Format:** ONNX
**Size:** ~500 MB (INT4 quantized)
**Repository:** microsoft/Phi-3-mini-4k-instruct-onnx

## Download Instructions

### Option 1: Using Hugging Face CLI (Recommended)

```bash
# Install Hugging Face CLI
pip install -U "huggingface_hub[cli]"

# Navigate to this directory
cd assets/models/

# Download the INT4 CPU/Mobile model
huggingface-cli download microsoft/Phi-3-mini-4k-instruct-onnx \
  --include "cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/*" \
  --local-dir .
```

### Option 2: Manual Download

1. Visit: https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx
2. Navigate to: `cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/`
3. Download all files to this directory

## Required Files

After download, you should have:
- `phi-3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx` (~500 MB)
- `phi-3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx.data` (if separate)
- `genai_config.json` (model configuration)
- `tokenizer.json` (tokenizer data)
- `tokenizer_config.json` (tokenizer configuration)

## ⚠️ Important Notes

1. **Do NOT commit the model files to Git!**
   - The `.gitignore` already excludes `*.onnx` and `*.onnx.data` files
   - These files are too large for Git (500+ MB)

2. **Download before running the app**
   - The app will check for the model on initialization
   - If missing, it will fall back to template responses

3. **First-time setup**
   - Download takes ~5-10 minutes depending on internet speed
   - Model loads once at app startup (~2-3 seconds)

## Alternative: Phi-3.5 Mini (Newer)

If you want the latest version:

```bash
huggingface-cli download microsoft/Phi-3.5-mini-instruct-onnx \
  --include "cpu_and_mobile/cpu-int4-awq-block-128/*" \
  --local-dir .
```

## Troubleshooting

**Issue:** Model fails to load
- **Solution:** Check file integrity, ensure all required files are present

**Issue:** Out of memory
- **Solution:** Close other apps, restart device, try INT4 quantized version

**Issue:** Slow inference (>5 seconds)
- **Solution:** Device may not meet minimum specs, fall back to template responses
