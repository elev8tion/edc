"""
Vertex AI Training Script for LSTM Text Generator
Trains on Google Cloud with GPU acceleration for 50+ epochs
"""

import tensorflow as tf
import numpy as np
import os
import argparse
from google.cloud import storage

# Parse arguments for Vertex AI
parser = argparse.ArgumentParser()
parser.add_argument('--epochs', type=int, default=50, help='Number of epochs')
parser.add_argument('--batch-size', type=int, default=256, help='Batch size')
parser.add_argument('--learning-rate', type=float, default=0.001, help='Learning rate')
parser.add_argument('--model-dir', type=str, default=os.environ.get('AIP_MODEL_DIR', './model'), help='Model output directory')
parser.add_argument('--bucket-name', type=str, default='everyday-christian-models', help='GCS bucket name')
args = parser.parse_args()

# Configuration - PROPER TRAINING SETTINGS
MODEL_DIR = args.model_dir
SEQ_LENGTH = 100
BATCH_SIZE = args.batch_size  # 256 for GPU training
BUFFER_SIZE = 10000
EMBEDDING_DIM = 256
RNN_UNITS = 1024
EPOCHS = args.epochs  # 50 epochs for proper training
LEARNING_RATE = args.learning_rate

print(f"🚀 Vertex AI Training Configuration:")
print(f"   Epochs: {EPOCHS}")
print(f"   Batch Size: {BATCH_SIZE}")
print(f"   Learning Rate: {LEARNING_RATE}")
print(f"   Output Dir: {MODEL_DIR}")

# Create model directory
os.makedirs(MODEL_DIR, exist_ok=True)

def load_training_data():
    """Load training data from GCS or local file"""
    print("📖 Loading Christian training data...")

    # For Vertex AI, load from GCS
    if args.bucket_name:
        client = storage.Client()
        bucket = client.bucket(args.bucket_name)
        blob = bucket.blob('training_data/lstm_training_data.txt')
        full_text = blob.download_as_text()
    else:
        # Local fallback
        training_file = '/Users/kcdacre8tor/ everyday-christian/assets/training_data/lstm_training_data.txt'
        with open(training_file, 'r', encoding='utf-8') as f:
            full_text = f.read()

    print(f"✅ Loaded {len(full_text)} characters of Christian text")
    return full_text

def create_character_mappings(text):
    """Create character to index mappings"""
    vocab = sorted(set(text))
    vocab = ['<PAD>', '<START>', '<END>'] + vocab

    char2idx = {char: idx for idx, char in enumerate(vocab)}
    idx2char = {idx: char for idx, char in enumerate(vocab)}

    print(f"📝 Vocabulary size: {len(vocab)}")

    # Save vocabulary
    vocab_path = os.path.join(MODEL_DIR, 'char_vocab.txt')
    with open(vocab_path, 'w', encoding='utf-8') as f:
        for char in vocab:
            f.write(f"{char}\n")

    print(f"✅ Saved vocabulary to {vocab_path}")
    return char2idx, idx2char, vocab

def create_training_sequences(text, char2idx, seq_length):
    """Create training sequences with optimizations"""
    text_as_int = np.array([char2idx[c] for c in text])

    char_dataset = tf.data.Dataset.from_tensor_slices(text_as_int)
    sequences = char_dataset.batch(seq_length + 1, drop_remainder=True)

    def split_input_target(chunk):
        input_text = chunk[:-1]
        target_text = chunk[1:]
        return input_text, target_text

    dataset = sequences.map(split_input_target)
    dataset = dataset.cache()
    dataset = dataset.prefetch(tf.data.AUTOTUNE)

    return dataset

def build_model(vocab_size, embedding_dim, rnn_units, batch_size):
    """Build improved LSTM model"""
    model = tf.keras.Sequential([
        tf.keras.layers.Embedding(
            vocab_size,
            embedding_dim,
            batch_input_shape=[batch_size, None]
        ),
        tf.keras.layers.LSTM(
            rnn_units,
            return_sequences=True,
            stateful=False,
            recurrent_initializer='glorot_uniform',
            recurrent_dropout=0.1  # Added recurrent dropout
        ),
        tf.keras.layers.Dropout(0.3),  # Increased dropout
        tf.keras.layers.LSTM(
            rnn_units // 2,
            return_sequences=True,
            stateful=False,
            recurrent_initializer='glorot_uniform',
            recurrent_dropout=0.1
        ),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(
            vocab_size,
            kernel_regularizer=tf.keras.regularizers.l2(0.01)  # Added L2 regularization
        )
    ])

    return model

