# AI Training Data Structure

## Purpose
This directory contains training data for the Everyday Christian AI models:
1. **Theme Classifier (TFLite)** - Detects emotional/spiritual needs from user input
2. **Response Generator (LSTM)** - Generates pastoral responses in your voice

## Directory Structure

```
training_data/
├── pastoral_guidance/      # Your sermon content (30% of training data)
│   └── *.jsonl            # One guidance point per line
├── bible_verses/          # WEB Bible verses (70% of training data)
│   └── *.jsonl            # Verses tagged with themes
└── processed/             # Combined datasets ready for training
    ├── theme_classification.jsonl
    ├── response_generation.jsonl
    └── training_manifest.json
```

## Data Format

### Theme Classification (theme_classification.jsonl)
Each line is a JSON object for training the theme classifier:

```json
{"text": "I can't sleep, my mind keeps racing about everything", "theme": "anxiety", "confidence": 0.95}
{"text": "Why do good things happen to everyone but me?", "theme": "jealousy", "confidence": 0.90}
{"text": "I feel stuck and don't know what to do", "theme": "guidance", "confidence": 0.85}
```

**Fields:**
- `text`: User input (indirect language, real concerns)
- `theme`: Primary theme (anxiety, grief, anger, jealousy, etc.)
- `confidence`: How certain this theme is (0.0-1.0)

### Response Generation (response_generation.jsonl)
Each line is a training example for generating pastoral responses:

```json
{"input": "I'm feeling anxious about my future", "response": "Stop stressing about tomorrow's provision. Look at the birds—they don't store up food in barns, but your Heavenly Father feeds them. You're worth more than birds. If God takes care of them, how much more will he take care of you? Trust him.", "theme": "anxiety", "scripture": "Matthew 6:25-26", "source": "pastoral"}
{"input": "grief loss mourning", "response": "The LORD is near to those who have a broken heart. He doesn't distance himself from your pain—he draws closer.", "theme": "grief", "scripture": "Psalms 34:18", "source": "bible"}
```

**Fields:**
- `input`: User concern or theme keywords
- `response`: Pastoral guidance in your voice
- `theme`: Primary theme
- `scripture`: Bible reference used
- `source`: "pastoral" (your content) or "bible" (WEB verse)

## Training Data Ratio
- **70% Bible verses** (scriptural foundation, 31,103 verses)
- **30% Pastoral content** (your voice, ~140 guidance points)

## Next Steps
1. Convert pastoral text files → JSONL format
2. Extract themed WEB Bible verses → JSONL format
3. Combine into training datasets
4. Train TFLite theme classifier
5. Train LSTM response generator
