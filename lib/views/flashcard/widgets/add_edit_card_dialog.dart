import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/flashcard_model.dart';
import '../dialogs/add_edit_card_dialog.dart';

void showAddEditCardDialog(
  BuildContext context,
  WidgetRef ref, {
  FlashcardModel? cardToEdit,
}) {
  AddEditCardDialog.show(context, ref, cardToEdit: cardToEdit);
}
