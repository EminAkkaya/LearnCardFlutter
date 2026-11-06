import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reader_settings_provider.dart';
import '../../providers/reading_provider.dart';
import 'dialogs/new_text_dialog.dart';
import 'dialogs/save_article_dialog.dart';
import 'dialogs/saved_articles_sheet.dart';
import 'widgets/reader_app_bar_title.dart';
import 'widgets/reader_bottom_bar.dart';
import 'widgets/reader_content_view.dart';
import 'widgets/reader_focus_mode_header.dart';
import 'widgets/reader_legend_bar.dart';
import 'widgets/theme_selector_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: ref.read(readingProvider).currentText,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReadingState>(readingProvider, (previous, next) {
      if (previous?.currentText != next.currentText &&
          _textController.text != next.currentText) {
        _textController.text = next.currentText;
      }
    });

    final readingState = ref.watch(readingProvider);
    final isFocusMode = readingState.isFocusMode;
    final settings = ref.watch(readerSettingsProvider);
    final themeColors = settings.colors;

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: isFocusMode
          ? null
          : AppBar(
              backgroundColor: themeColors.surface,
              foregroundColor: themeColors.defaultText,
              elevation: 0,
              centerTitle: true,
              title: ReaderAppBarTitle(
                readingState: readingState,
                themeColors: themeColors,
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (isFocusMode) ReaderFocusModeHeader(themeColors: themeColors),
            if (!isFocusMode) ReaderLegendBar(colors: themeColors),
            Expanded(
              child: ReaderContentView(
                textController: _textController,
                scrollController: _scrollController,
                colors: themeColors,
                isFocusMode: isFocusMode,
                settings: settings,
              ),
            ),
            if (!isFocusMode)
              ReaderBottomBar(
                colors: themeColors,
                onNewTextTap: () =>
                    NewTextDialog.show(context, ref, _textController.text),
                onSavedTap: () => SavedArticlesSheet.show(context),
                onThemeTap: () => ThemeSelectorSheet.show(context, themeColors),
                onSaveTap: () =>
                    SaveArticleDialog.show(context, ref, _textController.text),
                onFocusTap: () =>
                    ref.read(readingProvider.notifier).toggleFocusMode(),
              ),
          ],
        ),
      ),
    );
  }
}
