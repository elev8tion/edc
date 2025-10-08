import sqlite3
import json
import re

DB_PATH = "/Users/kcdacre8tor/ everyday-christian/assets/bible.db"
OUTPUT_PATH = "/Users/kcdacre8tor/ everyday-christian/assets/training_data/themes/fear.jsonl"

def clean_verse_text(text):
    """Remove strong tags and extra whitespace from verse text."""
    # Remove strong tags
    text = re.sub(r'\|strong="[^"]*"', '', text)
    # Clean up extra spaces
    text = re.sub(r'\s+', ' ', text)
    # Remove leading/trailing spaces
    text = text.strip()
    return text

def get_fear_verses(limit=30):
    """Get verses about fear from the database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    query = """
    SELECT DISTINCT reference, text 
    FROM verses 
    WHERE translation = 'WEB' 
    AND (
        text LIKE '%fear not%' OR 
        text LIKE '%don''t be afraid%' OR
        text LIKE '%do not fear%' OR
        text LIKE '%fear%God%' OR
        text LIKE '%afraid%' OR
        text LIKE '%terror%' OR
        text LIKE '%dread%'
    )
    AND length(text) < 500
    ORDER BY RANDOM()
    LIMIT ?
    """
    
    cursor.execute(query, (limit,))
    verses = cursor.fetchall()
    conn.close()
    
    # Clean verses
    cleaned_verses = []
    for ref, text in verses:
        cleaned_text = clean_verse_text(text)
        if cleaned_text and len(cleaned_text) > 20:
            cleaned_verses.append((ref, cleaned_text))
    
    return cleaned_verses[:25]

# Indirect phrases about fear
indirect_phrases = [
    "I'm terrified of what might happen",
    "I can't shake this dread",
    "I'm paralyzed by fear right now",
    "Everything feels so scary and uncertain",
    "I'm afraid I'm going to fail",
    "I keep having panic attacks about the future",
    "I'm scared of losing everything",
    "This anxiety is consuming me",
    "I'm too afraid to even try",
    "I feel like something terrible is about to happen"
]

# Pastoral responses using the pattern: challenge→truth→scripture→action
pastoral_responses = [
    {
        "input": "I'm terrified of what might happen",
        "response": "You're staring into a future you can't control, and it's eating you alive. Here's the truth: God hasn't given you a spirit of fear. He's given you power, love, and self-control. When you're terrified, you're believing fear's lies instead of God's promises. Read 2 Timothy 1:7 today. Then take one small step forward in faith. Just one.",
        "scripture": "2 Timothy 1:7"
    },
    {
        "input": "I can't shake this dread",
        "response": "That dread is a bully, and you've been letting it push you around. But listen: God is your refuge and strength, always ready to help in times of trouble. Always. Not sometimes. When dread shows up, you don't have to fight it alone. Psalm 46:1 - memorize it. And when the dread hits, speak it out loud. Truth defeats the lie.",
        "scripture": "Psalm 46:1"
    },
    {
        "input": "I'm paralyzed by fear right now",
        "response": "Paralysis means you're frozen between what you fear and what you know. Break it. The Lord is with you wherever you go - that's not a suggestion, it's a fact. Joshua 1:9 tells you to be strong and courageous because God is with you. Stop waiting to feel brave. Act in obedience despite the fear. Movement kills paralysis.",
        "scripture": "Joshua 1:9"
    },
    {
        "input": "Everything feels so scary and uncertain",
        "response": "Uncertainty isn't the enemy - it's the environment where faith grows. You want guarantees, but God offers something better: His presence. When anxiety overwhelms you, cast it on Him because He cares for you. Not might care. Does care. Read 1 Peter 5:7. Then write down three things you're certain about in God, not in your circumstances.",
        "scripture": "1 Peter 5:7"
    },
    {
        "input": "I'm afraid I'm going to fail",
        "response": "You're afraid of failure, but you're already failing by letting fear run the show. God hasn't promised you success - He's promised you His presence. Even when you walk through the valley of death's shadow, He's there. Psalm 23:4. Your job isn't to avoid failure. It's to walk with God through whatever comes. Start walking.",
        "scripture": "Psalm 23:4"
    },
    {
        "input": "I keep having panic attacks about the future",
        "response": "Your panic attacks are real, and they're lying to you about who's in control. Jesus asked one simple question: Can worry add a single hour to your life? It can't. But it can steal today's peace. Matthew 6:27. Get help if you need it - therapy, counseling, medical support. But also practice this: when panic rises, name three things you can see, touch, hear. Bring yourself back to now. God meets you here, not in tomorrow.",
        "scripture": "Matthew 6:27"
    },
    {
        "input": "I'm scared of losing everything",
        "response": "You're gripping so tight because you think control equals safety. It doesn't. Even if you lose everything else, you cannot lose God. Nothing can separate you from His love. Romans 8:38-39 isn't poetry - it's a guarantee. Read it until you believe it. Then open your hands. What you're clutching might be the very thing God wants to replace with something better.",
        "scripture": "Romans 8:38-39"
    },
    {
        "input": "This anxiety is consuming me",
        "response": "Anxiety is loud, but it's not the boss. You've been feeding it by dwelling on worst-case scenarios. Starve it instead. Philippians 4:6-7 gives you the pattern: pray about everything, worry about nothing. God's peace will guard your heart and mind. Start right now. Pray about one thing you're anxious about. Be specific. Then leave it with God and move on to the next thing you need to do today.",
        "scripture": "Philippians 4:6-7"
    },
    {
        "input": "I'm too afraid to even try",
        "response": "Your fear is reasonable, but it's not trustworthy. God didn't call you to safety - He called you to faithfulness. When you're afraid, He says: 'Don't be afraid, for I am with you.' Isaiah 41:10. With you. Not watching from a distance. Right there in the risk with you. What's one small thing you can try today? Not everything. Just one thing. Do that afraid.",
        "scripture": "Isaiah 41:10"
    },
    {
        "input": "I feel like something terrible is about to happen",
        "response": "That feeling is dread, and it's a liar. It tells you disaster is certain, but it's not. What is certain? God works all things together for good for those who love Him. Romans 8:28. All things. Even the hard things. Even the unexpected things. You don't know what tomorrow holds, but you know who holds tomorrow. Write Romans 8:28 on a card. Read it every time dread whispers its lies.",
        "scripture": "Romans 8:28"
    }
]

def generate_training_data():
    """Generate complete training dataset for FEAR theme."""
    training_data = []
    
    # Get 25 clean verses
    verses = get_fear_verses(30)
    print(f"Retrieved {len(verses)} clean verses about fear")
    
    # Add verse-based training examples
    for ref, text in verses:
        training_data.append({
            "input": text,
            "response": f"This is God's truth speaking directly to fear. {ref} reminds us that fear doesn't have the final word - God does. When fear whispers lies, Scripture shouts truth.",
            "theme": "fear",
            "scripture": ref,
            "source": "direct_verse"
        })
    
    # Add pastoral responses to indirect phrases
    for response_data in pastoral_responses:
        training_data.append({
            "input": response_data["input"],
            "response": response_data["response"],
            "theme": "fear",
            "scripture": response_data["scripture"],
            "source": "pastoral_response"
        })
    
    # Write to JSONL file
    with open(OUTPUT_PATH, 'w') as f:
        for item in training_data:
            f.write(json.dumps(item) + '\n')
    
    print(f"\nTraining data generated: {OUTPUT_PATH}")
    print(f"Total examples: {len(training_data)}")
    print(f"  - Direct verses: {len(verses)}")
    print(f"  - Pastoral responses: {len(pastoral_responses)}")
    
    return len(training_data)

if __name__ == "__main__":
    count = generate_training_data()
    print(f"\n✓ Generated {count} training examples for FEAR theme")
