import 'package:flutter/material.dart';
import '../services/tts_service.dart';

/// Reusable TTS Icon Button Widget
/// Displays a speaker icon that reads text aloud when tapped
class TtsIconButton extends StatefulWidget {
  final String text;
  final Color? iconColor;
  final double iconSize;
  final String? tooltip;

  const TtsIconButton({
    super.key,
    required this.text,
    this.iconColor,
    this.iconSize = 20,
    this.tooltip,
  });

  @override
  State<TtsIconButton> createState() => _TtsIconButtonState();
}

class _TtsIconButtonState extends State<TtsIconButton>
    with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService.instance;
  bool _isSpeaking = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    debugPrint('🎤 TTS Button Tapped - Text: "${widget.text}"');

    if (_isSpeaking) {
      // Stop speaking
      debugPrint('⏹️ Stopping TTS');
      await _ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
      _animationController.stop();
      _animationController.reset();
    } else {
      // Start speaking
      debugPrint('▶️ Starting TTS');
      setState(() {
        _isSpeaking = true;
      });
      _animationController.repeat();

      try {
        await _ttsService.speak(widget.text);
        debugPrint('✅ TTS Speak command sent');
      } catch (e) {
        debugPrint('❌ TTS Button Error: $e');
      }

      // Auto-stop animation after a delay (web doesn't have completion callback)
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        _animationController.stop();
        _animationController.reset();
        debugPrint('🔄 TTS Animation stopped');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? 'Tap to listen',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale:
                  _isSpeaking ? 1.0 + (_animationController.value * 0.2) : 1.0,
              child: Icon(
                _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                size: widget.iconSize,
                color:
                    _isSpeaking
                        ? const Color(0xFF00C853)
                        : (widget.iconColor ?? Colors.grey[600]),
              ),
            );
          },
        ),
      ),
    );
  }
}
