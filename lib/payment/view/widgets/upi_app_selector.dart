import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/upi_config.dart';
import '../../data/model/UpiAppModel.dart';

class UpiAppSelector extends StatelessWidget {
  final List<UpiApp> apps;


  final String? selectedPackage;


  final bool otherSelected;

  final ValueChanged<String> onSelectApp;
  final VoidCallback onSelectOther;

  final bool enabled;

  const UpiAppSelector({
    super.key,
    required this.apps,
    required this.selectedPackage,
    required this.otherSelected,
    required this.onSelectApp,
    required this.onSelectOther,
    this.enabled = true,
  });

  bool get _showOther => UpiConfig.otherLabel.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) return const SizedBox.shrink();

    final tiles = <Widget>[
      for (final app in apps)
        _UpiTile(
          label: app.appName,
          iconUrl: app.appLogoUrl,
          iconBase64: app.iconBase64,
          iconFit: BoxFit.contain,
          iconScale: 1,
          selected: !otherSelected && selectedPackage == app.packageName,
          onTap: enabled ? () => onSelectApp(app.packageName) : null,
        ),
      if (_showOther)
        _UpiTile(
          label: UpiConfig.otherLabel,
          iconUrl: UpiConfig.otherIconUrl,
          iconBase64: null,
          iconFit: BoxFit.contain,
          iconScale: UpiConfig.otherIconScale,
          selected: otherSelected,
          onTap: enabled ? onSelectOther : null,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (UpiConfig.headerLabel.isNotEmpty) ...[
          Text(
            UpiConfig.headerLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: UpiConfig.headerColor,
            ),
          ),
          SizedBox(height: UpiConfig.cardGap),
        ],

        Wrap(
          spacing: UpiConfig.cardGap,
          runSpacing: UpiConfig.cardGap,
          children: tiles,
        ),
      ],
    );
  }
}

class _UpiTile extends StatelessWidget {
  final String label;
  final String? iconUrl;
  final String? iconBase64;
  final BoxFit iconFit;
  final double iconScale;
  final bool selected;
  final VoidCallback? onTap;

  const _UpiTile({
    required this.label,
    required this.iconUrl,
    required this.iconBase64,
    required this.iconFit,
    required this.iconScale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = UpiConfig.selectedBorderColor;
    final ring = selected ? accent : Colors.grey.shade200;
    final diameter = UpiConfig.iconSize + UpiConfig.iconRingWidth * 1;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Fixed width so labels of different lengths cannot shift the icons out of
        // alignment with each other.
        width: diameter + 18,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: UpiConfig.iconRingWidth),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: UpiConfig.iconSize,
                  height: UpiConfig.iconSize,
                  // Scaling inside the ClipOval, not around it: the mark grows to match the
                  // full-bleed app icons while anything spilling past the circle is still
                  // clipped by the ring.
                  child: Transform.scale(
                    scale: iconScale,
                    child: _UpiIcon(
                      url: iconUrl,
                      base64Data: iconBase64,
                      fit: iconFit,
                      label: label,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // FittedBox so a long app name shrinks instead of forcing a different tile
            // height per app.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  // Selection is signalled by the label and the ring, not by a box.
                  color: selected
                      ? UpiConfig.selectedLabelColor
                      : UpiConfig.labelColor,
                  fontSize: UpiConfig.labelFontSize,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpiIcon extends StatelessWidget {
  final String? url;
  final String? base64Data;
  final BoxFit fit;
  final String label;

  const _UpiIcon({
    required this.url,
    required this.base64Data,
    required this.fit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u != null && u.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: u,
        fit: fit,
        placeholder: (_, __) => _local(),
        errorWidget: (_, __, ___) => _local(),
      );
    }
    return _local();
  }

  Widget _local() {
    final b64 = base64Data;
    if (b64 != null && b64.isNotEmpty) {
      try {
        return Image.memory(base64Decode(b64), fit: fit);
      } catch (_) {
        // Fall through to the initial.
      }
    }
    return _initial();
  }

  Widget _initial() {
    final trimmed = label.trim();
    final letter =
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    return ColoredBox(
      color: UpiConfig.selectedBorderColor.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: UpiConfig.selectedLabelColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}