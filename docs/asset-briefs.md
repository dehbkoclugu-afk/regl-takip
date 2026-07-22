# Regl Takip — Art Direction & Asset Generation Briefs

Hand this document to your image-generation AI (Midjourney, DALL·E, Imagen,
Firefly…) **one asset at a time**. Always paste the MASTER STYLE PROMPT first,
then the asset's own prompt. Deliver files with the exact filenames below into
`assets/art/`, then add the matching line to `lib/core/art/art_registry.dart`
(one line per asset). Every slot in the app is already laid out and waiting —
until a file exists it renders a labeled placeholder.

---

## MASTER STYLE PROMPT (paste before every asset prompt)

> **Style: "Bloom" — soft botanical pastel illustration for a women's cycle app.**
> Painterly digital gouache with a gentle brush grain and faint paper texture;
> NOT flat vector, NOT 3D render, NOT photograph. Color world: soft rose
> `#E8A0BF`, deep rose `#D4789E`, warm peach `#FFCBA4`, gentle amber `#FFD9A0`,
> lilac `#BA90C6`, powder blue `#C0DBEA`, mint `#A8D5BA`, on a warm ivory ground
> `#FDF2F8`. Light is soft and diffuse like early morning — never harsh. Motifs:
> blooming flowers, petals, leaves, moon phases, gentle water drops, flowing
> organic curves and rounded blob shapes. Mood: calm, warm, feminine, reassuring,
> tender; lots of soft negative space so ivory text stays legible. Human figures,
> when present, are faceless and simplified — seen from behind or in silhouette,
> dignified, never photorealistic. No text, no letters, no watermark, no logos
> inside the artwork.
>
> **Dark-mode variants** (only where noted "· dark"): swap the ivory ground for
> deep plum `#1A1020` / `#251A30`, keep the same pastel accents glowing softly
> against it; values kept dark-to-mid.
>
> **Negative prompt:** text, watermark, signature, photorealism, 3D render,
> plastic sheen, neon colors, harsh saturation, medical/clinical look, blood,
> anatomical diagrams, cluttered composition, cartoon outlines, anime, emoji
> style, stock-photo look, extra limbs, distorted anatomy.

**Consistency controls (use if the tool supports them):**
- Midjourney: append `--ar <given> --style raw --stylize 200 --chaos 5`; generate
  all assets in one session, reuse the first accepted image as `--sref` for the rest.
- DALL·E/Imagen: keep the master prompt verbatim; regenerate until the palette
  matches the hexes; ask for "same illustration style as previous" within one chat.
- Export PNG (transparent where noted), at least the pixel size given.

---

## R1 — Logomark · `R1-logomark.png` · 512×512 · transparent PNG
**Placement:** app-wide brand mark, readable at 24 px.
> Minimal feminine logomark: a crescent moon and a single soft flower petal
> merging into one continuous elegant line, soft rose `#E8A0BF` to deep rose
> `#D4789E` gradient, faint outer glow, balanced inside a circle. Flat emblem,
> no scene, transparent background. --ar 1:1

## R2 — Splash · `R2-splash.png` · 1080×1920
**Placement:** launch screen background.
> Vertical calm scene: soft ivory-to-rose gradient sky with a large pale moon,
> a few drifting petals and tiny stars, a low soft botanical silhouette along the
> bottom. Centered empty space for the logo. Serene, minimal. --ar 9:16

## R3 — Welcome hero · `R3-welcome-hero.png` · 1170×1000
**Placement:** onboarding welcome page hero, ~220pt tall, rounded 28.
> Warm hero: a simplified woman seen from behind sitting calmly among oversized
> soft blooming flowers and leaves at gentle morning light, pastel rose/peach/
> lilac palette, powder-blue sky with a faint crescent moon, generous calm
> negative space at the top. Tender and reassuring. --ar 1.17:1

## R4 — Onboarding · tracking · `R4-onb-tracking.png` · 1170×1000
**Placement:** onboarding "how tracking works" page hero.
> Soft flat-lay from above: a rounded calendar shape made of petals, a moon-phase
> row, a water drop and a small leaf, arranged in a gentle circular flow on ivory,
> pastel palette, airy spacing. Symbolic, not literal UI. --ar 1.17:1

## R5 — Onboarding · privacy · `R5-onb-privacy.png` · 1170×1000
**Placement:** onboarding privacy/consent page hero.
> A cupped pair of hands gently holding a glowing soft flower bud, warm protective
> mood, pastel rose and mint, ivory ground, soft light, lots of negative space.
> Conveys safety and privacy without a padlock cliché. --ar 1.17:1

