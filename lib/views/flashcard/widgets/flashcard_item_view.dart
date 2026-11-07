import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/flashcard_model.dart';
import '../../../services/srs_service.dart';
import 'flashcard_back_view.dart';
import 'flashcard_front_view.dart';
import 'fill_or_scroll.dart';

class FlashcardItemView extends StatefulWidget {
  final FlashcardModel card;
  final Map<ReviewRating, String> previews;
  final void Function(ReviewRating rating) onRating;

  const FlashcardItemView({
    super.key,
    required this.card,
    required this.previews,
    required this.onRating,
  });

  @override
  State<FlashcardItemView> createState() => _FlashcardItemViewState();
}

class _FlashcardItemViewState extends State<FlashcardItemView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: AppPalette.motionSlow,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final card = widget.card;

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final double angle = _flipAnimation.value * pi;
          final isBackVisible = angle >= pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            // Opak kart: 1px kenarlık + açık temada hafif gölge; gradient yok.
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: palette.cardDecoration(),
              child: FillOrScroll(
                child: isBackVisible
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: FlashcardBackView(
                          card: card,
                          previews: widget.previews,
                          onRating: widget.onRating,
                        ),
                      )
                    : FlashcardFrontView(card: card),
              ),
            ),
          );
        },
      ),
    );
  }
}
