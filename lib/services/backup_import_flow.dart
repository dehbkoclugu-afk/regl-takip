import 'encrypted_backup_codec.dart'
    show
        EncryptedBackupException,
        validateBackupPassword,
        BackupPasswordValidation;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';
import 'backup_service.dart';
import 'hive_service.dart';

Future<BackupData?> pickBackupForRestore(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['rtbackup', 'json'],
  );
  final path = result?.files.single.path;
  if (path == null) return null;

  final BackupData data;
  var isLegacyBackup = false;
  try {
    final backupService = BackupService(HiveService());
    var source = await backupService.readBackupFile(path);
    final isEncrypted =
        path.toLowerCase().endsWith('.rtbackup') ||
        backupService.isEncryptedBackup(source);
    if (isEncrypted) {
      if (!context.mounted) return null;
      final password = await requestBackupPassword(
        context,
        l10n,
        confirmPassword: false,
      );
      if (password == null || !context.mounted) return null;
      source = await withBackupProgress(
        context,
        l10n.unlockBackupTitle,
        () => backupService.decryptBackup(source, password),
      );
    } else {
      isLegacyBackup = true;
    }
    data = backupService.parseBackup(source);
  } on EncryptedBackupException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupPasswordOrFileInvalid),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return null;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidBackupFile),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return null;
  }

  if (!context.mounted) return null;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(l10n.restoreConfirmTitle),
      content: Text(
        [
          l10n.restoreConfirmBody(data.totalRecordCount),
          if (isLegacyBackup) l10n.legacyBackupWarning,
        ].join('\n\n'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.restore),
        ),
      ],
    ),
  );
  if (confirmed != true) return null;
  return data;
}

Future<String?> requestBackupPassword(
  BuildContext context,
  AppLocalizations l10n, {
  required bool confirmPassword,
}) async {
  final passwordController = TextEditingController();
  final confirmationController = TextEditingController();
  var obscurePassword = true;
  String? errorText;

  try {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          void submit() {
            final password = passwordController.text;
            final confirmation = confirmationController.text;
            final validation = validateBackupPassword(
              password,
              confirmation: confirmPassword ? confirmation : null,
            );
            final error = switch (validation) {
              BackupPasswordValidation.valid => null,
              BackupPasswordValidation.invalidLength =>
                l10n.backupPasswordLength,
              BackupPasswordValidation.mismatch =>
                l10n.backupPasswordsDoNotMatch,
            };
            if (error != null) {
              setSheetState(() => errorText = error);
              return;
            }
            Navigator.pop(sheetContext, password);
          }

          final visibilityLabel = obscurePassword
              ? l10n.showPassword
              : l10n.hidePassword;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    confirmPassword ? l10n.backupData : l10n.unlockBackupTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    confirmPassword
                        ? l10n.backupNoRecovery
                        : l10n.unlockBackupBody,
                    style: TextStyle(
                      height: 1.4,
                      color: confirmPassword
                          ? AppColors.warningText
                          : AppColors.ts(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    autofocus: true,
                    obscureText: obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: confirmPassword
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onSubmitted: confirmPassword ? null : (_) => submit(),
                    decoration: InputDecoration(
                      labelText: l10n.backupPassword,
                      errorText: errorText,
                      suffixIcon: IconButton(
                        tooltip: visibilityLabel,
                        onPressed: () => setSheetState(
                          () => obscurePassword = !obscurePassword,
                        ),
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                  ),
                  if (confirmPassword) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmationController,
                      obscureText: obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: l10n.backupPasswordConfirm,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: submit,
                        child: Text(l10n.continueBtn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  } finally {
    passwordController.dispose();
    confirmationController.dispose();
  }
}

Future<T> withBackupProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() operation,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    ),
  );
  try {
    return await operation();
  } finally {
    if (navigator.canPop()) navigator.pop();
  }
}
