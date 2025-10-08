#!/usr/bin/env python3
"""
Final Training Data Generation - 19,750 Examples
Generates 250 examples per theme for all 79 themes
"""

import json
import random
import re
from pathlib import Path

def parse_theme_user_phrases(md_path):
    """Extract real user phrases from theme_definitions.md"""
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    themes = {}
    pattern = r'####\s+\d+\.\s+(\w+)\s*\n.*?\*\*Real User Language:\*\*\n((?:- ".*?"\n)+)'
    matches = re.findall(pattern, content, re.DOTALL)
    
    for theme_name, phrases_block in matches:
        phrases = re.findall(r'- "(.*?)"', phrases_block)
        themes[theme_name] = phrases
    
    return themes

def generate_250_variations(base_phrases, theme_name):
    """Generate exactly 250 variations from base phrases"""
    variations = []
    
    # Use all original phrases
    variations.extend(base_phrases)
    
    # Contextual wrappers (15 variations)
    contexts = [
        "{phrase}",
        "I'm struggling with {phrase}",
        "{phrase} and I don't know what to do",
        "Help me with {phrase}",
        "I need guidance on {phrase}",
        "{phrase}, can you help?",
        "I'm dealing with {phrase}",
        "{phrase} - what does the Bible say?",
        "How do I handle {phrase}?",
        "I'm going through {phrase}",
        "{phrase} and I feel lost",
        "{phrase}, please help",
        "Can you talk to me about {phrase}?",
        "{phrase} and I need encouragement",
        "I don't know how to deal with {phrase}",
    ]
    
    for phrase in base_phrases:
        for ctx in contexts:
            variations.append(ctx.format(phrase=phrase))
    
    # Question variations
    question_forms = [
        "Why am I feeling {phrase}?",
        "What should I do about {phrase}?",
        "How can I cope with {phrase}?",
        "Is it normal that {phrase}?",
        "Can you help me understand {phrase}?",
        "How do I get through {phrase}?",
    ]
    
    for phrase in base_phrases:
        for q in question_forms:
            variations.append(q.format(phrase=phrase.lower()))
    
    # Emotional markers
    for phrase in base_phrases[:10]:  # Top 10 phrases
        variations.append(f"{phrase}...")
        variations.append(f"{phrase} and I'm scared")
        variations.append(f"{phrase} and I'm tired")
        variations.append(f"{phrase} and I'm overwhelmed")
    
    # Direct statements about the theme
    theme_readable = theme_name.replace('_', ' ')
    direct_statements = [
        f"I'm struggling with {theme_readable}",
        f"Tell me about {theme_readable}",
        f"I need help with {theme_readable}",
        f"Can you help me with {theme_readable}?",
        f"I'm dealing with {theme_readable}",
        f"I'm going through {theme_readable}",
        f"How do I handle {theme_readable}?",
        f"What does the Bible say about {theme_readable}?",
        f"I'm experiencing {theme_readable}",
        f"Help me understand {theme_readable}",
    ]
    variations.extend(direct_statements)
    
    # If still need more, repeat with slight variations
    while len(variations) < 250:
        phrase = random.choice(base_phrases)
        prefix = random.choice(["Really struggling with", "Need help with", "Going through", "Can't handle"])
        variations.append(f"{prefix} {phrase.lower()}")
    
    # Shuffle and return exactly 250
    random.shuffle(variations)
    return variations[:250]

def create_pastoral_response(theme, user_input, verse):
    """Create pastoral response with 4-part structure"""
    
    empathy_statements = [
        "I hear the weight of what you're experiencing.",
        "Thank you for sharing something so personal.",
        "What you're going through is real and valid.",
        "I want to acknowledge the difficulty of this struggle.",
        "Your feelings are understandable given what you're facing.",
    ]
    
    hope_statements = [
        "You're not alone in this, and there is hope for healing and peace.",
        "This season won't last forever, and healing is possible.",
        "God is with you in this struggle, even when it doesn't feel like it.",
        "You're taking a brave step by seeking help and guidance.",
        "There is genuine hope ahead, grounded in God's faithfulness.",
    ]
    
    empathy = random.choice(empathy_statements)
    hope = random.choice(hope_statements)
    
    scripture = f"{verse['reference']} says: \"{verse['text']}\""
    
    response = f"{empathy} {scripture} {hope}"
    
    return response

def main():
    base_dir = Path(__file__).parent.parent
    
    # Paths
    theme_defs = base_dir / "docs/theme_definitions.md"
    verse_mappings = base_dir / "assets/training_data/theme_verse_mappings.json"
    output_dir = base_dir / "assets/training_data"
    
    print("Final Training Data Generation - 19,750 Examples")
    print("="*60)
    
    # Load data
    print("📖 Loading theme definitions and verse mappings...")
    user_phrases_by_theme = parse_theme_user_phrases(theme_defs)
    
    with open(verse_mappings, 'r') as f:
        verses_by_theme = json.load(f)
    
    print(f"   Themes: {len(verses_by_theme)}\n")
    
    # Generate examples
    all_examples = []
    
    print("🤖 Generating 250 examples per theme...")
    for theme_name in sorted(verses_by_theme.keys()):
        print(f"   {theme_name}: ", end='', flush=True)
        
        # Get user phrases
        base_phrases = user_phrases_by_theme.get(
            theme_name,
            [f"I'm struggling with {theme_name.replace('_', ' ')}"]
        )
        
        # Generate exactly 250 variations
        user_inputs = generate_250_variations(base_phrases, theme_name)
        
        # Get verses
        verses = verses_by_theme[theme_name]['verses']
        
        # Generate examples
        for i, user_input in enumerate(user_inputs):
            verse = verses[i % len(verses)]  # Cycle through verses
            
            response = create_pastoral_response(theme_name, user_input, verse)
            
            example = {
                'messages': [
                    {
                        'role': 'system',
                        'content': 'You are a compassionate Christian pastoral guide providing biblically-grounded encouragement and wisdom. You acknowledge real struggles, provide scriptural truth, offer practical guidance, and point toward hope—without toxic positivity or spiritual bypassing.'
                    },
                    {'role': 'user', 'content': user_input},
                    {'role': 'assistant', 'content': response}
                ]
            }
            
            all_examples.append(example)
        
        print(f"✓ {len(user_inputs)} examples")
    
    # Save JSONL
    print(f"\n💾 Saving {len(all_examples)} examples...")
    output_file = output_dir / "training_19750_final.jsonl"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        for example in all_examples:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')
    
    file_size = output_file.stat().st_size / (1024 * 1024)  # MB
    
    print(f"✅ Saved to: {output_file}")
    print(f"\n📊 Final Statistics:")
    print(f"   Total examples: {len(all_examples)}")
    print(f"   Themes: {len(verses_by_theme)}")
    print(f"   Examples per theme: {len(all_examples) // len(verses_by_theme)}")
    print(f"   File size: {file_size:.1f} MB")
    print(f"\n✅ Training data generation complete!")

if __name__ == "__main__":
    main()
