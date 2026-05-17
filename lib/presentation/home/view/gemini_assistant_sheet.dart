import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/presentation/home/viewmodel/gemini_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GeminiAssistantSheet extends StatefulWidget {
  final bool showCloseButton;
  final bool isBottomSheet;

  const GeminiAssistantSheet({
    super.key,
    this.showCloseButton = true,
    this.isBottomSheet = true,
  });

  @override
  State<GeminiAssistantSheet> createState() => _GeminiAssistantSheetState();
}

class _GeminiAssistantSheetState extends State<GeminiAssistantSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
          SnackbarHelper.showError(context, 'Mikrofon izni verilmedi veya cihaz desteklemiyor!');
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(GeminiViewModel viewModel) async {
    final text = _textController.text.trim();
    if (text.isEmpty || viewModel.isLoading) return;

    _textController.clear();
    await viewModel.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeminiViewModel>(
      builder: (context, viewModel, child) {
        final chatContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "🪄 Yapay Zeka Asistanı",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.showCloseButton)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _buildMessages(viewModel),
            ),
            const SizedBox(height: 8),
            _buildInput(viewModel),
          ],
        );

        if (!widget.isBottomSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: chatContent,
            ),
          );
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: chatContent,
          ),
        );
      },
    );
  }

  Widget _buildMessages(GeminiViewModel viewModel) {
    final messages = viewModel.messages;
    final hasMessages = messages.isNotEmpty;
    final itemCount = hasMessages
        ? messages.length + (viewModel.isLoading ? 1 : 0)
        : 1;

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (!hasMessages) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                "Mesajını yaz, birlikte planlayalım.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        if (viewModel.isLoading && index == messages.length) {
          return const _TypingBubble();
        }

        final message = messages[index];
        return Align(
          alignment:
              message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: message.isUser
                  ? AppColors.primaryBlue
                  : (message.isError ? Colors.red.shade50 : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(14),
              border: message.isError
                  ? Border.all(color: Colors.red.shade300)
                  : null,
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      },
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
          minLines: 1,
          maxLines: 4,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendMessage(viewModel),
          decoration: InputDecoration(
            hintText: "Mesajını yaz...",
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
              : () => _sendMessage(viewModel),
          child: const Text("Gönder"),
        ),
      ],
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text("Yazıyor..."),
          ],
        ),
      ),
    );
  }
}
