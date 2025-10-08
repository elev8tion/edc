#!/usr/bin/env python3
"""
Generate complete AI training dataset from scratch.

This script generates:
1. Theme classification data (indirect language → theme detection)
2. Response generation data (user input → pastoral response in your voice)

Uses: WEB Bible (70%) + Your pastoral voice patterns (30%)
"""

import json
import re
import sqlite3
from pathlib import Path
from typing import List, Dict, Any
import random

# Your pastoral voice patterns (learned from your content)
PASTORAL_PATTERNS = {
    "openings": [
        "Stop {action}. {reason}.",
        "You don't have to {worry}. {truth}.",
        "Listen to me. {direct_truth}.",
        "Here's the truth: {statement}.",
        "{question}? {answer}.",
    ],
    "encouragement": [
        "You can do this.",
        "You're not alone in this.",
        "God hasn't forgotten you.",
        "This isn't the end of your story.",
        "You're stronger than you think.",
    ],
    "direct_commands": [
        "Drop it.",
        "Let it go.",
        "Stop playing with it.",
        "Deal with it now.",
        "Bring it to God.",
        "Trust him.",
    ],
    "challenges": [
        "Stop waiting for them to {action}.",
        "You can't {negative} your way into {positive}.",
        "Don't let {thing} steal your {blessing}.",
        "If you want {desire}, {action}.",
    ]
}

# Indirect language patterns for theme classification
INDIRECT_LANGUAGE = {
    "anxiety": [
        "I can't sleep, my mind keeps racing",
        "Everything feels overwhelming right now",
        "I keep worrying about what might happen",
        "My chest feels tight when I think about tomorrow",
        "I feel like I'm drowning in all these responsibilities",
        "What if everything falls apart?",
        "I can't stop thinking about the worst case scenario",
        "I feel paralyzed by all these decisions",
    ],
    "grief": [
        "Nothing feels the same anymore",
        "I don't know how to move forward from this",
        "The pain just won't go away",
        "Why did this have to happen?",
        "I feel so empty inside",
        "Everyone else seems to be moving on but I can't",
        "I miss them so much it hurts",
        "How am I supposed to keep going?",
    ],
    "anger": [
        "I'm so tired of people treating me this way",
        "Why do they always get away with it?",
        "I can't let this go, it's eating me up inside",
        "They don't deserve my forgiveness",
        "I replay what they did over and over",
        "I want them to feel what I felt",
        "This rage is consuming me",
        "I can't believe they did that to me",
    ],
    "jealousy": [
        "Why do good things happen to everyone but me?",
        "They don't deserve what they have",
        "I worked harder than them, why did they get it?",
        "Everyone else's life looks so perfect",
        "I can't be happy for them right now",
        "Why am I always left behind?",
        "They have everything I've been praying for",
        "I feel so bitter when I see their success",
    ],
    "forgiveness": [
        "I don't know if I can forgive them",
        "They never even apologized",
        "How many times do I have to let this go?",
        "I keep remembering what they did",
        "They hurt me too badly",
        "I want to move on but I can't forget",
        "Do I really have to forgive them?",
        "What if they do it again?",
    ],
    "loneliness": [
        "Nobody really understands what I'm going through",
        "I feel so alone even in a crowd",
        "Everyone has someone except me",
        "I don't have anyone to talk to",
        "It feels like God has forgotten about me",
        "I'm tired of doing life by myself",
        "Where is everyone when I need them?",
        "I feel invisible",
    ],
    "provision": [
        "I don't know how I'm going to pay this bill",
        "The money just isn't stretching far enough",
        "I keep praying but nothing changes financially",
        "I'm tired of struggling to make ends meet",
        "What if I lose everything?",
        "I can't afford what my family needs",
        "Why does everyone else seem financially stable?",
        "I'm one emergency away from disaster",
    ],
}

