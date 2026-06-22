/// Decodes PhaJay QR payloads (base64 PNG, data URLs, or image URLs).
library;

import 'dart:convert';

import 'package:flutter/material.dart';

/// Renders PhaJay `qrCode` (base64 PNG, data URL, or remote image URL).
Widget? buildPhajayQrImage(String? raw, {double size = 280}) {
  if (raw == null || raw.trim().isEmpty) return null;
  var s = raw.trim();

  if (s.startsWith('data:image')) {
    final comma = s.indexOf(',');
    if (comma >= 0) s = s.substring(comma + 1);
  }

  if (s.startsWith('http://') || s.startsWith('https://')) {
    return Image.network(
      s,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  try {
    final bytes = base64Decode(s.replaceAll(RegExp(r'\s'), ''));
    return Image.memory(
      bytes,
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  } catch (_) {
    return null;
  }
}
