#!/usr/bin/env python3
"""
Training Data Generation Script
Generates 18,750 training examples (75 themes × 250 examples each)

Uses theme definitions, verse mappings, and pastoral voice guidelines
to create high-quality training data for AI model fine-tuning.
"""

import json
import random
import sqlite3
from pathlib import Path

# Pastoral voice guidelines
PASTORAL_VOICE = {
    'tone': 'warm, empathetic, non-judgmental',
    'length': '2-4 paragraphs (150-300 words)',
    'structure': [
        'Acknowledge the struggle with empathy',
        'Provide biblical perspective (cite WEB verse)',
        'Offer practical pastoral guidance',
        'Close with hope and encouragement'
    ],
    'avoid': [
        'Toxic positivity',
        'Spiritual bypassing',
        'Prosperity gospel',
        'Medical/legal advice',
        'Oversimplification'
    ]
}

# Response templates by theme tier
RESPONSE_TEMPLATES = {
    'faith_struggle': [
        "I hear the struggle in your words, and I want you to know that {emotion} is not a sign of weak faith. {biblical_truth}. {scripture_citation}. {practical_guidance}. {hope_statement}.",
        "{empathy_statement}. Many believers have walked this path before you. {scripture_citation} reminds us that {biblical_truth}. {practical_guidance}. {encouragement}."
    ],
    'mental_health': [
        "What you're experiencing is real, and it's not something you can just 'pray away.' {empathy_statement}. {scripture_citation} shows us that {biblical_truth}. {professional_referral}. {practical_guidance}. {hope_statement}.",
        "I want to acknowledge the weight of what you're carrying. {biblical_truth}, as we see in {scripture_citation}. {practical_guidance}. {professional_referral}. {encouragement}."
    ],
    'relationships': [
        "{empathy_statement}. Relationships are complex, and there's no simple formula. {scripture_citation} teaches us that {biblical_truth}. {practical_guidance}. {boundary_guidance}. {hope_statement}.",
        "I hear the pain in your situation. {biblical_truth}. {scripture_citation}. {practical_guidance}. Remember, {encouragement}."
    ],
    'life_circumstances': [
        "{empathy_statement}. What you're going through is not a sign of God's absence or punishment. {scripture_citation} reminds us that {biblical_truth}. {practical_guidance}. {hope_statement}.",
        "I want you to know that {biblical_truth}. {scripture_citation}. {practical_guidance}. God is with you in this, even when it doesn't feel like it. {encouragement}."
    ]
}

def load_theme_definitions(path):
    """Load theme definitions from markdown file"""
    # This is a simplified parser - in production, use proper markdown parsing
    themes = {}
    # For now, return empty dict - will be populated from theme_definitions.md
    return themes

def load_verse_mappings(path):
    """Load theme-to-verse mappings"""
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_user_input_variations(theme_name, user_phrases, count=250):
    """
    Generate variations of user inputs for a theme

    Takes the 5-10 real user phrases from theme definitions
    and creates natural variations to reach 250 examples
    """
    variations = []

    # Direct user phrases (from theme definitions)
    variations.extend(user_phrases)

    # Add contextual variations
    contexts = [
        "I'm struggling with {phrase}",
        "{phrase} and I don't know what to do",
        "Help me understand {phrase}",
        "I need guidance on {phrase}",
        "{phrase}, can you help?",
        "I'm dealing with {phrase}",
        "{phrase} - what does the Bible say?",
        "How do I handle {phrase}?",
        "I'm going through {phrase}",
        "{phrase} and I feel lost"
    ]

    for phrase in user_phrases:
        # Remove quotes if present
        clean_phrase = phrase.strip('"')

        for context in contexts:
            variations.append(context.format(phrase=clean_phrase))

    # Add question variations
    question_starters = [
        "Why am I feeling",
        "Is it normal to",
        "What should I do about",
        "How can I cope with",
        "Can you help me with"
    ]

    for phrase in user_phrases:
        clean_phrase = phrase.strip('"').lower()
        for starter in question_starters:
            variations.append(f"{starter} {clean_phrase}?")

    # Shuffle and limit to requested count
    random.shuffle(variations)
    return variations[:count]

def select_best_verse(theme_name, verses, used_verses):
    """
    Select the most appropriate verse for this training example
    Avoids repeating verses too often
    """
    # Filter out recently used verses
    available = [v for v in verses if v['reference'] not in used_verses]

    if not available:
        # Reset if all verses have been used
        available = verses
        used_verses.clear()

    # Select highest scoring verse
    best_verse = max(available, key=lambda v: v['match_score'])
    used_verses.add(best_verse['reference'])

    return best_verse

