# Text Generator Model Training

This directory contains scripts to train the LSTM text generation model for the everyday-christian app.

## Prerequisites

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## Training the Model

```bash
# Run training script
python train_text_generator.py
```

This will:
1. Download Bible (KJV) text
2. Create character vocabulary
3. Train LSTM model (~30 epochs, takes 1-2 hours on CPU)
4. Convert to TFLite format
5. Save model to `../assets/models/`

## Model Output

After training, you'll get:
- `text_generator.tflite` (~20-40MB) - The TFLite model
- `char_vocab.txt` - Character vocabulary file

## Using in Flutter

1. Copy the generated files:
```bash
cp ../assets/models/text_generator.tflite ../assets/models/
cp ../assets/models/char_vocab.txt ../assets/models/
```

2. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/models/text_generator.tflite
    - assets/models/char_vocab.txt
```

3. The `TextGeneratorService` will automatically load these files.

## Customizing Training

Edit `train_text_generator.py` to:
- Change training data sources
- Adjust model size (RNN_UNITS, EMBEDDING_DIM)
- Modify sequence length
- Add more epochs for better quality

## Model Size vs Quality

| RNN Units | Model Size | Quality |
|-----------|------------|---------|
| 512       | ~10MB      | Basic   |
| 1024      | ~25MB      | Good    |
| 2048      | ~80MB      | Better  |

Default is 1024 for balanced size/quality.
