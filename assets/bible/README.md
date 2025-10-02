# Bible Content Integration

## Public Domain Bible Sources (Commercial Use Allowed)

### English Bibles
- **KJV (King James Version)** - Primary English translation
  - Source: [Crosswire](https://www.crosswire.org/sword/modules/ModInfo.jsp?modName=KJV) or [Bible Databases](https://github.com/scrollmapper/bible_databases)
  - License: Public domain
  - Year: 1611

- **WEB (World English Bible)** - Modern English translation
  - Source: [Crosswire](https://www.crosswire.org/sword/modules/ModInfo.jsp?modName=WEB) or [eBible.org](https://ebible.org/web/)
  - License: Public domain
  - Year: Updated regularly (modern language)

### Spanish Bibles
- **RVR1909 (Reina-Valera 1909)** - Spanish translation
  - Source: [Crosswire](https://www.crosswire.org/sword/modules/ModInfo.jsp?modName=RVR1909)
  - License: Public domain
  - Year: 1909

## Integration Plan

### Step 1: Download Bible Data
Download JSON/SQLite formats from:
- https://github.com/scrollmapper/bible_databases
- https://github.com/thiagobodruk/bible (API + JSON)
- https://api.scripture.api.bible (Free tier)

### Step 2: Convert to App Format
Structure:
```json
{
  "version": "ESV",
  "books": [
    {
      "name": "Genesis",
      "abbr": "gen",
      "chapters": [
        {
          "number": 1,
          "verses": [
            { "number": 1, "text": "In the beginning..." }
          ]
        }
      ]
    }
  ]
}
```

### Step 3: Load into SQLite
- Create local Bible database
- Index for fast search
- Support verse queries, keyword search

## Next Steps
1. Download KJV, WEB (English) and RVR1909 (Spanish) JSON files
2. Create BibleLoader service
3. Import on first app launch
4. Enable offline verse search
