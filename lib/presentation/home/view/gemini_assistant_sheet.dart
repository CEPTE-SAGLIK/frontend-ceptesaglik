import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/home/viewmodel/gemini_viewmodel.dart';
import 'package:health_asistants/presentation/home/viewmodel/home_viewmodel.dart';
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
        onError: (val) => print('onError: $val'),
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
    switch (viewModel.status) {
      case GeminiStatus.analyzing:
      case GeminiStatus.saving:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Yapay zeka analiz ediyor... 🪄",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );

      case GeminiStatus.success:
        return _buildResults(context, viewModel);

      case GeminiStatus.error:
        return Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? "Bilinmeyen bir hata oluştu.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.reset(),
              child: const Text("Tekrar Dene"),
            )
          ],
        );

      case GeminiStatus.saved:
      case GeminiStatus.initial:
      default:
        return _buildInput(viewModel);
    }
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
          onPressed: () {
            if (_textController.text.trim().isNotEmpty) {
              viewModel.analyzeText(_textController.text);
            }
          },
          child: const Text("Analiz Et"),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, GeminiViewModel viewModel) {
    final data = viewModel.analysisResponse;
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Asistanımız şunları tespit etti:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // İlaçlar
        const Text("💊 İlaçlar:", style: TextStyle(fontWeight: FontWeight.bold)),
        if (data.medicines.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 4.0),
            child: Text("Bulunamadı.", style: TextStyle(color: Colors.grey)),
          )
        else
          ...data.medicines.map((m) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Text("• ${m.name} (${m.timesPerDay} kez, ${m.usageInstructions ?? ''})"),
              )),
        
        const SizedBox(height: 16),

        // Hatırlatıcılar
        const Text("📅 Hatırlatıcılar:", style: TextStyle(fontWeight: FontWeight.bold)),
        if (data.reminders.isEmpty)
           const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 4.0),
            child: Text("Bulunamadı.", style: TextStyle(color: Colors.grey)),
          )
        else
          ...data.reminders.map((r) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Text("• ${r.title} (${r.dateTime.toLocal()})"),
              )),

        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
             // Kişi Id'si alımı - Şimdilik HomeViewModel üzerinden veya varsayılan kullanılabilir
             final personId = context.read<HomeViewModel>().currentPerson?.id ?? 'default';
             final success = await viewModel.saveParsedResults(personId);
             
             if (success && context.mounted) {
               viewModel.reset();
               context.read<HomeViewModel>().loadHomeData();
               Navigator.pop(context); // Kapat
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Kayıtlar başarıyla eklendi! ✨'))
               );
             }
          },
          child: const Text("Kaydet ve Paneli Kapat"),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => viewModel.reset(),
          style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          child: const Text("Vazgeç"),
        )
      ],
    );
  }
}
