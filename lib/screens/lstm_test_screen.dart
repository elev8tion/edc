import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/text_generator_service.dart';

class LSTMTestScreen extends StatefulWidget {
  const LSTMTestScreen({Key? key}) : super(key: key);

  @override
  State<LSTMTestScreen> createState() => _LSTMTestScreenState();
}

class _LSTMTestScreenState extends State<LSTMTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextGeneratorService _textGen = TextGeneratorService.instance;
  
  bool _isInitializing = true;
  bool _isGenerating = false;
  String _status = 'Initializing...';
  String _generatedText = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isInitializing = true;
      _status = 'Loading LSTM model...';
      _error = null;
    });

    try {
      await _textGen.initialize();
      
      setState(() {
        _isInitializing = false;
        if (_textGen.isReady) {
          _status = '✅ LSTM Model Loaded Successfully!\nVocab Size: ${_textGen.vocabSize} characters';
        } else {
          _status = '⚠️ Model loaded but not ready';
          _error = 'Text generator not in ready state';
        }
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _status = '❌ Failed to load model';
        _error = e.toString();
      });
    }
  }

  Future<void> _generateText() async {
    if (!_textGen.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model not ready!')),
      );
      return;
    }

    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedText = '';
      _error = null;
    });

    try {
      final result = await _textGen.generateResponse(
        userInput: prompt,
        theme: 'general',
        maxLength: 200,
      );

      setState(() {
        _isGenerating = false;
        _generatedText = result;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = 'Generation failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LSTM Model Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _error != null 
                  ? Colors.red.shade50 
                  : _textGen.isReady 
                      ? Colors.green.shade50 
                      : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (_isInitializing)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Model Info
            if (_textGen.isReady) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('• Vocabulary Size: ${_textGen.vocabSize}'),
                      const Text('• Model Type: LSTM Text Generator'),
                      const Text('• Format: TensorFlow Lite'),
                      const Text('• Max Sequence: 100 characters'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Generation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter prompt',
                        hintText: 'e.g., "I feel anxious about..."',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _textGen.isReady && !_isGenerating
                          ? _generateText
                          : null,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Output Section
            if (_generatedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Generated Response',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_generatedText),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _generatedText),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
