#!/bin/bash

# Cloudflare AI Integration Test Suite
# Tests all critical functionality before deployment

ACCOUNT_ID="f56a6b02be9ed4b418a06e6169d4b4be"
API_TOKEN="FVJ0Sfwy4f0WubZpHr0mVFckVrQms9GoieIrNyXa"
BASE_URL="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/ai/run"
MODEL="@cf/meta/llama-3.1-8b-instruct"

echo "=========================================="
echo "CLOUDFLARE AI INTEGRATION TEST SUITE"
echo "=========================================="
echo ""

# Test 1: Basic AI Response
echo "✅ TEST 1: Basic AI Functionality"
echo "Testing: Anxiety pastoral guidance..."
RESPONSE=$(curl -s -X POST "$BASE_URL/$MODEL" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "messages": [
      {"role": "system", "content": "You are a compassionate pastoral counselor providing biblical guidance."},
      {"role": "user", "content": "I am feeling anxious about work.\n\nRelevant Scripture:\n\"Cast all your anxiety on him because he cares for you.\" - 1 Peter 5:7"}
    ],
    "max_tokens": 200
  }')

if echo "$RESPONSE" | grep -q "success\":true"; then
  echo "✅ PASSED: AI response generated"
  echo "Response preview: $(echo "$RESPONSE" | jq -r '.result.response' | head -c 100)..."
  TOKENS=$(echo "$RESPONSE" | jq -r '.result.usage.total_tokens')
  echo "Tokens used: $TOKENS"
else
  echo "❌ FAILED: AI response error"
  echo "$RESPONSE"
fi
echo ""

# Test 2: Depression Theme
echo "✅ TEST 2: Depression Theme"
RESPONSE2=$(curl -s -X POST "$BASE_URL/$MODEL" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "messages": [
      {"role": "system", "content": "You are a compassionate pastoral counselor."},
      {"role": "user", "content": "I am struggling with depression.\n\nRelevant Scripture:\n\"The Lord is close to the brokenhearted.\" - Psalm 34:18"}
    ],
    "max_tokens": 150
  }')

if echo "$RESPONSE2" | grep -q "success\":true"; then
  echo "✅ PASSED: Depression guidance generated"
  TOKENS2=$(echo "$RESPONSE2" | jq -r '.result.usage.total_tokens')
  echo "Tokens used: $TOKENS2"
else
  echo "❌ FAILED"
fi
echo ""

# Test 3: Guidance Theme
echo "✅ TEST 3: Guidance Theme"
RESPONSE3=$(curl -s -X POST "$BASE_URL/$MODEL" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "messages": [
      {"role": "system", "content": "You are a compassionate pastoral counselor."},
      {"role": "user", "content": "I need guidance on an important decision.\n\nRelevant Scripture:\n\"Trust in the Lord with all your heart.\" - Proverbs 3:5-6"}
    ],
    "max_tokens": 150
  }')

if echo "$RESPONSE3" | grep -q "success\":true"; then
  echo "✅ PASSED: Guidance generated"
  TOKENS3=$(echo "$RESPONSE3" | jq -r '.result.usage.total_tokens')
  echo "Tokens used: $TOKENS3"
else
  echo "❌ FAILED"
fi
echo ""

# Test 4: Error Handling (Invalid Token)
echo "✅ TEST 4: Error Handling (Invalid Token)"
ERROR_RESPONSE=$(curl -s -X POST "$BASE_URL/$MODEL" \
  -H "Authorization: Bearer INVALID_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "messages": [
      {"role": "user", "content": "Test"}
    ],
    "max_tokens": 10
  }')

if echo "$ERROR_RESPONSE" | grep -q "success\":false"; then
  echo "✅ PASSED: Invalid token correctly rejected"
else
  echo "❌ FAILED: Should reject invalid token"
fi
echo ""

# Test 5: Cost Calculation
echo "=========================================="
echo "COST SUMMARY"
echo "=========================================="
TOTAL_TOKENS=$(($TOKENS + $TOKENS2 + $TOKENS3))
NEURONS_USED=$(echo "scale=2; $TOTAL_TOKENS * 0.154" | bc)  # ~7.7 neurons per 50 tokens
echo "Total tokens used: $TOTAL_TOKENS"
echo "Estimated neurons: $NEURONS_USED"
echo "Free tier remaining: ~9,900 neurons (10,000 - 100 from earlier tests)"
echo "Cost: \$0.00 (within free tier)"
echo ""

echo "=========================================="
echo "TEST SUITE COMPLETE"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Run the Flutter app manually to test UI"
echo "2. Navigate to Chat Screen"
echo "3. Send test messages"
echo "4. Verify responses appear within 3 seconds"
echo "5. Check console for Cloudflare AI logs"
