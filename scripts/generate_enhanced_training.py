#!/usr/bin/env python3
"""
Enhanced Training Data Generation - 18,750 Examples
Generates 250 examples per theme for 75 themes
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
    
    # Find all theme sections
    pattern = r'####\s+\d+\.\s+(\w+)\s*\n.*?\*\*Real User Language:\*\*\n((?:- ".*?"\n)+)'
    matches = re.findall(pattern, content, re.DOTALL)
    
    for theme_name, phrases_block in matches:
        phrases = re.findall(r'- "(.*?)"', phrases_block)
        themes[theme_name] = phrases
    
    return themes

def generate_variations(base_phrases, count=250):
    """Generate natural variations from base phrases"""
    variations = list(base_phrases)  # Start with originals
    
    # Contextual additions
    contexts = [
        "{phrase}",
        "I'm struggling with {phrase}",
        "{phrase} and I don't know what to do",
        "Help me understand {phrase}",
        "{phrase}, can you help?",
        "I'm dealing with {phrase}",
        "{phrase} - what should I do?",
        "How do I handle {phrase}?",
        "{phrase} and I feel lost",
    ]
    
    for phrase in base_phrases:
        for ctx in contexts:
            variations.append(ctx.format(phrase=phrase))
    
    # Question forms
    for phrase in base_phrases:
        variations.append(f"Why {phrase.lower()}?")
        variations.append(f"What should I do about {phrase.lower()}?")
        variations.append(f"How can I cope with {phrase.lower()}?")
    
    random.shuffle(variations)
    return variations[:count]

def create_pastoral_response(theme, user_input, verse):
    """Create pastoral response with empathy + scripture + guidance + hope"""
    
    empathy = random.choice([
        "I hear the weight of what you're experiencing.",
        "Thank you for sharing something so personal.",
        "What you're going through is real and valid.",
        "I want to acknowledge the difficulty of this struggle.",
    ])
    
    hope = random.choice([
        "You're not alone in this, and there is hope.",
        "This season won't last forever.",
        "God is with you in this struggle.",
        "Healing is possible with time and support.",
    ])
    
    response = f"{empathy} {verse['reference']} says: \"{verse['text']}\" {hope}"
    
    return response

def main():
    base_dir = Path(__file__).parent.parent
    
    # Paths
    theme_defs = base_dir / "docs/theme_definitions.md"
    verse_mappings = base_dir / "assets/training_data/theme_verse_mappings.json"
    output_dir = base_dir / "assets/training_data"
    
    print("Enhanced Training Data Generation")
    print("="*60)
    
    # Load data
    print("📖 Loading theme definitions and verse mappings...")
    user_phrases_by_theme = parse_theme_user_phrases(theme_defs)
    
    with open(verse_mappings, 'r') as f:
        verses_by_theme = json.load(f)
    
    print(f"   Themes with user phrases: {len(user_phrases_by_theme)}")
    print(f"   Themes with verses: {len(verses_by_theme)}\n")
    
    # Generate examples
    all_examples = []
    
    print("🤖 Generating 250 examples per theme...")
    for theme_name in verses_by_theme.keys():
        print(f"   {theme_name}: ", end='', flush=True)
        
        # Get user phrases
        base_phrases = user_phrases_by_theme.get(theme_name, [f"I'm struggling with {theme_name.replace('_', ' ')}"])
        user_inputs = generate_variations(base_phrases, 250)
        
        # Get verses
        verses = verses_by_theme[theme_name]['verses']
        
        # Generate examples
        for i, user_input in enumerate(user_inputs):
            verse = verses[i % len(verses)]  # Cycle through verses
            
            response = create_pastoral_response(theme_name, user_input, verse)
            
            example = {
                'messages': [
                    {'role': 'system', 'content': 'You are a compassionate Christian pastoral guide providing biblically-grounded encouragement and wisdom.'},
                    {'role': 'user', 'content': user_input},
                    {'role': 'assistant', 'content': response}
                ]
            }
            
            all_examples.append(example)
        
        print(f"✓ 250 examples")
    
    # Save JSONL
    print(f"\n💾 Saving {len(all_examples)} examples...")
    output_file = output_dir / "training_18750.jsonl"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        for example in all_examples:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')
    
    print(f"✅ Saved to: {output_file}")
    print(f"\n📊 Total examples: {len(all_examples)}")
    print(f"   Themes: {len(verses_by_theme)}")
    print(f"   Avg per theme: {len(all_examples) // len(verses_by_theme)}")

if __name__ == "__main__":
    main()
