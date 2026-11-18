import 'package:flutter/material.dart';

/// SpendHunt Design System - "Night sands" Palette Specification
/// #CBBD93 - Warm Sand Beige (Dune sand / subtle golden taupe)
/// #FAE8B4 - Light Sand Cream (Soft butter / warm luminous sand)
/// #80775C - Warm Olive Sand Taupe (Mid-tone earthy taupe)
/// #574A24 - Deep Dark Bronze Olive (Primary dark brand tone)
class AppColors {
  // --- Exact Night Sands Brand Palette ---
  static const Color nightDeepOlive = Color(0xFF574A24); // #574A24
  static const Color nightTaupe = Color(0xFF80775C);     // #80775C
  static const Color nightWarmSand = Color(0xFFCBBD93);  // #CBBD93
  static const Color nightLightSand = Color(0xFFFAE8B4); // #FAE8B4

  // --- Primary Semantic Brand Aliases ---
  static const Color deepForest = Color(0xFF574A24); // Primary dark brand color (#574A24)
  static const Color sage = Color(0xFF80775C);       // Secondary earthy taupe (#80775C)
  static const Color warmBronze = Color(0xFFCBBD93); // Warm sand highlight (#CBBD93)
  static const Color goldenYellow = Color(0xFFFAE8B4); // Luminous sand cream (#FAE8B4)

  // Light Surfaces & Backgrounds (Harmonized with Night sands)
  static const Color backgroundLight = Color(0xFFF7F5EE); // Soft warm sand off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFF1EDE0); // Pale warm sand tint
  static const Color surfaceTertiaryLight = Color(0xFFE8E2D0);

  // Dark Surfaces & Backgrounds (Deep Night Sands theme)
  static const Color backgroundDark = Color(0xFF18150D); // Deep night sand
  static const Color surfaceDark = Color(0xFF231F14);     // Dark night sand card
  static const Color surfaceSecondaryDark = Color(0xFF2E2A1C);
  static const Color surfaceTertiaryDark = Color(0xFF3B3624);

  // Text Colors - Light
  static const Color textPrimaryLight = Color(0xFF282315); // Deep espresso bronze
  static const Color textSecondaryLight = Color(0xFF756E5A); // Warm sandy slate
  static const Color textTertiaryLight = Color(0xFFA19A86);

  // Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFFAF6EB); // Soft sand cream
  static const Color textSecondaryDark = Color(0xFFBCB59D); // Sandy taupe grey
  static const Color textTertiaryDark = Color(0xFF7C7560);

  // Functional & Status
  static const Color borderLight = Color(0xFFE5DFC8); // Natural sandy border
  static const Color borderDark = Color(0xFF3E3926);  // Dark night border
  static const Color success = Color(0xFF5B8A68);     // Natural olive sage
  static const Color error = Color(0xFFC76558);       // Warm terracotta coral
  static const Color info = Color(0xFF5B7B88);        // Muted river slate
  static const Color warning = Color(0xFFD49A38);     // Warm golden amber

  // Category Accent Colors (Night sands organic spectrum)
  static const Color catFood = Color(0xFF80775C);        // Night taupe
  static const Color catTransport = Color(0xFF574A24);   // Deep dark olive
  static const Color catShopping = Color(0xFFA67A50);    // Sand bronze
  static const Color catBills = Color(0xFF6B664F);       // Olive slate
  static const Color catUtilities = Color(0xFF6B664F);   // Olive slate (alias)
  static const Color catEntertainment = Color(0xFF8C765C); // Dusty sand mauve
  static const Color catHealth = Color(0xFF5B8A68);      // Earthy sage
  static const Color catEducation = Color(0xFF7D7355);   // Warm khaki
  static const Color catInvestment = Color(0xFF574A24);  // Deep night olive
  static const Color catSalary = Color(0xFF436B46);      // Deep forest green
  static const Color catOther = Color(0xFFCBBD93);       // Warm sand beige
}
