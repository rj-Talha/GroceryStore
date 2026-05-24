import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/products.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../services/ai_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/product_placeholder.dart';

Future<void> showVoiceModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierColor: Daana.ink.withOpacity(0.45),
    barrierDismissible: true,
    barrierLabel: 'Voice order',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const VoiceModal(),
    transitionBuilder: (_, anim, __, child) {
      return FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );
}

class VoiceModal extends StatefulWidget {
  const VoiceModal({super.key});

  @override
  State<VoiceModal> createState() => _VoiceModalState();
}

class _VoiceModalState extends State<VoiceModal>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final _aiService = AIService();

  String _lang = 'ur';
  String _phase = 'init'; // init | listen | parsing | transcribed | items
  String _transcription = '';
  List<(Product, String)> _items = [];

  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        setState(() => _transcription = "Microphone permission denied.");
      }
      return;
    }

    final hasSpeech = await _speechToText.initialize(
      onError: (e) => print('Speech error: $e'),
      onStatus: (s) => print('Speech status: $s'),
    );

    if (hasSpeech && mounted) {
      _start();
    }
  }

  Future<void> _start() async {
    setState(() {
      _phase = 'listen';
      _transcription = '';
      _items = [];
    });

    final localeId = _lang == 'ur' ? 'ur_PK' : 'en_US';

    await _speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: true,
    );

    // Give it a short delay after listening stops before parsing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_speechToText.isNotListening &&
          _transcription.isNotEmpty &&
          mounted) {
        _processTranscription();
      } else if (mounted && _transcription.isEmpty) {
        setState(() => _phase = 'init');
      }
    });
  }

  Future<void> _stop() async {
    await _speechToText.stop();
    if (_transcription.isNotEmpty) {
      _processTranscription();
    } else {
      setState(() => _phase = 'init');
    }
  }

  Future<void> _processTranscription() async {
    setState(() => _phase = 'parsing');

    final catalog = Provider.of<CatalogProvider>(context, listen: false);
    final items = await _aiService.parseVoiceOrder(
      _transcription,
      catalog.allProducts,
    );

    if (mounted) {
      setState(() {
        _phase = 'transcribed';
        _items = items;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _phase = 'items');
      });
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Material(
          color: Daana.bg,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Eyebrow('Voice order · beta'),
                      _LangToggle(
                        value: _lang,
                        onChange: (v) {
                          _speechToText.cancel();
                          setState(() => _lang = v);
                          _start();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _phase == 'listen' ? _stop : _start,
                    child: Center(
                      child: _MicVisual(
                        listening: _phase == 'listen',
                        wave: _wave,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _phase == 'listen'
                          ? (_lang == 'ur'
                                ? 'سن رہا ہوں… (Tap to stop)'
                                : 'Listening… (Tap to stop)')
                          : _phase == 'parsing'
                          ? 'Parsing...'
                          : _phase == 'init'
                          ? 'Tap mic to start'
                          : 'Got it.',
                      style: _lang == 'ur' && _phase == 'listen'
                          ? Daana.urdu(size: 14, color: Daana.ink50)
                          : Daana.sans(size: 13, color: Daana.ink50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _TranscriptCard(
                    lang: _lang,
                    phase: _phase,
                    transcription: _transcription,
                  ),
                  if (_phase == 'items') ...[
                    const SizedBox(height: 14),
                    if (_items.isEmpty)
                      Center(
                        child: Text(
                          "Couldn't find any products.",
                          style: Daana.sans(size: 14, color: Daana.ink50),
                        ),
                      )
                    else
                      ..._items.map((it) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MatchedRow(product: it.$1, qty: it.$2),
                        );
                      }),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Btn(
                            'Keep listening',
                            variant: BtnVariant.quiet,
                            onPressed: _start,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Btn(
                            'Add ${_items.length} to cart',
                            iconRight: 'arrowR',
                            onPressed: _items.isEmpty
                                ? null
                                : () {
                                    final cart = context.read<CartProvider>();
                                    for (var item in _items) {
                                      cart.addItem(item.$1, 1);
                                    }
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${_items.length} items added to cart',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const _LangToggle({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    Widget pill(String id, String label) {
      final active = value == id;
      return GestureDetector(
        onTap: () => onChange(id),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Daana.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: id == 'ur' && !active
                ? Daana.urdu(size: 12, color: Daana.ink, height: 1.0)
                : id == 'ur' && active
                ? Daana.urdu(size: 12, color: Daana.bg, height: 1.0)
                : Daana.sans(size: 12, color: active ? Daana.bg : Daana.ink),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Daana.ink08,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pill('en', 'English'),
          const SizedBox(width: 2),
          pill('ur', 'اردو'),
        ],
      ),
    );
  }
}

class _MicVisual extends StatelessWidget {
  final bool listening;
  final AnimationController wave;
  const _MicVisual({required this.listening, required this.wave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (listening)
                AnimatedBuilder(
                  animation: wave,
                  builder: (_, __) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Daana.moss.withOpacity(0.18 + 0.06 * wave.value),
                      ),
                      transform: Matrix4.identity()
                        ..scale(1 + 0.06 * wave.value),
                    );
                  },
                ),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Daana.moss,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: DaanaIcon('mic', size: 28, color: Daana.bg),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: AnimatedBuilder(
            animation: wave,
            builder: (_, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(28, (i) {
                  final base = 4 + (math.sin(i * 0.7) + 1) * 12;
                  final factor = listening
                      ? (0.6 + 0.4 * math.sin(wave.value * 6.28 + i * 0.4))
                            .abs()
                      : 0.3;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Container(
                      width: 3,
                      height: base * factor + 2,
                      decoration: BoxDecoration(
                        color: Daana.moss.withOpacity(listening ? 0.85 : 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final String lang;
  final String phase;
  final String transcription;
  const _TranscriptCard({
    required this.lang,
    required this.phase,
    required this.transcription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Daana.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Daana.hairlineSoft),
      ),
      child: phase == 'init' || (phase == 'listen' && transcription.isEmpty)
          ? Text(
              lang == 'ur'
                  ? 'مثال کے طور پر کہیں: ایک کلو ٹماٹر اور دودھ'
                  : 'Try saying: "Add half kilo qeema and a dozen eggs"',
              style: lang == 'ur'
                  ? Daana.urdu(size: 16, color: Daana.ink30)
                  : Daana.sans(size: 14, color: Daana.ink30),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Heard', size: 9),
                const SizedBox(height: 8),
                if (lang == 'ur')
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      transcription,
                      style: Daana.urdu(
                        size: 22,
                        color: Daana.ink,
                        height: 1.6,
                      ),
                    ),
                  )
                else
                  Text(
                    transcription,
                    style: Daana.sans(size: 16, color: Daana.ink),
                  ),
              ],
            ),
    );
  }
}

class _MatchedRow extends StatelessWidget {
  final Product product;
  final String qty;
  const _MatchedRow({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Daana.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Daana.hairlineSoft),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: ProductPlaceholder(
              tone: product.tone,
              radius: 8,
              imageUrl: product.imageUrl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: Daana.sans(size: 14)),
                const SizedBox(height: 2),
                Text(
                  '$qty · ${product.unit}',
                  style: Daana.sans(size: 11.5, color: Daana.ink50),
                ),
              ],
            ),
          ),
          DaanaIcon('check', size: 16, color: Daana.moss),
        ],
      ),
    );
  }
}
