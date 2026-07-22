/// Art asset registry — the single connection point for finished artwork.
///
/// Every visual slot in the app is declared in [artSpecs] and rendered through
/// an [ArtSlot]. A slot shows an elegant labeled placeholder until its id is
/// added to [artRegistry] below AND the matching PNG exists in `assets/art/`.
///
/// To ship a finished asset:
///   1. Generate it from the brief in `docs/asset-briefs.md`.
///   2. Drop the PNG into `assets/art/` with the exact filename.
///   3. Uncomment (or add) its one line in [artRegistry].
/// The placeholder turns into real art automatically — no layout changes.
library;

class ArtSpec {
  /// Human label shown on the placeholder.
  final String label;

  /// Target pixel size, e.g. "1170x1000". Documentation only.
  final String size;

  const ArtSpec(this.label, this.size);
}

/// Declared slots. Keep ids in sync with `docs/asset-briefs.md`.
const Map<String, ArtSpec> artSpecs = {
  'R1-logomark': ArtSpec('Logomark', '512x512'),
  'R2-splash': ArtSpec('Splash', '1080x1920'),
  'R3-welcome-hero': ArtSpec('Welcome hero', '1170x1000'),
  'R4-onb-tracking': ArtSpec('Onboarding · tracking', '1170x1000'),
  'R5-onb-privacy': ArtSpec('Onboarding · privacy', '1170x1000'),
  'R6-phase-menstrual': ArtSpec('Phase · menstrual', '800x800'),
  'R7-phase-follicular': ArtSpec('Phase · follicular', '800x800'),
  'R8-phase-ovulation': ArtSpec('Phase · ovulation', '800x800'),
  'R9-phase-luteal': ArtSpec('Phase · luteal', '800x800'),
  'R10-empty-notes': ArtSpec('Empty · notes', '600x500'),
  'R11-empty-calendar': ArtSpec('Empty · calendar', '600x500'),
  'R12-empty-statistics': ArtSpec('Empty · statistics', '600x500'),
  'R13-mood-spot': ArtSpec('Mood spot', '400x400'),
  'R14-symptoms-spot': ArtSpec('Symptoms spot', '400x400'),
  'R15-prediction-hero': ArtSpec('Prediction hero', '1000x600'),
  'R16-profile-header': ArtSpec('Profile header', '1170x600'),
  'R17-paywall-hero': ArtSpec('Paywall hero', '1170x1000'),
  'R18-share-card': ArtSpec('Share card', '1080x1080'),
};

/// Finished art. id -> asset path. Add a line here once the PNG is in place.
/// Empty on purpose: every slot renders a placeholder until you fill it in.
const Map<String, String> artRegistry = {
  // 'R1-logomark': 'assets/art/R1-logomark.png',
  // 'R3-welcome-hero': 'assets/art/R3-welcome-hero.png',
};
