#!/bin/bash
# Diagnostic script to check iOS deployment status

echo "========================================="
echo "EVERYDAY CHRISTIAN - iOS DIAGNOSTIC"
echo "========================================="
echo ""

echo "1. Checking TFLite Models..."
if [ -f "assets/models/text_generator.tflite" ]; then
    echo "✅ text_generator.tflite exists ($(du -h assets/models/text_generator.tflite | cut -f1))"
else
    echo "❌ text_generator.tflite MISSING"
fi

if [ -f "assets/models/text_classification.tflite" ]; then
    echo "✅ text_classification.tflite exists ($(du -h assets/models/text_classification.tflite | cut -f1))"
else
    echo "❌ text_classification.tflite MISSING"
fi

if [ -f "assets/models/char_vocab.txt" ]; then
    echo "✅ char_vocab.txt exists ($(wc -l < assets/models/char_vocab.txt) lines)"
else
    echo "❌ char_vocab.txt MISSING"
fi

echo ""
echo "2. Checking Flutter Dependencies..."
flutter doctor -v | grep -A 5 "Flutter\|iOS"

echo ""
echo "3. Checking iOS Simulators..."
xcrun simctl list devices | grep "iPhone"

echo ""
echo "4. Checking pubspec.yaml for tflite_flutter..."
grep "tflite_flutter" pubspec.yaml || echo "❌ tflite_flutter not found in pubspec.yaml"

echo ""
echo "5. Checking iOS Pods..."
if [ -f "ios/Podfile.lock" ]; then
    grep "TensorFlowLite" ios/Podfile.lock || echo "⚠️  TensorFlowLite pods might not be installed"
else
    echo "❌ Podfile.lock not found"
fi

echo ""
echo "========================================="
echo "DIAGNOSTIC COMPLETE"
echo "========================================="
