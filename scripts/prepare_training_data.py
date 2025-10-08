#!/usr/bin/env python3
"""
Prepare training data for AI models from pastoral content and WEB Bible.

This script:
1. Converts pastoral guidance text files → JSONL training format
2. Extracts themed WEB Bible verses → JSONL training format
3. Combines into final training datasets
"""

import json
import re
import sqlite3
from pathlib import Path
from typing import List, Dict, Any

# Theme mappings
THEME_KEYWORDS = {
    "anxiety": ["anxiety", "anxious", "worry", "fear", "afraid", "stress", "overwhelm"],
    "grief": ["grief", "loss", "mourn", "sorrow", "death", "died", "tears", "weep"],
    "anger": ["anger", "angry", "wrath", "rage", "furious", "bitter"],
    "jealousy": ["jealous", "envy", "covet", "comparison", "compete"],
    "forgiveness": ["forgive", "forgiveness", "mercy", "reconcile", "pardon"],
    "loneliness": ["lonely", "alone", "isolated", "forsake", "abandon"],
    "provision": ["provide", "provision", "need", "supply", "money", "financial"],
    "marriage": ["marriage", "husband", "wife", "spouse", "relationship"],
    "sin": ["sin", "repent", "holy", "righteousness", "temptation"],
    "hope": ["hope", "trust", "faith", "believe", "confidence"],
    "strength": ["strong", "strength", "power", "courage", "endure"],
    "comfort": ["comfort", "peace", "rest", "assurance", "calm"],
    "guidance": ["guide", "path", "way", "direction", "purpose"],
    "love": ["love", "compassion", "grace", "kindness", "mercy"]
}

def detect_theme(text: str) -> tuple[str, float]:
    """Detect primary theme from text content."""
    text_lower = text.lower()
    theme_scores = {}

    for theme, keywords in THEME_KEYWORDS.items():
        score = sum(1 for keyword in keywords if keyword in text_lower)
        if score > 0:
            theme_scores[theme] = score

    if not theme_scores:
        return "general", 0.5

    # Get theme with highest score
    primary_theme = max(theme_scores, key=theme_scores.get)
    max_score = theme_scores[primary_theme]

    # Confidence based on keyword matches
    confidence = min(0.95, 0.5 + (max_score * 0.15))

    return primary_theme, confidence


def parse_pastoral_file(file_path: Path) -> List[Dict[str, Any]]:
    """Parse a pastoral guidance text file into training examples."""
    content = file_path.read_text(encoding='utf-8')

    examples = []

    # Try format 1: With quotes around the opening line
    pattern1 = r'(\d+)\.\s+(.+?)\n"(.+?)"\nAdvice:\s+(.+?)\nScripture Reference:\s+"(.+?)"\s*—\s*(.+?)(?=\n\d+\.|\Z)'
    for match in re.finditer(pattern1, content, re.DOTALL):
        number, title, quote, advice, verse_text, reference = match.groups()
        theme, confidence = detect_theme(f"{title} {quote} {advice}")
        examples.append({
            "input": title.strip(),
            "response": advice.strip(),
            "theme": theme,
            "scripture": reference.strip(),
            "source": "pastoral",
            "quote": quote.strip()
        })

    # Try format 2: Without quotes around opening line
    pattern2 = r'(\d+)\.\s+(.+?)\nAdvice:\s+(.+?)\nScripture Reference:\s+"(.+?)"\s*—\s*(.+?)(?=\n\d+\.|\Z)'
    for match in re.finditer(pattern2, content, re.DOTALL):
        number, title, advice, verse_text, reference = match.groups()
        theme, confidence = detect_theme(f"{title} {advice}")
        examples.append({
            "input": title.strip(),
            "response": advice.strip(),
            "theme": theme,
            "scripture": reference.strip(),
            "source": "pastoral",
            "quote": ""
        })

    # Try format 3: Emoji + title format (from wt.txt)
    pattern3 = r'[🕰️✝️🌍📖💡❤️🤝🙏🌅]+\s+(\d+)\.\s+(.+?)\nAdvice:\s+(.+?)\nBible References?:\s+(.+?)(?=\n[🕰️✝️🌍📖💡❤️🤝🙏🌅]|\n\d+\.|\Z)'
    for match in re.finditer(pattern3, content, re.DOTALL):
        number, title, advice, references = match.groups()
        theme, confidence = detect_theme(f"{title} {advice}")

        # Extract first reference
        ref_match = re.search(r'"(.+?)"\s*—\s*(.+?)(?:\n|$)', references)
        if ref_match:
            verse_text, reference = ref_match.groups()
        else:
            reference = references.split('\n')[0].strip()

        examples.append({
            "input": title.strip(),
            "response": advice.strip(),
            "theme": theme,
            "scripture": reference.strip(),
            "source": "pastoral",
            "quote": ""
        })

    return examples


