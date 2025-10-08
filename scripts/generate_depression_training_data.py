#!/usr/bin/env python3
"""
Generate AI training data for the DEPRESSION theme.
Extracts verses from WEB Bible, cleans them, and generates pastoral responses.
"""

import sqlite3
import json
import re
from pathlib import Path

# Database path
DB_PATH = "/Users/kcdacre8tor/ everyday-christian/assets/bible.db"
OUTPUT_PATH = "/Users/kcdacre8tor/ everyday-christian/assets/training_data/themes/depression.jsonl"

# Search terms for depression-related themes
SEARCH_TERMS = [
    "soul AND (troubled OR cast down OR despair)",
    "hope OR hopeless",
    "darkness OR dark",
    "despair",
    "weary OR weariness",
    "burden OR heavy laden",
    "trouble OR troubles",
    "sorrow OR sorrowful",
    "comfort OR comforted",
    "strength OR strengthen",
    "wait OR waiting",
    "refuge OR shelter"
]

def clean_verse_text(text):
    """Remove Strong's numbers and USFM markup from verse text."""
    # Remove Strong's numbers: |strong="H1234"
    text = re.sub(r'\|strong="[^"]*"', '', text)
    # Remove footnote markers: + X:Y
    text = re.sub(r'\s*\+\s*\d+:\d+[^|]*', '', text)
    # Clean up extra spaces and pipes
    text = re.sub(r'\s+', ' ', text)
    text = text.replace('|', '').strip()
    return text

def get_depression_verses(limit=30):
    """Extract verses related to depression themes."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    verses = []
    seen_references = set()

    # Try different search queries
    queries = [
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE v.text LIKE '%soul%' AND (v.text LIKE '%cast down%' OR v.text LIKE '%despair%' OR v.text LIKE '%troubled%') LIMIT 5",
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE v.text LIKE '%darkness%' AND v.text LIKE '%light%' LIMIT 5",
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE v.text LIKE '%hope%' LIMIT 5",
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE (v.text LIKE '%weary%' OR v.text LIKE '%burden%') LIMIT 5",
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE v.text LIKE '%comfort%' LIMIT 5",
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE v.text LIKE '%strength%' AND (v.text LIKE '%give%' OR v.text LIKE '%renew%') LIMIT 5",
        "SELECT DISTINCT v.reference, v.text FROM verses v WHERE v.text LIKE '%refuge%' OR v.text LIKE '%shelter%' LIMIT 5",
    ]

    for query in queries:
        cursor.execute(query)
        results = cursor.fetchall()

        for ref, text in results:
            if ref not in seen_references and len(verses) < limit:
                cleaned_text = clean_verse_text(text)
                if len(cleaned_text) > 20:  # Filter out too-short verses
                    verses.append({
                        "reference": ref,
                        "text": cleaned_text
                    })
                    seen_references.add(ref)

    conn.close()
    return verses

# Indirect language examples (how users express depression)
INDIRECT_PHRASES = [
    "I don't feel anything anymore",
    "What's the point of even trying",
    "Everything feels heavy",
    "I'm just going through the motions",
    "Nothing brings me joy",
    "I can't see a way forward",
    "It's like I'm stuck in darkness",
    "I feel empty inside",
    "I'm so tired of fighting",
    "Why should I even bother"
]

# Pastoral response templates (using the established voice pattern)
def generate_pastoral_responses(verses):
    """Generate pastoral responses using the voice pattern."""
    responses = []

    # Template patterns based on the established voice
    templates = [
        {
            "input": "I don't feel anything anymore",
            "pattern": "Stop believing the numbness is permanent. {truth}. {scripture}.",
            "truth": "Feelings come and go, but God's presence is constant"
        },
        {
            "input": "What's the point of even trying",
            "pattern": "{truth}. {scripture}. Your pain has purpose.",
            "truth": "You don't have to see the ending to take the next step"
        },
        {
            "input": "Everything feels heavy",
            "pattern": "Drop the weight you weren't meant to carry. {scripture}. {truth}.",
            "truth": "God invites you to rest, not to white-knuckle through life"
        },
        {
            "input": "I'm just going through the motions",
            "pattern": "{truth}. {scripture}. That's where faith begins.",
            "truth": "Even 'going through the motions' is showing up"
        },
        {
            "input": "Nothing brings me joy",
            "pattern": "Stop waiting to feel joy before you believe. {scripture}. {truth}.",
            "truth": "Joy isn't a feeling you manufacture—it's a Person you encounter"
        },
        {
            "input": "I can't see a way forward",
            "pattern": "{truth}. {scripture}. One step is enough.",
            "truth": "You don't need to see the whole path, just the next step"
        },
        {
            "input": "It's like I'm stuck in darkness",
            "pattern": "{scripture}. {truth}. The darkness doesn't get the final word.",
            "truth": "Even the darkest night ends with sunrise"
        },
        {
            "input": "I feel empty inside",
            "pattern": "Stop trying to fill the void with anything but God. {scripture}. {truth}.",
            "truth": "That emptiness? It's God-shaped, and only He fits"
        },
        {
            "input": "I'm so tired of fighting",
            "pattern": "{truth}. {scripture}. You can stop fighting alone.",
            "truth": "God hasn't forgotten you in this battle"
        },
        {
            "input": "Why should I even bother",
            "pattern": "{scripture}. {truth}. Your life matters.",
            "truth": "Because your story isn't over, and God's still writing"
        }
    ]

    for i, template in enumerate(templates):
        if i < len(verses):
            verse = verses[i]
            response = template["pattern"].replace("{truth}", template["truth"])
            response = response.replace("{scripture}", f'"{verse["text"]}" ({verse["reference"]})')

            responses.append({
                "input": template["input"],
                "response": response,
                "theme": "depression",
                "scripture": verse["reference"],
                "source": "pastoral"
            })

    return responses

def main():
    """Main function to generate training data."""
    print("Extracting verses from WEB Bible...")
    verses = get_depression_verses(limit=25)
    print(f"Found {len(verses)} clean verses")

    print("\nGenerating pastoral responses...")
    pastoral_responses = generate_pastoral_responses(verses)

    # Add verse-only entries
    verse_entries = []
    for verse in verses[:15]:  # Use remaining verses as direct scripture entries
        verse_entries.append({
            "input": f"struggling with {verse['reference'].split()[0].lower()}",
            "response": f'"{verse["text"]}" ({verse["reference"]})',
            "theme": "depression",
            "scripture": verse["reference"],
            "source": "bible"
        })

    # Combine all entries
    all_entries = pastoral_responses + verse_entries

    # Create output directory
    output_dir = Path(OUTPUT_PATH).parent
    output_dir.mkdir(parents=True, exist_ok=True)

    # Write to JSONL file
    print(f"\nWriting to {OUTPUT_PATH}...")
    with open(OUTPUT_PATH, 'w') as f:
        for entry in all_entries:
            f.write(json.dumps(entry) + '\n')

    print(f"\n✅ Depression theme complete: {len(all_entries)} examples generated")
    print(f"   - {len(pastoral_responses)} pastoral responses")
    print(f"   - {len(verse_entries)} scripture references")
    print(f"\nSample verses found:")
    for verse in verses[:5]:
        print(f"   {verse['reference']}: {verse['text'][:80]}...")

if __name__ == "__main__":
    main()
