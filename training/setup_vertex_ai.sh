#!/bin/bash

# Vertex AI Setup Script
# This script prepares and submits your training job to Google Cloud

echo "🚀 Vertex AI Training Setup for LSTM Text Generator"
echo "===================================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Configuration
PROJECT_ID="everyday-christian"  # UPDATE THIS WITH YOUR ACTUAL PROJECT ID
BUCKET_NAME="everyday-christian-models"
REGION="us-east4"
JOB_NAME="lstm-text-generator-$(date +%Y%m%d-%H%M%S)"

echo "📋 Configuration:"
echo "   Project: $PROJECT_ID"
echo "   Bucket: $BUCKET_NAME"
echo "   Region: $REGION"
echo "   Job Name: $JOB_NAME"
echo ""

# Step 1: Set project
echo "1️⃣ Setting GCP project..."
gcloud config set project $PROJECT_ID

# Step 2: Create bucket if it doesn't exist
echo "2️⃣ Creating GCS bucket..."
gsutil mb -l $REGION gs://$BUCKET_NAME 2>/dev/null || echo "   Bucket already exists"

# Step 3: Upload training data
echo "3️⃣ Uploading training data to GCS..."
gsutil cp ../assets/training_data/lstm_training_data.txt \
    gs://$BUCKET_NAME/training_data/lstm_training_data.txt

# Step 4: Package the training script
echo "4️⃣ Packaging training script..."
tar -czf trainer.tar.gz train_vertex_ai.py
gsutil cp trainer.tar.gz gs://$BUCKET_NAME/training/trainer.tar.gz

# Step 5: Submit training job
echo "5️⃣ Submitting Vertex AI training job..."
gcloud ai custom-jobs create \
    --display-name="$JOB_NAME" \
    --config=vertex_ai_config.yaml \
    --region=$REGION

echo ""
echo "✅ Training job submitted!"
echo ""
echo "📊 Monitor your job at:"
echo "   https://console.cloud.google.com/vertex-ai/training/custom-jobs?project=$PROJECT_ID"
echo ""
echo "⏱️ Estimated training time: 2-3 hours with GPU"
echo ""
echo "📦 After training completes, download your model:"
echo "   gsutil cp gs://$BUCKET_NAME/models/text_generator.tflite ../assets/models/"
echo "   gsutil cp gs://$BUCKET_NAME/models/char_vocab.txt ../assets/models/"
echo ""
echo "💡 Tip: The model will be MUCH better after 50 epochs of proper training!"