def clean_bible_text(text: str) -> str:
    """Remove USFM markup and Strong's numbers from Bible text."""
    # Remove Strong's numbers
    text = re.sub(r'\|strong="[^"]+"\s*', '', text)
    # Remove USFM markers
    text = re.sub(r'\\+[a-z]+\s*|\s*\\+[a-z]+\*', '', text)
    text = re.sub(r'\+w\s*|\s*\+w\*', '', text)
    # Clean whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def generate_pastoral_response(theme: str, user_input: str, scripture_ref: str, scripture_text: str) -> str:
    """Generate a pastoral response in your voice based on theme."""

    responses = {
        "anxiety": [
            f"Stop stressing about tomorrow's provision. {scripture_text} If God takes care of them, how much more will he take care of you? Trust him.",
            f"You're carrying a weight God never asked you to carry. {scripture_text} Let him hold it. You focus on today.",
            f"Fear is a liar. {scripture_text} God is with you. He hasn't left. He won't leave. Breathe and believe that.",
        ],
        "grief": [
            f"The LORD is near to you right now. {scripture_text} He's not distant. He's not judging your tears. He's holding you through this.",
            f"Grief is not a sign of weak faith—it's evidence of real love. {scripture_text} Let yourself feel it, and let God heal it.",
            f"{scripture_text} One day, every tear will be wiped away. Until then, it's okay to cry. God catches every tear.",
        ],
        "anger": [
            f"Feel the anger, but don't let it control you. {scripture_text} Bring it to God before you bring it to them.",
            f"Bitterness will poison your soul faster than anything else. {scripture_text} Let it go before it destroys you.",
            f"{scripture_text} Don't let the sun go down on this. Deal with it today. Forgive them, not because they deserve it, but because YOU deserve peace.",
        ],
        "jealousy": [
            f"Their win is not your loss. {scripture_text} God has enough blessing for everybody. Stop comparing and start celebrating.",
            f"You're in a different chapter than they are. {scripture_text} Run YOUR race. Stay in YOUR lane. Trust YOUR timing.",
            f"Jealousy will rob your joy faster than anything. {scripture_text} Ask God to give you a content heart that celebrates others.",
        ],
        "forgiveness": [
            f"You didn't deserve his forgiveness, but he gave it anyway. {scripture_text} Do the same. Not because they earned it, but because Christ forgave you.",
            f"Unforgiveness hurts you more than it hurts them. {scripture_text} Let it go and get your life back.",
            f"{scripture_text} Forgiveness isn't for them—it's for you. It sets YOU free. Stop drinking poison and expecting them to die.",
        ],
        "loneliness": [
            f"You might feel alone, but you're not. {scripture_text} God is right there with you, closer than your next breath.",
            f"{scripture_text} God will never leave you. People might walk away, but he never will. Anchor yourself in that truth.",
            f"Loneliness is a signal, not a sentence. {scripture_text} Reach out. Connect. Don't let isolation become your identity.",
        ],
        "provision": [
            f"{scripture_text} God knows about the bill. He sees the need. And he's already making a way before you even ask.",
            f"Stop panicking. {scripture_text} The same God who feeds the birds will take care of you. Trust him with this.",
            f"Honor God with your firstfruits. {scripture_text} When you put him first, he takes care of the rest.",
        ],
    }

    theme_responses = responses.get(theme, [f"{scripture_text} Trust God in this season. He hasn't forgotten you."])
    return random.choice(theme_responses)

