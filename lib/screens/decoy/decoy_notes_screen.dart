import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tam kılık: gizli modda uygulama "Notlar" olarak açılır ve bu ekran
/// GERÇEKTEN çalışan basit bir not defteridir — telefonu eline alan biri
/// kurcalasa da regl uygulaması görmez. Gerçek uygulamaya dönüş: başlığa
/// uzun basış (ayarlardaki gizli mod açıklamasında yazar), altta kilit
/// açıksa PIN sorulur.
///
/// Bilinçli sadelik: notlar şifresiz SharedPreferences'ta tutulur —
/// bunlar kullanıcının sağlık verisi değil, kılığın sahne dekorudur
/// (ama gerçek not olarak da işe yarar).
class DecoyNotesScreen extends StatefulWidget {
  final VoidCallback onExitRequested;

  const DecoyNotesScreen({super.key, required this.onExitRequested});

  @override
  State<DecoyNotesScreen> createState() => _DecoyNotesScreenState();
}

class _DecoyNotesScreenState extends State<DecoyNotesScreen> {
  static const _prefsKey = 'decoy_notes';
  List<String> _notes = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notes = prefs.getStringList(_prefsKey) ?? [];
      _loaded = true;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _notes);
  }

  Future<void> _editNote({int? index}) async {
    final l10n = AppLocalizations.of(context)!;
    final controller =
        TextEditingController(text: index != null ? _notes[index] : '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.decoyTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 6,
          minLines: 3,
          decoration: InputDecoration(hintText: l10n.decoyHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;
    setState(() {
      if (index != null) {
        _notes[index] = result;
      } else {
        _notes.insert(0, result);
      }
    });
    await _persist();
  }

  Future<void> _deleteNote(int index) async {
    setState(() => _notes.removeAt(index));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Nötr kimlik: marka pembesi YOK — sıradan bir not uygulaması gibi
    // görünmeli. Kendi küçük teması, uygulama temasından bağımsız.
    final decoyTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF546E7A)),
    );

    return Theme(
      data: decoyTheme,
      child: Scaffold(
        appBar: AppBar(
          // Gerçek uygulamaya dönüş kapısı: başlığa uzun basış.
          // Görsel hiçbir ipucu yok — kapı yalnız bilene açılır.
          title: GestureDetector(
            onLongPress: widget.onExitRequested,
            behavior: HitTestBehavior.opaque,
            child: Text(l10n.decoyTitle),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _editNote(),
          child: const Icon(Icons.add),
        ),
        body: !_loaded
            ? const SizedBox.shrink()
            : _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sticky_note_2_outlined,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(l10n.decoyEmpty,
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => Dismissible(
                      key: ValueKey('decoy-$index-${_notes[index].hashCode}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteNote(index),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Material(
                        color: decoyTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _editNote(index: index),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              _notes[index],
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
