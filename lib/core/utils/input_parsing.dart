/// Kullanıcı girdisini sayıya çeviren yardımcılar.
class InputParsing {
  InputParsing._();

  static const double minWeightKg = 20;
  static const double maxWeightKg = 300;

  /// Kilo girdisi. Türkçe klavyede ondalık ayırıcı virgüldür ("60,5");
  /// `double.tryParse` bunu null döndürür ve girdi sessizce yok sayılırdı.
  /// Aralık dışı ya da anlamsız girdilerde null döner (çağıran uyarır).
  static double? weightKg(String raw) {
    final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (parsed == null || parsed.isNaN) return null;
    if (parsed < minWeightKg || parsed > maxWeightKg) return null;
    return double.parse(parsed.toStringAsFixed(1));
  }
}
