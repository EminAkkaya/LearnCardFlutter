import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reading_article_model.dart';
import 'create_folder_dialog.dart';
import 'edit_article_dialog.dart';
import 'new_text_dialog.dart';
import 'save_article_dialog.dart';
import 'saved_articles_sheet.dart';

class ReaderDialogs {
  static void showCreateFolderDialog(
    BuildContext parentContext,
    WidgetRef ref, {
    ValueChanged<String>? onCreated,
  }) {
    CreateFolderDialog.show(parentContext, ref, onCreated: onCreated);
  }

  static void showSaveArticleDialog(
    BuildContext context,
    WidgetRef ref,
    String currentText,
  ) {
    SaveArticleDialog.show(context, ref, currentText);
  }

  static void showEditArticleDialog(
    BuildContext parentContext,
    WidgetRef ref,
    ReadingArticleModel article,
  ) {
    EditArticleDialog.show(parentContext, ref, article);
  }

  static void showSavedArticlesSheet(BuildContext context, WidgetRef ref) {
    SavedArticlesSheet.show(context);
  }

  static void showNewTextDialog(
    BuildContext context,
    WidgetRef ref,
    String currentText,
  ) {
    NewTextDialog.show(context, ref, currentText);
  }
}
