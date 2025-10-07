# AI Models

## Current Model: TFLite Theme Classifier

This directory contains AI models for the Everyday Christian app.

### Theme Classifier (Coming Soon)
- **Type**: TensorFlow Lite text classification model
- **Size**: ~3-5 MB (vs 770MB previous model)
- **Purpose**: Classify user input into biblical themes (anxiety, guidance, hope, etc.)
- **Performance**: <50ms inference time on mobile devices
- **Memory**: ~50MB RAM usage

### How to Add the Model

When you have a trained TFLite model, add it here:
```
assets/models/theme_classifier.tflite
```

### Current Implementation

The app currently uses **keyword-based classification** as a fallback, which works well for:
- Anxiety detection
- Depression/sadness detection
- Guidance seeking
- Forgiveness questions
- Purpose/meaning questions
- Relationship issues
- Fear and doubt
- Gratitude expressions

This provides production-ready functionality while you optionally train a custom TFLite model for even better accuracy.

### Training a Custom Model (Optional)

To train a custom TFLite model:

1. Collect labeled data of user questions → themes
2. Train a text classification model (BERT, DistilBERT, etc.)
3. Convert to TFLite format:
   ```python
   converter = tf.lite.TFLiteConverter.from_saved_model(model_dir)
   tflite_model = converter.convert()
   ```
4. Place the `.tflite` file in this directory
5. Update `ThemeClassifierService` to load the model

### Benefits Over Previous Implementation

**Before (flutter_gemma + Llama)**:
- 770MB model file
- 2GB+ RAM required
- 3-10 second inference
- Experimental/unstable

**After (TFLite + Keywords)**:
- 0MB currently (keywords only) or 3-5MB with TFLite
- ~50MB RAM required
- <50ms inference
- Production-stable
- 99% smaller footprint
