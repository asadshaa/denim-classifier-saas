import 'package:flutter/material.dart';

/// Complete taxonomy for the DenimAI EfficientNetB0 multi-head model.
///
/// Model specs:
///   • Architecture : EfficientNetB0 fine-tuned
///   • Input        : (1, 224, 224, 3)  — normalized [0, 1]
///   • Output 0     : (1, 21)  — main class probabilities
///   • Output 1     : (1,  5)  — subclass probabilities
///   • Val Accuracy : 98.73% main / 98.77% sub
class FabricTaxonomy {
  // ── 21 Main Classes — must match model output index exactly ─────────────────
  // Source: classification_report target_names (alphabetically sorted folders)
  static const List<String> mainClasses = [
    '138-CG',      // 0
    '1553-EL',     // 1
    '1583-EM',     // 2
    '1600-JK',     // 3
    '1780-A',      // 4
    '1830-BE',     // 5
    '1830-BZ',     // 6
    '1952-BC',     // 7
    '1965-G',      // 8
    '1976-W',      // 9
    '2034-A',      // 10
    '2051',        // 11
    'P140394I',    // 12
    'P140406BB',   // 13
    'P140541',     // 14
    'P140676',     // 15
    'P140813',     // 16
    'P140858',     // 17
    'P140901',     // 18
    'PRP180CA',    // 19
    'PRT0235AY',   // 20
  ];

  // ── 5 Subclass Labels — folder indices 0–4 ────────────────────────────────
  static const List<String> subclassLabels = [
    'Cut A',   // 0
    'Cut B',   // 1
    'Cut C',   // 2
    'Cut D',   // 3
    'Cut E',   // 4
  ];

  // ── Human-readable descriptions ───────────────────────────────────────────
  static const Map<String, String> descriptions = {
    '138-CG':    'Classic grey denim with comfort stretch weave',
    '1553-EL':   'Medium weight denim with vintage stonewash finish',
    '1583-EM':   'Enzyme-washed medium denim, relaxed texture',
    '1600-JK':   'Jacquard weave denim, structured silhouette fabric',
    '1780-A':    'Lightweight denim with natural drape and soft hand',
    '1830-BE':   'Broken-edge selvedge denim, raw finishing',
    '1830-BZ':   'Brazilian-cut lightweight denim, slim silhouette',
    '1952-BC':   'British-classic heavyweight twill, durable construction',
    '1965-G':    'Garment-dyed denim, irregular tonal depth',
    '1976-W':    'Raw unwashed selvedge denim, rigid construction',
    '2034-A':    'Advanced stretch denim, athletic performance weave',
    '2051':      'Premium doubled-yarn denim, high density weave',
    'P140394I':  'Indigo cross-hatch denim, Japanese heritage style',
    'P140406BB': 'Bark-blue heavy weight denim, classic indigo finish',
    'P140541':   'Saturation-dyed denim, deep pigment penetration',
    'P140676':   'Gradient washed denim, ombré tonal effect',
    'P140813':   'Micro-sand blasted denim, premium surface texture',
    'P140858':   'Reactive-dyed denim, high-contrast colour clarity',
    'P140901':   'One-sided twill denim, diagonal weave pattern',
    'PRP180CA':  'Canadian-refined polycore-reinforced denim blend',
    'PRT0235AY': 'Athletic-fit comfort stretch denim, performance grade',
  };

