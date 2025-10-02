# Bible Content Integration

## Free Bible Sources

### English Bibles
- **ESV (English Standard Version)** - Primary English translation
  - Source: [Crosswire](https://www.crosswire.org/sword/modules/ModInfo.jsp?modName=ESV2011)
  - License: Free for non-commercial use

### Spanish Bibles
- **RVR1960 (Reina-Valera 1960)** - Primary Spanish translation
  - Source: [Crosswire](https://www.crosswire.org/sword/modules/ModInfo.jsp?modName=RVR1960)
  - License: Public domain

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
1. Download ESV and RVR1960 JSON files
2. Create BibleLoader service
3. Import on first app launch
4. Enable offline verse search
