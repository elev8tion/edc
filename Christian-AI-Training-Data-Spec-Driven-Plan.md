# 📚 Christian AI Counselor Training Data - Spec-Driven Development Plan

**Version:** 1.0
**Created:** October 8, 2025
**Project:** LSTM-based Christian AI Pastoral Counselor

---

## 📋 SPECIFY.MD - Project Specification

### What We're Building

A production-ready training dataset for an LSTM-based Christian AI counselor that provides:
- Scripture-based responses to user struggles
- Pastoral guidance with theological soundness
- Multi-turn conversation capabilities
- Coverage across 40 life themes
- Empathetic, non-preachy tone

### Why This Matters

**Current State (Problems):**
- ⚠️ Only 1,316 examples (need 10K-100K for robust LSTM)
- ⚠️ Uneven theme coverage (only 7 of 40 themes have data)
- ⚠️ Single-turn only (no conversation context)
- ⚠️ Short inputs (5-10 words, doesn't handle paragraphs)
- ⚠️ Repetitive templates (lacks response diversity)

**Desired State (Solutions):**
- ✅ 10,000+ training examples across all 40 themes
- ✅ Multi-turn conversation threads with context
- ✅ Variable input lengths (5-500 words)
- ✅ Diverse pastoral voices and response patterns
- ✅ Conversation flow metadata for context-aware responses

### Success Criteria

1. **Dataset Size:** Minimum 10,000 total examples (7.6x current size)
2. **Theme Coverage:** All 40 themes from taxonomy represented
3. **Conversation Depth:** 30% of examples include 2-5 turn conversations
4. **Input Diversity:** Input length distribution: 40% short (5-20 words), 40% medium (20-100 words), 20% long (100-500 words)
5. **Response Quality:** Maintain 70% scripture / 30% pastoral voice ratio
6. **Validation:** 95%+ accuracy on theme classification test set

### Non-Goals (Out of Scope)

- ❌ Theological debate or apologetics training
- ❌ Medical/clinical diagnosis
- ❌ Real-time counseling (this is training data, not the app)
- ❌ Multi-language support (English only for v1)
- ❌ Audio/voice data (text only)

---

## 🛠 PLAN.MD - Technical Implementation Plan

### Tech Stack

**Data Generation:**
- Python 3.10+
- Libraries: `json`, `jsonlines`, `random`, `datetime`
- Scripture API: Bible API or local KJV/ESV JSON corpus
- LLM for augmentation: Claude API (for pastoral voice generation)

**Data Storage:**
- Format: JSONL (JSON Lines) for streaming efficiency
- Structure: Separate files per theme + consolidated master file
- Version control: Git with semantic versioning
- Backup: S3 or Google Cloud Storage

**Data Validation:**
- Schema validation: `jsonschema` library
- Quality checks: Custom Python scripts
- Duplicate detection: Fuzzy matching with `fuzzywuzzy`
- Theme classification test: Sklearn for accuracy metrics

**LSTM Training (Future Phase):**
- Framework: TensorFlow/Keras or PyTorch
- Character-level LSTM for response generation
- Attention mechanism for long inputs
- Embedding layer for scripture references

### Architecture

```
christian-ai-training-data/
├── source_data/
│   ├── processed/
│   │   ├── response_generation.jsonl (1,120 examples)
│   │   └── theme_classification.jsonl (56 examples)
│   ├── themes/
│   │   ├── depression.jsonl (25 examples)
│   │   ├── fear.jsonl (35 examples)
│   │   ├── overwhelm.jsonl (35 examples)
│   │   └── rejection.jsonl (45 examples)
│   └── theme_taxonomy.json (40 themes)
│
├── augmented_data/
│   ├── v2.0_expanded/
│   │   ├── anxiety.jsonl (target: 300 examples)
│   │   ├── grief.jsonl (target: 300 examples)
│   │   ├── [... 38 more theme files]
│   │   └── multi_turn_conversations.jsonl (target: 2,000 examples)
│   └── master_consolidated_v3.0.jsonl (10,000+ examples)
│
├── validation/
│   ├── test_set_classification.jsonl (500 examples, 20% holdout)
│   ├── test_set_generation.jsonl (500 examples, 20% holdout)
│   └── validation_results.json
│
├── scripts/
│   ├── 01_analyze_current_data.py
│   ├── 02_generate_theme_variations.py
│   ├── 03_create_multi_turn_conversations.py
│   ├── 04_augment_with_llm.py
│   ├── 05_validate_schema.py
│   ├── 06_detect_duplicates.py
│   ├── 07_balance_themes.py
│   ├── 08_split_train_test.py
│   └── 09_generate_master_consolidated.py
│
├── docs/
│   ├── data_dictionary.md
│   ├── pastoral_voice_guidelines.md
│   └── scripture_selection_criteria.md
│
└── README.md
```

### Data Schema

#### Single-Turn Response (Current Format)
```json
{
  "input": "I can't sleep, my mind keeps racing",
  "response": "Don't be terrified. Don't be afraid of them. (Deuteronomy 1:29)",
  "theme": "anxiety",
  "scripture": "Deuteronomy 1:29",
  "source": "bible",
  "response_type": "verse_direct",
  "confidence": 0.92,
  "created_at": "2025-10-08T12:00:00Z",
  "version": "2.0"
}
```

#### Multi-Turn Conversation (New Format)
```json
{
  "conversation_id": "conv_20251008_001",
  "theme": "anxiety",
  "turns": [
    {
      "turn": 1,
      "user_input": "I can't sleep, my mind keeps racing",
      "assistant_response": "That racing mind must be exhausting. What's weighing on you most right now?",
      "response_type": "empathetic_question",
      "scripture": null
    },
    {
      "turn": 2,
      "user_input": "Work deadline tomorrow and I feel unprepared",
      "assistant_response": "The pressure feels real, but remember: 'Don't be anxious about anything, but in everything by prayer and petition, with thanksgiving, present your requests to God.' (Philippians 4:6). You've done what you can - now release it.",
      "response_type": "pastoral_with_verse",
      "scripture": "Philippians 4:6"
    },
    {
      "turn": 3,
      "user_input": "How do I actually 'release' it though?",
      "assistant_response": "Practically? Write down 3 things you're grateful for right now. Then pray - even if it's just 'God, I need help.' Sleep is a gift from Him, not something you earn. Trust that tomorrow's strength will come tomorrow.",
      "response_type": "practical_guidance",
      "scripture": null
    }
  ],
  "total_turns": 3,
  "resolution_achieved": true,
  "created_at": "2025-10-08T12:00:00Z",
  "version": "3.0"
}
```

### Implementation Phases

**Phase 1: Analysis & Foundation (Week 1)**
- Audit existing 1,316 examples
- Validate schema consistency
- Identify quality issues
- Create baseline metrics

**Phase 2: Theme Expansion (Week 2-3)**
- Generate 200-300 examples per theme (40 themes × 250 avg = 10,000)
- Use pattern variation + LLM augmentation
- Maintain 70/30 scripture/pastoral ratio
- Cover all 40 themes from taxonomy

**Phase 3: Multi-Turn Conversations (Week 4)**
- Create 2,000 conversation threads (2-5 turns each)
- 5 conversation types: empathetic, scriptural, practical, challenging, affirming
- Train context-awareness for follow-ups

**Phase 4: Validation & Quality Assurance (Week 5)**
- Schema validation across all files
- Duplicate detection and removal
- Theme classification accuracy test
- Human review of 500 random samples

**Phase 5: Consolidation & Documentation (Week 6)**
- Generate master consolidated file (v3.0)
- Create data dictionary
- Write pastoral voice guidelines
- Package for LSTM training

---

## ✅ TASKS.MD - Execution Checklist

### Task Categories

#### Category A: Setup & Analysis (Sequential, No Subagents)
#### Category B: Data Generation (Parallel, Subagent-Friendly)
#### Category C: Validation & QA (Sequential, No Subagents)
#### Category D: Documentation (Parallel, Subagent-Friendly)

---

### CATEGORY A: SETUP & ANALYSIS (Days 1-2)

**🎯 Goal:** Establish baseline, create infrastructure, validate current data

#### Task A1: Project Structure Setup
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 30 minutes

**Steps:**
1. Create directory structure as per architecture plan
2. Move existing files to `source_data/` directory
3. Initialize Git repository
4. Create `.gitignore` (exclude large files, API keys)
5. **Hook:** Update progress → "Project structure created ✓"

**Acceptance Criteria:**
- All directories exist
- Existing 7 files in correct locations
- Git initialized with initial commit

---

#### Task A2: Current Data Analysis
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 1 hour

**Steps:**
1. Run `scripts/01_analyze_current_data.py`:
   ```python
   # Count examples per file
   # Measure input length distribution
   # Detect duplicate entries
   # Identify missing metadata fields
   # Calculate theme coverage gaps
   ```
2. Generate analysis report: `validation/baseline_analysis.json`
3. **Hook:** Update progress → "Baseline metrics calculated ✓"

**Acceptance Criteria:**
- Exact count per file confirmed
- Input length histogram generated
- Theme gap analysis shows which 33 themes need data
- Report saved to validation folder

**Output Example:**
```json
{
  "total_examples": 1316,
  "by_file": {
    "response_generation.jsonl": 1120,
    "theme_classification.jsonl": 56,
    "depression.jsonl": 25,
    "fear.jsonl": 35,
    "overwhelm.jsonl": 35,
    "rejection.jsonl": 45
  },
  "themes_with_data": 7,
  "themes_without_data": 33,
  "avg_input_length": 8.4,
  "duplicates_found": 0
}
```

---

#### Task A3: Schema Validation Script
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 45 minutes

**Steps:**
1. Create `scripts/05_validate_schema.py`
2. Define JSON schemas for:
   - Single-turn response
   - Multi-turn conversation
   - Theme classification
3. Validate all existing files against schemas
4. **Hook:** Update progress → "Schema validation complete ✓"

**Acceptance Criteria:**
- All existing files pass validation
- Script reports any schema violations
- Validation results saved to `validation/schema_results.json`

---

### CATEGORY B: DATA GENERATION (Days 3-21)

**🎯 Goal:** Expand from 1,316 to 10,000+ examples across all 40 themes

**⚡ SUBAGENT ORCHESTRATION PLAN:**
- Deploy 5 parallel subagents (one per theme category from taxonomy)
- Each subagent generates 2,000 examples for their assigned themes
- Total: 5 × 2,000 = 10,000 examples

---

#### Task B1: Subagent 1 - Emotional Struggles (10 themes)
**Status:** ⬜ Not Started
**Owner:** Subagent 1
**Estimated Time:** 4 days
**Themes:** anxiety, grief, anger, jealousy, loneliness, depression, fear, overwhelm, insecurity, rejection

**Steps:**
1. Load `theme_taxonomy.json` for theme definitions
2. For each theme, generate 200 examples:
   - 140 bible-sourced (70%)
   - 60 pastoral-voiced (30%)
3. Input variation patterns:
   - Short (5-20 words): 80 examples
   - Medium (20-100 words): 80 examples
   - Long (100-500 words): 40 examples
4. Save to `augmented_data/v2.0_expanded/{theme}.jsonl`
5. **Hook:** After each theme → "Completed {theme} - 200 examples ✓"

**Script to Run:**
```python
python scripts/02_generate_theme_variations.py \
  --themes "anxiety,grief,anger,jealousy,loneliness,depression,fear,overwhelm,insecurity,rejection" \
  --examples-per-theme 200 \
  --bible-ratio 0.7 \
  --output-dir augmented_data/v2.0_expanded/
```

**Quality Checks (Built into script):**
- No duplicates within theme
- All required fields present
- Scripture references valid (Bible API lookup)
- Input length matches distribution targets

**Acceptance Criteria:**
- 2,000 total examples generated (10 themes × 200)
- 10 new JSONL files created
- 70/30 scripture/pastoral ratio maintained
- Schema validation passes

---

#### Task B2: Subagent 2 - Spiritual Growth (8 themes)
**Status:** ⬜ Not Started
**Owner:** Subagent 2
**Estimated Time:** 3 days
**Themes:** doubt, spiritual_dryness, prayer_struggles, backsliding, discernment, hearing_gods_voice, spiritual_warfare, bible_reading

**Steps:**
1. Load `theme_taxonomy.json` for theme definitions
2. For each theme, generate 250 examples (8 × 250 = 2,000):
   - 175 bible-sourced (70%)
   - 75 pastoral-voiced (30%)
3. Input variation patterns:
   - Short: 100 examples
   - Medium: 100 examples
   - Long: 50 examples
4. Save to `augmented_data/v2.0_expanded/{theme}.jsonl`
5. **Hook:** After each theme → "Completed {theme} - 250 examples ✓"

**Script to Run:**
```python
python scripts/02_generate_theme_variations.py \
  --themes "doubt,spiritual_dryness,prayer_struggles,backsliding,discernment,hearing_gods_voice,spiritual_warfare,bible_reading" \
  --examples-per-theme 250 \
  --bible-ratio 0.7 \
  --output-dir augmented_data/v2.0_expanded/
```

**Acceptance Criteria:**
- 2,000 total examples generated
- 8 new JSONL files created
- Schema validation passes

---

#### Task B3: Subagent 3 - Relationships (8 themes)
**Status:** ⬜ Not Started
**Owner:** Subagent 3
**Estimated Time:** 3 days
**Themes:** marriage_conflict, dating, singleness, parenting, family_dysfunction, toxic_relationships, breakup, divorce

**Steps:**
1. Load `theme_taxonomy.json` for theme definitions
2. For each theme, generate 250 examples (8 × 250 = 2,000)
3. **Special focus:** Pastoral voice more appropriate for relationships (50/50 ratio vs 70/30)
   - 125 bible-sourced (50%)
   - 125 pastoral-voiced (50%)
4. Input variation patterns:
   - Short: 100 examples
   - Medium: 100 examples
   - Long: 50 examples (relationship contexts often require more detail)
5. Save to `augmented_data/v2.0_expanded/{theme}.jsonl`
6. **Hook:** After each theme → "Completed {theme} - 250 examples ✓"

**Script to Run:**
```python
python scripts/02_generate_theme_variations.py \
  --themes "marriage_conflict,dating,singleness,parenting,family_dysfunction,toxic_relationships,breakup,divorce" \
  --examples-per-theme 250 \
  --bible-ratio 0.5 \
  --output-dir augmented_data/v2.0_expanded/
```

**Acceptance Criteria:**
- 2,000 total examples generated
- 8 new JSONL files created
- 50/50 scripture/pastoral ratio (appropriate for relationship context)

---

#### Task B4: Subagent 4 - Moral Struggles + Life Challenges (12 themes)
**Status:** ⬜ Not Started
**Owner:** Subagent 4
**Estimated Time:** 4 days
**Themes:** addiction, sexual_purity, lying, boundaries, forgiveness, bitterness, provision, unemployment, purpose, transition, illness, church_hurt

**Steps:**
1. Load `theme_taxonomy.json` for theme definitions
2. For each theme, generate 167 examples (12 × 167 ≈ 2,000):
   - 117 bible-sourced (70%)
   - 50 pastoral-voiced (30%)
3. **Special consideration:** Sensitive topics (addiction, sexual_purity, church_hurt)
   - Increase pastoral voice to 40% for these 3 themes
   - Emphasize grace over condemnation
4. Input variation patterns:
   - Short: 67 examples
   - Medium: 67 examples
   - Long: 33 examples
5. Save to `augmented_data/v2.0_expanded/{theme}.jsonl`
6. **Hook:** After each theme → "Completed {theme} - 167 examples ✓"

**Script to Run:**
```python
python scripts/02_generate_theme_variations.py \
  --themes "addiction,sexual_purity,lying,boundaries,forgiveness,bitterness,provision,unemployment,purpose,transition,illness,church_hurt" \
  --examples-per-theme 167 \
  --bible-ratio 0.7 \
  --sensitive-themes "addiction,sexual_purity,church_hurt" \
  --sensitive-pastoral-ratio 0.4 \
  --output-dir augmented_data/v2.0_expanded/
```

**Acceptance Criteria:**
- 2,000+ total examples generated
- 12 new JSONL files created
- Appropriate pastoral voice balance for sensitive topics

---

#### Task B5: Subagent 5 - Identity/Worth + Foundational (8 themes)
**Status:** ⬜ Not Started
**Owner:** Subagent 5
**Estimated Time:** 3 days
**Themes:** identity_in_christ, shame, guilt, comparison, hope, strength, comfort, love

**Steps:**
1. Load `theme_taxonomy.json` for theme definitions
2. For each theme, generate 250 examples (8 × 250 = 2,000):
   - 175 bible-sourced (70%)
   - 75 pastoral-voiced (30%)
3. **Special focus:** Foundational themes (hope, strength, comfort, love) should emphasize affirming tone
4. Input variation patterns:
   - Short: 100 examples
   - Medium: 100 examples
   - Long: 50 examples
5. Save to `augmented_data/v2.0_expanded/{theme}.jsonl`
6. **Hook:** After each theme → "Completed {theme} - 250 examples ✓"

**Script to Run:**
```python
python scripts/02_generate_theme_variations.py \
  --themes "identity_in_christ,shame,guilt,comparison,hope,strength,comfort,love" \
  --examples-per-theme 250 \
  --bible-ratio 0.7 \
  --tone-emphasis affirming \
  --output-dir augmented_data/v2.0_expanded/
```

**Acceptance Criteria:**
- 2,000 total examples generated
- 8 new JSONL files created
- Affirming, hope-filled tone validated

---

#### Task B6: Multi-Turn Conversation Generation (All Agents)
**Status:** ⬜ Not Started
**Owner:** All 5 Subagents (400 conversations each)
**Estimated Time:** 2 days (parallel)

**Steps:**
1. Each subagent creates 400 multi-turn conversations for their assigned themes
2. Conversation structure:
   - 2-turn conversations: 40% (160 conversations)
   - 3-turn conversations: 40% (160 conversations)
   - 4-turn conversations: 15% (60 conversations)
   - 5-turn conversations: 5% (20 conversations)
3. Conversation types (evenly distributed):
   - Empathetic (20%): Listening, validating feelings
   - Scriptural (20%): Heavy verse references, teaching
   - Practical (20%): Actionable steps, tools, exercises
   - Challenging (20%): Gentle confrontation, reframing
   - Affirming (20%): Encouragement, identity reinforcement
4. Save to `augmented_data/v2.0_expanded/multi_turn_conversations.jsonl`
5. **Hook:** After every 100 conversations → "Completed 100 multi-turn conversations ✓"

**Script to Run (per subagent):**
```python
python scripts/03_create_multi_turn_conversations.py \
  --themes-file augmented_data/v2.0_expanded/{assigned_themes}.txt \
  --num-conversations 400 \
  --turn-distribution "2:0.4,3:0.4,4:0.15,5:0.05" \
  --conversation-types "empathetic,scriptural,practical,challenging,affirming" \
  --output augmented_data/v2.0_expanded/multi_turn_conversations.jsonl
```

**Acceptance Criteria:**
- 2,000 total conversations (5 agents × 400)
- Turn distribution matches targets
- All 5 conversation types represented
- Schema validation passes

---

### CATEGORY C: VALIDATION & QA (Days 22-28)

**🎯 Goal:** Ensure data quality, remove duplicates, validate accuracy

---

#### Task C1: Duplicate Detection & Removal
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 2 hours

**Steps:**
1. Run `scripts/06_detect_duplicates.py`:
   ```python
   # Exact match detection (hash comparison)
   # Fuzzy match detection (80%+ similarity threshold)
   # Cross-file duplicate checking
   # Remove duplicates, keep highest quality version
   ```
2. Generate report: `validation/duplicate_report.json`
3. **Hook:** Update progress → "Duplicates removed: {count} ✓"

**Acceptance Criteria:**
- No exact duplicates remain
- Fuzzy duplicates (<80% similarity) flagged for review
- Report shows before/after counts

---

#### Task C2: Schema Validation (All Files)
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 1 hour

**Steps:**
1. Run `scripts/05_validate_schema.py` on all `augmented_data/v2.0_expanded/` files
2. Check:
   - Required fields present
   - Data types correct
   - Scripture references valid (Bible API lookup)
   - Confidence scores 0.0-1.0 range
3. **Hook:** Update progress → "Schema validation: {pass_rate}% passed ✓"

**Acceptance Criteria:**
- 100% of files pass schema validation
- Any violations logged to `validation/schema_violations.json`

---

#### Task C3: Theme Classification Accuracy Test
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 3 hours

**Steps:**
1. Split data: 80% train, 20% test (random stratified by theme)
2. Train simple classifier (e.g., Naive Bayes or Logistic Regression)
3. Evaluate on test set:
   - Accuracy score
   - Precision/recall per theme
   - Confusion matrix
4. Generate report: `validation/classification_accuracy.json`
5. **Hook:** Update progress → "Theme classification accuracy: {score}% ✓"

**Acceptance Criteria:**
- Classification accuracy ≥ 95%
- All 40 themes have precision/recall ≥ 0.90
- No theme has <50 examples in test set

**Output Example:**
```json
{
  "total_accuracy": 0.97,
  "by_theme": {
    "anxiety": {"precision": 0.98, "recall": 0.96, "f1": 0.97},
    "grief": {"precision": 0.95, "recall": 0.94, "f1": 0.95},
    ...
  },
  "confusion_matrix": "saved to validation/confusion_matrix.png"
}
```

---

#### Task C4: Human Quality Review (Sample)
**Status:** ⬜ Not Started
**Owner:** Primary Agent (presents samples for user review)
**Estimated Time:** 4 hours (user time)

**Steps:**
1. Randomly sample 500 examples (stratified by theme)
2. Present to user for review:
   - Is theme classification accurate?
   - Is response appropriate and helpful?
   - Is scripture reference contextually relevant?
   - Is pastoral tone empathetic (not preachy)?
3. Collect user feedback in `validation/human_review.csv`
4. **Hook:** Update progress → "Human review complete: {approved}% approved ✓"

**Acceptance Criteria:**
- User reviews 500 samples
- Approval rate ≥ 90%
- Any issues flagged for correction

---

#### Task C5: Balance Check
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 1 hour

**Steps:**
1. Run `scripts/07_balance_themes.py`:
   ```python
   # Count examples per theme
   # Check 70/30 scripture/pastoral ratio globally
   # Verify input length distribution (40/40/20)
   # Ensure all themes have 200-300 examples
   ```
2. Generate report: `validation/balance_report.json`
3. If imbalances found, flag for correction
4. **Hook:** Update progress → "Data balance verified ✓"

**Acceptance Criteria:**
- All 40 themes have 150-350 examples (acceptable variance)
- Global scripture/pastoral ratio 68-72%
- Input length distribution within 5% of targets

---

### CATEGORY D: DOCUMENTATION (Days 26-30, Parallel with C)

**🎯 Goal:** Create comprehensive documentation for dataset users

---

#### Task D1: Data Dictionary
**Status:** ⬜ Not Started
**Owner:** Documentation Subagent 1
**Estimated Time:** 3 hours

**Steps:**
1. Create `docs/data_dictionary.md`
2. Document all fields:
   - Field name
   - Data type
   - Description
   - Example values
   - Required/Optional
3. Include schema diagrams
4. **Hook:** Update progress → "Data dictionary complete ✓"

**Acceptance Criteria:**
- All fields documented
- Examples provided for each field
- Markdown formatting clean and readable

---

#### Task D2: Pastoral Voice Guidelines
**Status:** ⬜ Not Started
**Owner:** Documentation Subagent 2
**Estimated Time:** 4 hours

**Steps:**
1. Create `docs/pastoral_voice_guidelines.md`
2. Extract patterns from existing pastoral examples:
   - Tone principles (empathetic, direct, non-judgmental)
   - Sentence structures
   - Phrase libraries ("Stop believing...", "You don't need to...")
   - Scripture integration patterns
3. Provide do's and don'ts
4. **Hook:** Update progress → "Pastoral voice guidelines complete ✓"

**Acceptance Criteria:**
- 20+ example pastoral responses analyzed
- Clear tone guidelines documented
- Phrase library with 50+ examples

---

#### Task D3: Scripture Selection Criteria
**Status:** ⬜ Not Started
**Owner:** Documentation Subagent 3
**Estimated Time:** 3 hours

**Steps:**
1. Create `docs/scripture_selection_criteria.md`
2. Document how verses were chosen:
   - Thematic relevance
   - Contextual appropriateness
   - Translation choices (KJV vs ESV vs NIV)
   - Avoiding misuse (e.g., prosperity gospel verses)
3. Provide verse selection flowchart
4. **Hook:** Update progress → "Scripture criteria documented ✓"

**Acceptance Criteria:**
- Clear criteria for verse selection
- Examples of good vs poor verse matches
- Translation guidelines

---

#### Task D4: Master README
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 2 hours

**Steps:**
1. Create comprehensive `README.md`:
   - Project overview
   - Dataset statistics
   - File structure guide
   - Usage instructions
   - Licensing (important for Bible content!)
   - Citation format
   - Contact information
2. **Hook:** Update progress → "README complete ✓"

**Acceptance Criteria:**
- README covers all sections
- Statistics accurate (from validation reports)
- Clear usage instructions for LSTM training

---

### CATEGORY E: CONSOLIDATION & DELIVERY (Days 29-30)

**🎯 Goal:** Package everything for LSTM training

---

#### Task E1: Train/Test Split
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 30 minutes

**Steps:**
1. Run `scripts/08_split_train_test.py`:
   ```python
   # 80% train, 20% test (stratified by theme)
   # Save to separate files
   # Ensure no data leakage (multi-turn conversations stay together)
   ```
2. Output:
   - `augmented_data/train_v3.0.jsonl` (~8,000 examples)
   - `augmented_data/test_v3.0.jsonl` (~2,000 examples)
3. **Hook:** Update progress → "Train/test split complete ✓"

**Acceptance Criteria:**
- Train set: 8,000 examples
- Test set: 2,000 examples
- No overlap between sets

---

#### Task E2: Master Consolidated File
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 30 minutes

**Steps:**
1. Run `scripts/09_generate_master_consolidated.py`:
   ```python
   # Combine all theme files + multi-turn conversations
   # Sort by theme, then timestamp
   # Add metadata: version, created_at, total_count
   ```
2. Output: `augmented_data/master_consolidated_v3.0.jsonl` (10,000+ examples)
3. **Hook:** Update progress → "Master file generated ✓"

**Acceptance Criteria:**
- Single file with all examples
- No duplicates
- Sorted consistently

---

#### Task E3: Final Validation Report
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 1 hour

**Steps:**
1. Aggregate all validation results:
   - Baseline analysis (Task A2)
   - Duplicate report (Task C1)
   - Schema validation (Task C2)
   - Classification accuracy (Task C3)
   - Human review (Task C4)
   - Balance check (Task C5)
2. Create executive summary: `validation/FINAL_VALIDATION_REPORT.md`
3. Include before/after metrics
4. **Hook:** Update progress → "Final validation report complete ✓"

**Acceptance Criteria:**
- All metrics aggregated
- Executive summary readable
- Pass/fail status clear for each criterion

**Output Example:**
```markdown
# Final Validation Report - Christian AI Training Data v3.0

## Executive Summary
✅ PASSED - Dataset ready for LSTM training

## Metrics
| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Total Examples | 10,000+ | 10,487 | ✅ |
| Theme Coverage | 40 themes | 40 themes | ✅ |
| Classification Accuracy | ≥95% | 97.2% | ✅ |
| Schema Compliance | 100% | 100% | ✅ |
| Human Approval Rate | ≥90% | 94.6% | ✅ |
| Scripture/Pastoral Ratio | 70/30 | 71/29 | ✅ |

## Improvements from v2.0
- Dataset size: 1,316 → 10,487 (796% increase)
- Theme coverage: 7 → 40 (100% taxonomy)
- Multi-turn conversations: 0 → 2,000 (new capability)
- Input length diversity: Short only → Short/Medium/Long mix

## Recommendations for LSTM Training
1. Use character-level LSTM (vocab size: ~100)
2. Embedding dim: 256, Hidden units: 512
3. Attention mechanism for long inputs (>100 chars)
4. Train with 80/20 split provided
5. Target perplexity: <50 for pastoral voice quality
```

---

#### Task E4: Package & Archive
**Status:** ⬜ Not Started
**Owner:** Primary Agent
**Estimated Time:** 30 minutes

**Steps:**
1. Create ZIP archive:
   ```bash
   zip -r christian_ai_training_data_v3.0.zip \
     augmented_data/ \
     validation/ \
     docs/ \
     README.md \
     theme_taxonomy.json
   ```
2. Upload to cloud storage (S3 or Google Drive)
3. Generate download link
4. **Hook:** Update progress → "Dataset packaged and archived ✓"

**Acceptance Criteria:**
- ZIP file <100 MB (JSONL is compressed efficiently)
- All files included
- Download link works

---

## 📊 PROGRESS TRACKING

### Overall Status Dashboard

| Category | Tasks | Completed | In Progress | Not Started | % Complete |
|----------|-------|-----------|-------------|-------------|------------|
| A: Setup & Analysis | 3 | 0 | 0 | 3 | 0% |
| B: Data Generation | 6 | 0 | 0 | 6 | 0% |
| C: Validation & QA | 5 | 0 | 0 | 5 | 0% |
| D: Documentation | 4 | 0 | 0 | 4 | 0% |
| E: Consolidation | 4 | 0 | 0 | 4 | 0% |
| **TOTAL** | **22** | **0** | **0** | **22** | **0%** |

### Milestone Tracker

- [ ] **Milestone 1:** Setup complete (Tasks A1-A3)
- [ ] **Milestone 2:** 5,000 examples generated (Tasks B1-B3 complete)
- [ ] **Milestone 3:** 10,000 examples generated (Tasks B4-B6 complete)
- [ ] **Milestone 4:** Validation passed (Tasks C1-C5 complete)
- [ ] **Milestone 5:** Documentation finished (Tasks D1-D4 complete)
- [ ] **Milestone 6:** Final delivery (Tasks E1-E4 complete)

### Critical Path

```
A1 → A2 → A3 → [B1, B2, B3, B4, B5 parallel] → B6 (depends on B1-B5) →
C1 → C2 → C3 → C4 → C5 → E1 → E2 → E3 → E4
[D1, D2, D3 parallel] → D4 (anytime after C5)
```

**Estimated Total Time:** 30 days (assuming parallel execution of subagents)

---

## 🚀 EXECUTION INSTRUCTIONS

### For Claude Code (Primary Agent):

1. **Start with Category A tasks (sequential):**
   - Execute A1, then A2, then A3
   - Wait for user confirmation before proceeding to Category B

2. **Deploy Category B subagents (parallel):**
   - Use Task tool to launch 5 subagents simultaneously
   - Each subagent runs `scripts/02_generate_theme_variations.py` with their assigned themes
   - Monitor progress via hooks
   - After B1-B5 complete, deploy subagents again for B6 (multi-turn conversations)

3. **Execute Category C tasks (sequential):**
   - Run C1, then C2, then C3, then C4 (requires user participation), then C5
   - Review validation results with user before proceeding

4. **Deploy Category D subagents (parallel, can start during Category C):**
   - Launch 3 documentation subagents for D1, D2, D3
   - Primary agent completes D4 after D1-D3 finish

5. **Execute Category E tasks (sequential):**
   - Run E1, then E2, then E3, then E4
   - Present final delivery to user

### For User:

1. **Your involvement required:**
   - Task A2: Review baseline analysis report
   - Task C4: Human quality review (500 samples, ~4 hours)
   - Task E3: Review final validation report
   - Task E4: Approve final delivery

2. **Approval gates:**
   - After Task A3: Approve proceeding to data generation
   - After Task C5: Approve proceeding to consolidation
   - After Task E3: Final approval for delivery

---

## 🎯 SUCCESS CRITERIA SUMMARY

**Dataset must achieve ALL of the following to be considered complete:**

1. ✅ Total examples ≥ 10,000
2. ✅ All 40 themes from taxonomy represented (150-350 examples each)
3. ✅ Theme classification accuracy ≥ 95% on test set
4. ✅ 100% schema validation pass rate
5. ✅ Zero exact duplicates, <10 fuzzy duplicates flagged
6. ✅ Scripture/pastoral ratio 68-72% globally
7. ✅ Input length distribution: 38-42% short, 38-42% medium, 18-22% long
8. ✅ Multi-turn conversations: 2,000+ (30% of single-turn examples)
9. ✅ Human approval rate ≥ 90% on 500-sample review
10. ✅ Comprehensive documentation (data dictionary, guidelines, README)

---

## 📝 NOTES & ASSUMPTIONS

**Assumptions:**
- User has Python 3.10+ installed
- User has access to Bible API or local scripture corpus
- User has Claude API key for LLM-based pastoral voice augmentation
- User can commit ~4 hours for human quality review (Task C4)
- Cloud storage (S3/Drive) available for final archive

**Dependencies:**
- Python libraries: `jsonlines`, `jsonschema`, `fuzzywuzzy`, `sklearn`, `requests`
- External APIs: Bible API (e.g., api.bible), Claude API
- Git for version control

**Risk Mitigation:**
- If LLM augmentation quality is poor, increase human review sample size
- If theme balance fails, use oversampling/undersampling (Task C5)
- If validation fails, iterate on data generation (return to Category B)

---

## 📞 CONTACT & SUPPORT

**Project Owner:** [Your Name]
**Created:** October 8, 2025
**Version:** 1.0
**License:** Creative Commons Attribution-ShareAlike 4.0 (Bible content public domain)

**Questions or Issues:**
- Open GitHub issue in project repository
- Email: [your-email]
- Documentation: See `docs/` directory

---

**END OF SPEC-DRIVEN DEVELOPMENT PLAN**

This plan is 100% executable. Follow the task sequence, deploy subagents as indicated, and use the hooks to maintain accountability. All outputs are measurable and verifiable.

**Next Step:** Execute Task A1 to create project structure. Ready to begin? 🚀