def extract_themed_bible_verses(db_path: Path) -> Dict[str, List[Dict]]:
    """Extract Bible verses organized by theme."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    theme_keywords = {
        "anxiety": ["anxious", "worry", "fear", "afraid", "overwhelm", "peace", "calm", "rest"],
        "grief": ["mourn", "sorrow", "comfort", "tears", "weep", "broken heart", "loss"],
        "anger": ["anger", "wrath", "bitter", "slow to anger", "gentle answer"],
        "jealousy": ["envy", "jealous", "covet", "content"],
        "forgiveness": ["forgive", "mercy", "reconcile", "pardon"],
        "loneliness": ["alone", "forsake", "with you", "never leave"],
        "provision": ["provide", "supply", "need", "daily bread"],
        "hope": ["hope", "trust", "faith", "confidence"],
        "strength": ["strong", "strength", "power", "courage"],
        "comfort": ["comfort", "peace", "rest"],
        "love": ["love", "compassion", "grace", "mercy"],
    }

    themed_verses = {}

    for theme, keywords in theme_keywords.items():
        search_conditions = " OR ".join([f"text LIKE '%{kw}%'" for kw in keywords[:4]])

        query = f"""
        SELECT reference, text
        FROM verses
        WHERE ({search_conditions})
        AND LENGTH(text) BETWEEN 50 AND 400
        LIMIT 100
        """

        cursor.execute(query)
        verses = []

        for ref, text in cursor.fetchall():
            clean_text = clean_bible_text(text)
            if len(clean_text) > 30:
                verses.append({
                    "reference": ref,
                    "text": clean_text,
                    "theme": theme
                })

        themed_verses[theme] = verses

    conn.close()
    return themed_verses

def main():
    """Generate complete training dataset."""
    project_root = Path(__file__).parent.parent
    training_dir = project_root / "assets" / "training_data"
    bible_db = project_root / "assets" / "bible.db"

    print("🔄 Generating AI Training Dataset...")
    print("=" * 60)

    # 1. Extract Bible verses by theme
    print("\n📖 Extracting WEB Bible verses by theme...")
    bible_verses = extract_themed_bible_verses(bible_db)
    total_bible = sum(len(verses) for verses in bible_verses.values())
    print(f"✅ Extracted {total_bible} themed Bible verses")

    # 2. Generate theme classification data (indirect language)
    print("\n🎯 Generating theme classification data...")
    classification_data = []

    for theme, phrases in INDIRECT_LANGUAGE.items():
        for phrase in phrases:
            classification_data.append({
                "text": phrase,
                "theme": theme,
                "confidence": 0.92
            })

    print(f"✅ Created {len(classification_data)} indirect language examples")

    # 3. Generate response data (Q&A pairs)
    print("\n💬 Generating pastoral response data...")
    response_data = []

    # From Bible verses (70%)
    for theme, verses in bible_verses.items():
        for verse in verses:
            # Bible verse as response
            response_data.append({
                "input": f"{theme} {' '.join(INDIRECT_LANGUAGE.get(theme, [theme])[0].split()[:4])}",
                "response": verse["text"],
                "theme": theme,
                "scripture": verse["reference"],
                "source": "bible"
            })

    # From pastoral voice patterns (30%)
    pastoral_count = int(total_bible * 0.3 / 0.7)  # Calculate 30% ratio

    for theme in INDIRECT_LANGUAGE.keys():
        theme_verses = bible_verses.get(theme, [])
        if not theme_verses:
            continue

        samples_needed = min(pastoral_count // len(INDIRECT_LANGUAGE), len(theme_verses))

        for i in range(samples_needed):
            verse = theme_verses[i % len(theme_verses)]
            user_phrase = INDIRECT_LANGUAGE[theme][i % len(INDIRECT_LANGUAGE[theme])]

            pastoral_response = generate_pastoral_response(
                theme, user_phrase, verse["reference"], verse["text"]
            )

            response_data.append({
                "input": user_phrase,
                "response": pastoral_response,
                "theme": theme,
                "scripture": verse["reference"],
                "source": "pastoral"
            })

    pastoral_examples = [r for r in response_data if r["source"] == "pastoral"]
    bible_examples = [r for r in response_data if r["source"] == "bible"]

    print(f"✅ Generated {len(response_data)} response examples")
    print(f"   • Pastoral voice: {len(pastoral_examples)} ({len(pastoral_examples)/len(response_data)*100:.1f}%)")
    print(f"   • Bible verses: {len(bible_examples)} ({len(bible_examples)/len(response_data)*100:.1f}%)")

    # 4. Save datasets
    print("\n💾 Saving training datasets...")

    # Save response generation data
    output_file = training_dir / "processed" / "response_generation.jsonl"
    with open(output_file, 'w', encoding='utf-8') as f:
        for example in response_data:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')
    print(f"✅ Saved {output_file}")

    # Save theme classification data
    output_file = training_dir / "processed" / "theme_classification.jsonl"
    with open(output_file, 'w', encoding='utf-8') as f:
        for example in classification_data:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')
    print(f"✅ Saved {output_file}")

    # Save manifest
    manifest = {
        "version": "2.0",
        "generated": "2025-10-08",
        "datasets": {
            "response_generation": {
                "file": "response_generation.jsonl",
                "total_examples": len(response_data),
                "pastoral_voice": len(pastoral_examples),
                "bible_verses": len(bible_examples),
                "pastoral_percentage": round(len(pastoral_examples)/len(response_data)*100, 1),
                "bible_percentage": round(len(bible_examples)/len(response_data)*100, 1),
            },
            "theme_classification": {
                "file": "theme_classification.jsonl",
                "examples": len(classification_data),
                "themes": list(INDIRECT_LANGUAGE.keys())
            }
        },
        "themes_covered": list(set(INDIRECT_LANGUAGE.keys()) | set(bible_verses.keys())),
        "total_themes": len(set(INDIRECT_LANGUAGE.keys()) | set(bible_verses.keys())),
    }

    manifest_file = training_dir / "processed" / "training_manifest.json"
    with open(manifest_file, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    print(f"✅ Saved {manifest_file}")

    print("\n" + "=" * 60)
    print("✅ TRAINING DATA GENERATION COMPLETE!")
    print("=" * 60)
    print(f"\n📊 Final Summary:")
    print(f"   Response Generation: {len(response_data)} examples")
    print(f"     → {len(pastoral_examples)} in your pastoral voice ({len(pastoral_examples)/len(response_data)*100:.1f}%)")
    print(f"     → {len(bible_examples)} WEB Bible verses ({len(bible_examples)/len(response_data)*100:.1f}%)")
    print(f"\n   Theme Classification: {len(classification_data)} examples")
    print(f"     → Covers {len(INDIRECT_LANGUAGE)} emotional/spiritual themes")
    print(f"\n   Total Themes: {manifest['total_themes']}")
    print(f"\n🎯 Ready for AI model training!")

if __name__ == "__main__":
    main()