def train_model():
    """Main training function for Vertex AI"""
    print("🚀 Starting Vertex AI training...")

    # Enable mixed precision for faster GPU training
    policy = tf.keras.mixed_precision.Policy('mixed_float16')
    tf.keras.mixed_precision.set_global_policy(policy)

    # Load data
    text = load_training_data()

    # Create mappings
    char2idx, idx2char, vocab = create_character_mappings(text)
    vocab_size = len(vocab)

    # Create dataset
    dataset = create_training_sequences(text, char2idx, SEQ_LENGTH)
    dataset = dataset.shuffle(BUFFER_SIZE).batch(BATCH_SIZE, drop_remainder=True)

    # Calculate steps per epoch
    steps_per_epoch = len(text) // (SEQ_LENGTH * BATCH_SIZE)
    print(f"📊 Steps per epoch: {steps_per_epoch}")

    # Build model
    print("🏗️ Building LSTM model...")
    model = build_model(vocab_size, EMBEDDING_DIM, RNN_UNITS, BATCH_SIZE)

    # Custom learning rate schedule
    lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(
        initial_learning_rate=LEARNING_RATE,
        decay_steps=steps_per_epoch * 10,
        decay_rate=0.95,
        staircase=True
    )

    # Compile with better optimizer
    optimizer = tf.keras.optimizers.Adam(learning_rate=lr_schedule)

    model.compile(
        optimizer=optimizer,
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=['accuracy']
    )

    # Callbacks
    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(
            filepath=os.path.join(MODEL_DIR, 'checkpoint-{epoch:02d}'),
            save_weights_only=True,
            save_freq='epoch'
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='loss',
            factor=0.5,
            patience=5,
            min_lr=1e-5,
            verbose=1
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor='loss',
            patience=10,  # More patience
            min_delta=0.0001,
            restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.TensorBoard(
            log_dir=os.path.join(MODEL_DIR, 'logs'),
            histogram_freq=1
        )
    ]

    # Train with more epochs
    print(f"🎓 Training model for {EPOCHS} epochs...")
    history = model.fit(
        dataset,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )

    # Print training results
    final_loss = history.history['loss'][-1]
    final_accuracy = history.history['accuracy'][-1]
    print(f"✅ Training complete!")
    print(f"   Final Loss: {final_loss:.4f}")
    print(f"   Final Accuracy: {final_accuracy:.4f}")

    # Rebuild model for inference
    print("🔄 Rebuilding model for inference...")
    inference_model = build_model(vocab_size, EMBEDDING_DIM, RNN_UNITS, batch_size=1)
    inference_model.set_weights(model.get_weights())
    inference_model.build(tf.TensorShape([1, None]))

    # Save Keras model
    keras_path = os.path.join(MODEL_DIR, 'text_generator.h5')
    inference_model.save(keras_path)
    print(f"✅ Saved Keras model to {keras_path}")

    # Convert to TFLite with iOS compatibility
    print("📦 Converting to TFLite (iOS compatible)...")
    converter = tf.lite.TFLiteConverter.from_keras_model(inference_model)

    # iOS-compatible settings (NO GPU DELEGATE OPERATIONS)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS  # Only standard TFLite ops for iOS CPU
    ]

    tflite_model = converter.convert()

    # Save TFLite model
    tflite_path = os.path.join(MODEL_DIR, 'text_generator.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)

    print(f"✅ Saved TFLite model to {tflite_path}")
    print(f"📊 Model size: {len(tflite_model) / 1024 / 1024:.2f} MB")

    # Test generation
    print("\n🧪 Testing text generation...")
    test_generate_text(inference_model, char2idx, idx2char, vocab_size)

    # Upload to GCS if specified
    if args.bucket_name:
        print(f"\n☁️ Uploading model to GCS bucket: {args.bucket_name}")
        client = storage.Client()
        bucket = client.bucket(args.bucket_name)

        # Upload TFLite model
        blob = bucket.blob('models/text_generator.tflite')
        blob.upload_from_filename(tflite_path)
        print(f"✅ Uploaded TFLite model to gs://{args.bucket_name}/models/text_generator.tflite")

        # Upload vocab
        vocab_blob = bucket.blob('models/char_vocab.txt')
        vocab_blob.upload_from_filename(os.path.join(MODEL_DIR, 'char_vocab.txt'))
        print(f"✅ Uploaded vocabulary to gs://{args.bucket_name}/models/char_vocab.txt")

    print("\n✨ Vertex AI training complete!")
    print(f"Download your model from the output directory or GCS bucket")

def test_generate_text(model, char2idx, idx2char, vocab_size, start_string="God "):
    """Test text generation with multiple temperatures"""
    print(f"\nTesting with prompt: '{start_string}'")

    for temperature in [0.3, 0.5, 0.8]:
        print(f"\n🌡️ Temperature: {temperature}")
        num_generate = 200

        input_eval = [char2idx.get(s, char2idx.get(' ', 0)) for s in start_string]
        input_eval = tf.expand_dims(input_eval, 0)

        text_generated = []
        model.reset_states()

        for i in range(num_generate):
            predictions = model(input_eval)
            predictions = tf.squeeze(predictions, 0)

            # Apply temperature
            predictions = predictions / temperature
            predicted_id = tf.random.categorical(predictions, num_samples=1)[-1, 0].numpy()

            input_eval = tf.expand_dims([predicted_id], 0)
            text_generated.append(idx2char[predicted_id])

        generated_text = start_string + ''.join(text_generated)
        print(f"Generated: {generated_text[:150]}...")

if __name__ == "__main__":
    # Set GPU memory growth
    gpus = tf.config.experimental.list_physical_devices('GPU')
    if gpus:
        try:
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            print(f"🎮 Using GPU: {gpus[0].name}")
        except RuntimeError as e:
            print(e)

    train_model()