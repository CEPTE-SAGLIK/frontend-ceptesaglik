import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/presentation/home/viewmodel/gemini_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GeminiAssistantSheet extends StatefulWidget {
  const GeminiAssistantSheet({super.key});

  @override
  State<GeminiAssistantSheet> createState() => _GeminiAssistantSheetState();
}

class _GeminiAssistantSheetState extends State<GeminiAssistantSheet> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          }),
          localeId: 'tr_TR', // Türkçe dinleme
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mikrofon izni verilmedi veya cihaz desteklemiyor!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dinamik olarak ViewModel'ı izle
    return Consumer<GeminiViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "🪄 Yapay Zeka Asistanı",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      viewModel.reset();
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // İçerik (Duruma göre)
              _buildContent(context, viewModel),

            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, GeminiViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Asistan yanıt hazırlıyor... 🪄",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (viewModel.message != null) {
      return _buildAssistantMessage(context, viewModel);
    }

    return _buildInput(viewModel);
  }

  Widget _buildAssistantMessage(
    BuildContext context,
    GeminiViewModel viewModel,
  ) {
    final msg = viewModel.message!;
    final isErr = viewModel.isError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          isErr ? Icons.error_outline : Icons.auto_awesome,
          color: isErr ? Colors.red : AppColors.primaryBlue,
          size: 40,
        ),
        const SizedBox(height: 12),
        SelectableText(
          msg,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: isErr ? Colors.red.shade800 : null,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => viewModel.reset(),
          child: Text(isErr ? 'Tekrar dene' : 'Yeni soru'),
        ),
      ],
    );
  }

  Widget _buildInput(GeminiViewModel viewModel) {
    return Column(
      children: [
        const Text(
          "İlaç kullanımınızı veya randevunuzu doğal bir dille yazın. (Örn: 'Yarın sabah 8'de hastane randevum var')",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Asistana söyle...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : AppColors.primaryBlue,
              ),
              onPressed: _listen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: viewModel.isLoading
              ? null
              : () {
                  if (_textController.text.trim().isNotEmpty) {
                    viewModel.analyzeText(_textController.text);
                  }
                },
          child: const Text("Gönder"),
        ),
      ],
    );
  }
}