def extract_bible_verses(db_path: Path, themes: Dict[str, List[str]]) -> List[Dict[str, Any]]:
    """Extract themed verses from WEB Bible database."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    examples = []

    for theme, keywords in themes.items():
        # Build search query
        search_conditions = " OR ".join([f"text LIKE '%{kw}%'" for kw in keywords[:3]])

        query = f"""
        SELECT reference, text
        FROM verses
        WHERE ({search_conditions})
        AND LENGTH(text) < 500
        LIMIT 50
        """

        cursor.execute(query)

        for reference, text in cursor.fetchall():
            # Clean text (remove Strong's numbers)
            clean_text = re.sub(r'\|strong="[^"]+"\s*', '', text)
            clean_text = re.sub(r'\+w\s*|\s*\+w\*', '', clean_text)
            clean_text = re.sub(r'\s+', ' ', clean_text).strip()

            if len(clean_text) < 20:  # Skip very short verses
                continue

            example = {
                "input": f"{theme} {' '.join(keywords[:2])}",
                "response": clean_text,
                "theme": theme,
                "scripture": reference,
                "source": "bible"
            }
            examples.append(example)

    conn.close()
    return examples


def create_theme_classification_data(examples: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Create theme classification training data."""
    classification_data = []

    for ex in examples:
        # Create variations for indirect language
        base_text = ex.get('quote', ex.get('response', ''))

        # Extract first sentence for training
        first_sentence = base_text.split('.')[0].strip()

        if len(first_sentence) > 10:
            classification_data.append({
                "text": first_sentence,
                "theme": ex['theme'],
                "confidence": 0.90 if ex['source'] == 'pastoral' else 0.80
            })

    return classification_data


def main():
    """Main processing function."""
    project_root = Path(__file__).parent.parent
    training_dir = project_root / "assets" / "training_data"
    docs_dir = Path.home() / "Documents"

    print("🔄 Processing pastoral guidance files...")

    # Process pastoral files from Documents
    pastoral_examples = []
    pastoral_files = list(docs_dir.glob("pastoral guidance*.txt"))

    for file_path in pastoral_files:
        print(f"  📄 {file_path.name}")
        try:
            examples = parse_pastoral_file(file_path)
            pastoral_examples.extend(examples)
            print(f"     ✅ Extracted {len(examples)} guidance points")
        except Exception as e:
            print(f"     ❌ Error: {e}")

    print(f"\n✅ Total pastoral examples: {len(pastoral_examples)}")

    # Extract Bible verses
    print("\n🔄 Extracting WEB Bible verses...")
    bible_db = project_root / "assets" / "bible.db"
    bible_examples = extract_bible_verses(bible_db, THEME_KEYWORDS)
    print(f"✅ Total Bible examples: {len(bible_examples)}")

    # Combine for response generation
    all_examples = pastoral_examples + bible_examples

    # Save response generation data
    output_file = training_dir / "processed" / "response_generation.jsonl"
    with open(output_file, 'w', encoding='utf-8') as f:
        for example in all_examples:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')

    print(f"\n✅ Saved {len(all_examples)} examples to {output_file}")

    # Create theme classification data
    print("\n🔄 Creating theme classification data...")
    classification_data = create_theme_classification_data(all_examples)

    output_file = training_dir / "processed" / "theme_classification.jsonl"
    with open(output_file, 'w', encoding='utf-8') as f:
        for example in classification_data:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')

    print(f"✅ Saved {len(classification_data)} examples to {output_file}")

    # Create manifest
    manifest = {
        "version": "1.0",
        "created": "2025-10-08",
        "datasets": {
            "response_generation": {
                "file": "response_generation.jsonl",
                "examples": len(all_examples),
                "pastoral": len(pastoral_examples),
                "bible": len(bible_examples)
            },
            "theme_classification": {
                "file": "theme_classification.jsonl",
                "examples": len(classification_data)
            }
        },
        "themes": list(THEME_KEYWORDS.keys()),
        "source_files": [f.name for f in pastoral_files]
    }

    manifest_file = training_dir / "processed" / "training_manifest.json"
    with open(manifest_file, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Training data preparation complete!")
    print(f"\n📊 Summary:")
    print(f"   - Response generation: {len(all_examples)} examples")
    print(f"     • Pastoral voice: {len(pastoral_examples)} ({len(pastoral_examples)/len(all_examples)*100:.1f}%)")
    print(f"     • Bible verses: {len(bible_examples)} ({len(bible_examples)/len(all_examples)*100:.1f}%)")
    print(f"   - Theme classification: {len(classification_data)} examples")
    print(f"   - Themes covered: {len(THEME_KEYWORDS)}")


if __name__ == "__main__":
    main()