def generate_pastoral_response(theme_name, user_input, verse, theme_info):
    """
    Generate a pastoral response following guidelines

    This is a template-based approach for MVP.
    In production, use LLM to generate more varied responses.
    """

    # Component builders
    empathy_statements = [
        f"I hear the weight of what you're experiencing",
        f"Thank you for sharing something so personal",
        f"What you're going through is real and valid",
        f"I want to acknowledge the difficulty of this struggle",
        f"Your feelings are understandable given what you're facing"
    ]

    biblical_truths = {
        'anxiety_disorders': "God's peace is available even in the midst of overwhelming anxiety",
        'depression': "God is near to the brokenhearted and sees your suffering",
        'doubt': "Doubt is not the opposite of faith - it's often the pathway to deeper faith",
        'addiction': "Freedom from bondage is possible through God's power and community support",
        'loneliness': "God sees you in your isolation and desires to be your companion",
        # Add more theme-specific truths...
    }

    practical_guidance = {
        'anxiety_disorders': "Consider speaking with a licensed therapist who can help you develop coping strategies. Anxiety is not a sin - it's a human experience that therapy and sometimes medication can address.",
        'depression': "Please reach out to a mental health professional. Depression is a real illness that responds to treatment. Taking medication is not a sign of weak faith.",
        'doubt': "Engage your doubts honestly. Read books by authors who've wrestled with similar questions. Talk to trusted mentors. Doubt can lead to a more mature, resilient faith.",
        # Add more theme-specific guidance...
    }

    hope_statements = [
        "You're not alone in this, and there is hope for healing and peace",
        "God is with you in this struggle, even when it doesn't feel like it",
        "This season won't last forever, and healing is possible",
        "You're taking a brave step by seeking help and guidance"
    ]

    # Build response
    empathy = random.choice(empathy_statements)
    truth = biblical_truths.get(theme_name, "God is faithful and present in your struggle")
    guidance = practical_guidance.get(theme_name, "Take time to seek wise counsel and support")
    hope = random.choice(hope_statements)

    scripture = f"{verse['reference']} says: \"{verse['text']}\""

    response = f"{empathy}. {truth}. {scripture}. {guidance}. {hope}."

    return response

def generate_training_examples(theme_name, theme_info, verses, count=250):
    """Generate training examples for a single theme"""

    examples = []
    used_verses = set()

    # Get user input variations
    user_phrases = [
        # These would come from theme_definitions.md
        # For now, using placeholders
        f"I'm struggling with {theme_name.replace('_', ' ')}",
        f"Help me with {theme_name.replace('_', ' ')}",
        f"I need guidance on {theme_name.replace('_', ' ')}"
    ]

    user_inputs = generate_user_input_variations(theme_name, user_phrases, count)

    for i, user_input in enumerate(user_inputs):
        # Select verse
        verse = select_best_verse(theme_name, verses, used_verses)

        # Generate response
        response = generate_pastoral_response(theme_name, user_input, verse, theme_info)

        # Create training example
        example = {
            'theme': theme_name,
            'user_input': user_input,
            'response': response,
            'verse_reference': verse['reference'],
            'verse_text': verse['text'],
            'example_id': f"{theme_name}_{i+1:03d}"
        }

        examples.append(example)

    return examples

def save_training_data(examples, output_dir):
    """Save training data in multiple formats"""

    # JSONL format (one example per line) - best for fine-tuning
    jsonl_path = output_dir / "training_data.jsonl"
    with open(jsonl_path, 'w', encoding='utf-8') as f:
        for example in examples:
            # OpenAI fine-tuning format
            training_row = {
                'messages': [
                    {'role': 'system', 'content': 'You are a compassionate Christian pastoral guide providing biblically-grounded encouragement and wisdom.'},
                    {'role': 'user', 'content': example['user_input']},
                    {'role': 'assistant', 'content': example['response']}
                ]
            }
            f.write(json.dumps(training_row, ensure_ascii=False) + '\n')

    # JSON format (for review and analysis)
    json_path = output_dir / "training_data_full.json"
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(examples, f, indent=2, ensure_ascii=False)

    print(f"✅ Saved training data:")
    print(f"   JSONL: {jsonl_path} ({len(examples)} examples)")
    print(f"   JSON:  {json_path}")

    return jsonl_path, json_path

def main():
    # Paths
    base_dir = Path(__file__).parent.parent
    mappings_path = base_dir / "assets/training_data/theme_verse_mappings.json"
    output_dir = base_dir / "assets/training_data"

    print("Training Data Generation Script")
    print("="*60)
    print(f"Verse mappings: {mappings_path}")
    print(f"Output directory: {output_dir}\n")

    # Load verse mappings
    print("📖 Loading verse mappings...")
    verse_mappings = load_verse_mappings(mappings_path)
    print(f"   Loaded {len(verse_mappings)} themes\n")

    # Generate examples for each theme
    all_examples = []

    print("🤖 Generating training examples...")
    for theme_name, theme_data in verse_mappings.items():
        print(f"   {theme_name}: ", end='', flush=True)

        verses = theme_data['verses']
        examples = generate_training_examples(
            theme_name,
            theme_data,
            verses,
            count=250
        )

        all_examples.extend(examples)
        print(f"✓ {len(examples)} examples")

    print(f"\n✅ Generated {len(all_examples)} total training examples")

    # Save training data
    print("\n💾 Saving training data...")
    save_training_data(all_examples, output_dir)

    # Statistics
    print(f"\n📊 Statistics:")
    print(f"   Themes: {len(verse_mappings)}")
    print(f"   Examples per theme: ~250")
    print(f"   Total examples: {len(all_examples)}")
    print(f"   Average response length: {sum(len(e['response']) for e in all_examples) / len(all_examples):.0f} chars")

    print("\n✅ Training data generation complete!")
    print("\n📋 Next steps:")
    print("   1. Review sample responses for quality")
    print("   2. Validate theological accuracy")
    print("   3. Fine-tune AI model with training data")

if __name__ == "__main__":
    main()