  // ── Fabric characteristics (weight, stretch, finish) ─────────────────────
  static const Map<String, String> characteristics = {
    '138-CG':    'Weight: 10oz • Stretch: Medium • Finish: Grey wash',
    '1553-EL':   'Weight: 12oz • Stretch: Minimal • Finish: Stonewashed',
    '1583-EM':   'Weight: 11oz • Stretch: Low • Finish: Enzyme wash',
    '1600-JK':   'Weight: 13oz • Stretch: None • Finish: Structured',
    '1780-A':    'Weight: 8oz • Stretch: Medium • Finish: Soft rinse',
    '1830-BE':   'Weight: 14oz • Stretch: None • Finish: Raw edge',
    '1830-BZ':   'Weight: 9oz • Stretch: High • Finish: Soft rinse',
    '1952-BC':   'Weight: 15oz • Stretch: None • Finish: Twill',
    '1965-G':    'Weight: 11oz • Stretch: Low • Finish: Garment dyed',
    '1976-W':    'Weight: 14oz • Stretch: None • Finish: Raw/unwashed',
    '2034-A':    'Weight: 10oz • Stretch: Very High • Finish: Clean wash',
    '2051':      'Weight: 16oz • Stretch: None • Finish: Dense weave',
    'P140394I':  'Weight: 12oz • Stretch: Low • Finish: Indigo dyed',
    'P140406BB': 'Weight: 13oz • Stretch: Low • Finish: Dark indigo',
    'P140541':   'Weight: 12oz • Stretch: Medium • Finish: Saturation dyed',
    'P140676':   'Weight: 11oz • Stretch: Medium • Finish: Gradient wash',
    'P140813':   'Weight: 12oz • Stretch: Low • Finish: Sand blasted',
    'P140858':   'Weight: 11oz • Stretch: Medium • Finish: Reactive dyed',
    'P140901':   'Weight: 13oz • Stretch: None • Finish: One-side twill',
    'PRP180CA':  'Weight: 11oz • Stretch: High • Finish: Polycore blend',
    'PRT0235AY': 'Weight: 10oz • Stretch: Medium • Finish: Clean wash',
  };

  // ── Model performance per class (from classification report) ─────────────
  static const Map<String, double> modelF1 = {
    '138-CG':    1.00, '1553-EL':  1.00, '1583-EM':  0.97,
    '1600-JK':   0.99, '1780-A':   1.00, '1830-BE':  1.00,
    '1830-BZ':   1.00, '1952-BC':  0.98, '1965-G':   1.00,
    '1976-W':    1.00, '2034-A':   1.00, '2051':     0.93,
    'P140394I':  0.97, 'P140406BB':0.99, 'P140541':  0.99,
    'P140676':   1.00, 'P140813':  1.00, 'P140858':  0.95,
    'P140901':   0.97, 'PRP180CA': 0.97, 'PRT0235AY':1.00,
  };

  // ── Colour palette (Textile Indigo spectrum — 21 distinct hues) ──────────
  static const List<Color> classColors = [
    Color(0xFF6366F1), // 0  138-CG      Indigo
    Color(0xFF8B5CF6), // 1  1553-EL     Violet
    Color(0xFF06B6D4), // 2  1583-EM     Cyan
    Color(0xFF10B981), // 3  1600-JK     Emerald
    Color(0xFFF59E0B), // 4  1780-A      Amber
    Color(0xFFEF4444), // 5  1830-BE     Red
    Color(0xFF3B82F6), // 6  1830-BZ     Blue
    Color(0xFFF97316), // 7  1952-BC     Orange
    Color(0xFF84CC16), // 8  1965-G      Lime
    Color(0xFFEC4899), // 9  1976-W      Pink
    Color(0xFF14B8A6), // 10 2034-A      Teal
    Color(0xFFA855F7), // 11 2051        Purple
    Color(0xFF22C55E), // 12 P140394I    Green
    Color(0xFFFBBF24), // 13 P140406BB   Yellow
    Color(0xFF60A5FA), // 14 P140541     Sky
    Color(0xFFF87171), // 15 P140676     Rose
    Color(0xFF34D399), // 16 P140813     Mint
    Color(0xFFC084FC), // 17 P140858     Lavender
    Color(0xFF38BDF8), // 18 P140901     Light Blue
    Color(0xFFD97706), // 19 PRP180CA    Dark Amber
    Color(0xFF4ADE80), // 20 PRT0235AY   Light Green
  ];

  // ── Public helpers ────────────────────────────────────────────────────────

  /// Color for a given class name.
  static Color colorFor(String className) {
    final idx = mainClasses.indexOf(className);
    if (idx == -1) return const Color(0xFF6366F1);
    return classColors[idx];
  }

  /// Short description.
  static String descriptionFor(String className) =>
      descriptions[className] ?? 'Premium denim fabric';

  /// Fabric characteristics string.
  static String characteristicsFor(String className) =>
      characteristics[className] ?? '';

  /// Model F1 score for this class (from training report).
  static double f1For(String className) => modelF1[className] ?? 0.99;

  /// Subclass readable label for index 0–4.
  static String subclassFor(int index) =>
      index >= 0 && index < subclassLabels.length
          ? subclassLabels[index]
          : 'Variant ${index + 1}';

  /// All 21 classes as a Set for fast lookup.
  static final Set<String> mainClassSet = Set.from(mainClasses);
}