## R6 — Phase · menstrual · `R6-phase-menstrual.png` · 800×800
**Placement:** dashboard phase art (menstrual), behind/near the cycle ring.
> Abstract soft composition for the menstrual phase: a resting waning moon over
> calm deep-rose `#D4789E` and rose `#E8A0BF` flowing blob layers, a single
> drooping soft flower, restful and gentle. Square, calm negative space. --ar 1:1

## R7 — Phase · follicular · `R7-phase-follicular.png` · 800×800
**Placement:** dashboard phase art (follicular).
> Abstract soft composition for the follicular phase: fresh green shoots and small
> buds opening, warm peach `#FFCBA4` sunrise glow, waxing crescent moon, hopeful
> rising energy. Square. --ar 1:1

## R8 — Phase · ovulation · `R8-phase-ovulation.png` · 800×800
**Placement:** dashboard phase art (ovulation).
> Abstract soft composition for the ovulation phase: a full flower in peak bloom
> radiating a soft lilac `#BA90C6` glow like a full moon, mint `#A8D5BA` fertile
> accents, luminous and vibrant yet calm. Square. --ar 1:1

## R9 — Phase · luteal · `R9-phase-luteal.png` · 800×800
**Placement:** dashboard phase art (luteal).
> Abstract soft composition for the luteal phase: warm amber `#FFD9A0` dusk light,
> a gently closing flower and falling petals, waning gibbous moon, cozy winding-
> down mood. Square. --ar 1:1

## R10 — Empty · notes · `R10-empty-notes.png` · 600×500 · transparent
**Placement:** notes screen empty state.
> Small spot illustration: an open soft journal with a flower growing from its
> pages and a floating pen, pastel rose/lilac, transparent background, airy.
> Inviting, light. --ar 6:5

## R11 — Empty · calendar · `R11-empty-calendar.png` · 600×500 · transparent
**Placement:** calendar/log screen empty state.
> Small spot illustration: a rounded calendar page with a single blooming flower
> marking a day and tiny moon icons, pastel palette, transparent background. --ar 6:5

## R12 — Empty · statistics · `R12-empty-statistics.png` · 600×500 · transparent
**Placement:** statistics screen empty state.
> Small spot illustration: soft pastel bar/curve shapes growing like flower stems
> with petals at their tips, gentle and playful, transparent background. --ar 6:5

## R13 — Mood spot · `R13-mood-spot.png` · 400×400 · transparent
**Placement:** mood tracking header accent.
> Tiny spot: a cluster of soft rounded faces-as-flowers showing calm expressions
> in the mood pastel hues, transparent background, light and friendly. --ar 1:1

## R14 — Symptoms spot · `R14-symptoms-spot.png` · 400×400 · transparent
**Placement:** symptom tracking header accent.
> Tiny spot: a gentle body silhouette wrapped in soft leaves and petals with a few
> glowing warm points, caring and non-clinical, transparent background. --ar 1:1

## R15 — Prediction hero · `R15-prediction-hero.png` · 1000×600
**Placement:** dashboard prediction card background (text overlaid).
> Wide soft banner: a horizon of flowing pastel waves and a moon-phase arc from
> new to full across the top, warm rose-to-lilac gradient, calm, most of the
> lower area kept simple for overlaid text. --ar 5:3

## R16 — Profile header · `R16-profile-header.png` · 1170×600
**Placement:** profile/settings header background.
> Wide gentle botanical banner: scattered soft flowers and leaves along a warm
> ivory-to-rose gradient, symmetrical calm composition, space in the middle for
> an avatar. --ar 1.95:1

## R17 — Paywall hero · `R17-paywall-hero.png` · 1170×1000
**Placement:** future premium paywall hero.
> Aspirational warm hero: a radiant oversized bloom opening toward soft golden-
> amber light, lilac and rose petals, a full moon halo, generous glow and calm
> negative space. Feels like a gift, premium and warm. --ar 1.17:1

## R18 — Share card · `R18-share-card.png` · 1080×1080
**Placement:** shareable cycle summary background (text overlaid).
> Square soft social card: a centered moon-and-flower emblem on a warm pastel
> gradient with a subtle petal border, plenty of clean space for overlaid stats
> text. Pretty and shareable. --ar 1:1
