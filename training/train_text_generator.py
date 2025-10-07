"""
Train LSTM Text Generator for Christian/Bible Text
Adapted from nikhithan-lab/textgeneration-tflite

This script trains a character-level LSTM model on Christian text
and converts it to TFLite for use in the everyday-christian Flutter app.
"""

import tensorflow as tf
import numpy as np
import os
import requests

# Configuration
MODEL_DIR = '../assets/models'
SEQ_LENGTH = 100
BATCH_SIZE = 64
BUFFER_SIZE = 10000
EMBEDDING_DIM = 256
RNN_UNITS = 1024
EPOCHS = 30

# Create model directory if it doesn't exist
os.makedirs(MODEL_DIR, exist_ok=True)


def download_bible_text():
    """Download KJV Bible text"""
    url = 'https://raw.githubusercontent.com/scrollmapper/bible_databases/master/kjv.txt'
    response = requests.get(url)
    return response.text


def download_devotional_text():
    """Download additional Christian devotional text"""
    # You can add more sources here
    urls = [
        'https://www.gutenberg.org/files/84/84-0.txt',  # Frankenstein (replace with Christian text)
    ]

    text = ""
    for url in urls:
        try:
            response = requests.get(url)
            text += "\n" + response.text
        except:
            pass

    return text


def load_training_data():
    """Load and combine training data"""
    print("📖 Downloading training data...")

    # Download Bible
    bible_text = download_bible_text()

    # Combine texts
    full_text = bible_text

    print(f"✅ Loaded {len(full_text)} characters")
    return full_text


def create_character_mappings(text):
    """Create character to index mappings"""
    vocab = sorted(set(text))

    # Add special tokens
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
    """Create training sequences"""
    text_as_int = np.array([char2idx[c] for c in text])

    # Create sequences
    examples_per_epoch = len(text) // (seq_length + 1)

    char_dataset = tf.data.Dataset.from_tensor_slices(text_as_int)
    sequences = char_dataset.batch(seq_length + 1, drop_remainder=True)

    def split_input_target(chunk):
        input_text = chunk[:-1]
        target_text = chunk[1:]
        return input_text, target_text

    dataset = sequences.map(split_input_target)

    return dataset


def build_model(vocab_size, embedding_dim, rnn_units, batch_size):
    """Build the LSTM model"""
    model = tf.keras.Sequential([
        tf.keras.layers.Embedding(
            vocab_size,
            embedding_dim,
            batch_input_shape=[batch_size, None]
        ),
        tf.keras.layers.LSTM(
            rnn_units,
            return_sequences=True,
            stateful=True,
            recurrent_initializer='glorot_uniform'
        ),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.LSTM(
            rnn_units // 2,
            return_sequences=True,
            stateful=True,
            recurrent_initializer='glorot_uniform'
        ),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(vocab_size)
    ])

    return model


def loss_function(labels, logits):
    """Custom loss function"""
    return tf.keras.losses.sparse_categorical_crossentropy(
        labels, logits, from_logits=True
    )


def train_model():
    """Main training function"""
    print("🚀 Starting text generator training...")

    # Load data
    text = load_training_data()

    # Create mappings
    char2idx, idx2char, vocab = create_character_mappings(text)
    vocab_size = len(vocab)

    # Create dataset
    dataset = create_training_sequences(text, char2idx, SEQ_LENGTH)
    dataset = dataset.shuffle(BUFFER_SIZE).batch(BATCH_SIZE, drop_remainder=True)

    # Build model
    print("🏗️  Building model...")
    model = build_model(vocab_size, EMBEDDING_DIM, RNN_UNITS, BATCH_SIZE)

    # Compile
    model.compile(
        optimizer='adam',
        loss=loss_function,
        metrics=['accuracy']
    )

    # Callbacks
    checkpoint_dir = './training_checkpoints'
    checkpoint_prefix = os.path.join(checkpoint_dir, "ckpt_{epoch}")

    checkpoint_callback = tf.keras.callbacks.ModelCheckpoint(
        filepath=checkpoint_prefix,
        save_weights_only=True
    )

    early_stopping = tf.keras.callbacks.EarlyStopping(
        monitor='loss',
        patience=3,
        restore_best_weights=True
    )

    # Train
    print("🎓 Training model...")
    history = model.fit(
        dataset,
        epochs=EPOCHS,
        callbacks=[checkpoint_callback, early_stopping]
    )

    # Rebuild model for inference (batch_size=1)
    print("🔄 Rebuilding model for inference...")
    inference_model = build_model(vocab_size, EMBEDDING_DIM, RNN_UNITS, batch_size=1)
    inference_model.load_weights(tf.train.latest_checkpoint(checkpoint_dir))
    inference_model.build(tf.TensorShape([1, None]))

    # Save as Keras model
    keras_model_path = os.path.join(MODEL_DIR, 'text_generator.h5')
    inference_model.save(keras_model_path)
    print(f"✅ Saved Keras model to {keras_model_path}")

    # Convert to TFLite
    print("📦 Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(inference_model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
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

    print("\n✨ Training complete!")
    print(f"\nNext steps:")
    print(f"1. Copy {tflite_path} to your Flutter app's assets/models/")
    print(f"2. Copy {vocab_path} to your Flutter app's assets/models/")
    print(f"3. Update pubspec.yaml to include these assets")


def test_generate_text(model, char2idx, idx2char, vocab_size, start_string="God "):
    """Test text generation"""
    num_generate = 200

    input_eval = [char2idx.get(s, char2idx.get(' ', 0)) for s in start_string]
    input_eval = tf.expand_dims(input_eval, 0)

    text_generated = []
    model.reset_states()

    for i in range(num_generate):
        predictions = model(input_eval)
        predictions = tf.squeeze(predictions, 0)

        # Use temperature sampling
        predictions = predictions / 0.7
        predicted_id = tf.random.categorical(predictions, num_samples=1)[-1, 0].numpy()

        input_eval = tf.expand_dims([predicted_id], 0)
        text_generated.append(idx2char[predicted_id])

    generated_text = start_string + ''.join(text_generated)
    print(f"\nGenerated sample:\n{generated_text}")


if __name__ == "__main__":
    train_model()
