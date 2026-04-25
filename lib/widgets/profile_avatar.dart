import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.displayName,
    required this.avatarSeed,
    this.imagePath,
    this.imageBytes,
    this.size = 56,
    this.fontSize = 24,
    this.borderRadius = 18,
  });

  final String displayName;
  final int avatarSeed;
  final String? imagePath;
  final Uint8List? imageBytes;
  final double size;
  final double fontSize;
  final double borderRadius;

  static const List<List<Color>> _gradients = [
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF22C55E), Color(0xFF06B6D4)],
    [Color(0xFF7C3AED), Color(0xFF6366F1)],
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    [Color(0xFF0EA5E9), Color(0xFF2563EB)],
    [Color(0xFFF97316), Color(0xFFFB7185)],
  ];

  @override
  Widget build(BuildContext context) {
    final normalizedName = displayName.trim();
    final initial =
        normalizedName.isEmpty ? 'A' : normalizedName[0].toUpperCase();
    final gradient = _gradients[avatarSeed % _gradients.length];
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          imageBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    final file = _resolvedFile(imagePath);
    if (file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  File? _resolvedFile(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    if (kIsWeb) {
      return null;
    }

    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    return file;
  }
}
