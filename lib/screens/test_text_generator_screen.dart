import 'package:flutter/material.dart';
import '../services/text_generator_service.dart';

/// Test screen for the LSTM text generator
class TestTextGeneratorScreen extends StatefulWidget {
  const TestTextGeneratorScreen({super.key});

  @override
  State<TestTextGeneratorScreen> createState() => _TestTextGeneratorScreenState();
}

class _TestTextGeneratorScreenState extends State<TestTextGeneratorScreen> {
  final _service = TextGeneratorService.instance;
  final _promptController = TextEditingController(text: 'God ');
  String _generatedText = '';
  bool _isLoading = false;
  bool _isInitialized = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await _service.initialize();
      setState(() {
        _isInitialized = true;
        _error = 'Model initialized! Vocab size: ${_service.vocabSize}';
      });
    } catch (e) {
      setState(() {
        _error = 'Initialization failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateText() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _service.generateText(
        prompt: _promptController.text,
        maxLength: 200,
        temperature: 0.7,
      );

      setState(() {
        _generatedText = result;
      });
    } catch (e) {
      setState(() {
        _error = 'Generation failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Generator Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _isInitialized
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.pending,
                          color: _isInitialized ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isInitialized
                                ? 'Ready (${_service.vocabSize} chars)'
                                : 'Initializing...',
                          ),
                        ),
                      ],
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error,
                        style: TextStyle(
                          color: _error.contains('failed')
                              ? Colors.red
                              : Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                hintText: 'Enter starting text...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Generate Button
            ElevatedButton.icon(
              onPressed: _isInitialized && !_isLoading ? _generateText : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Generating...' : 'Generate Text'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Output
            Expanded(
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generated Text:',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Divider(),
                        Text(
                          _generatedText.isEmpty
                              ? 'Generated text will appear here...'
                              : _generatedText,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: _generatedText.isEmpty
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
