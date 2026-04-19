import 'package:flutter/material.dart';
import 'app_colors.dart';

class SrTypography {
  SrTypography._();

  static const _serifFamily = 'Georgia';
  static const _sansFamily = 'Roboto';

  static const display = TextStyle(
    fontFamily: _serifFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: SrColors.textPrimary,
  );

  static const h1 = TextStyle(
    fontFamily: _serifFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: SrColors.textPrimary,
  );

  static const h2 = TextStyle(
    fontFamily: _serifFamily,
    fontSize: 17,
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: SrColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: SrColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: SrColors.textMuted,
  );

  static const overline = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: 1.5,
    color: SrColors.textMuted,
  );
}
