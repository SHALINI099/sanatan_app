import 'package:flutter/material.dart';
import 'package:posterapp/core/storage/app_spacing.dart';

import '../../core/storage/app_dimensions.dart';
import '../../core/theme/app_colors.dart';

class MantraTile extends StatelessWidget {
  final String title;
  final String desc;
  final String thumbnail;
  final VoidCallback? onTap;

  const MantraTile({
    super.key,
    required this.title,
    required this.desc,
    required this.thumbnail,
    this.onTap,
  });

  static const _radius = 18.0;
  static const _thumbSize = 64.0;

  // Saffron / amber devotional palette.
  static const _bgStart = Color(0xFFFFF4E0);
  static const _bgEnd = Color(0xFFFFE0B3);
  static const _accent = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          splashColor: _accent.withValues(alpha: 0.18),
          highlightColor: _accent.withValues(alpha: 0.08),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgStart, _bgEnd],
              ),
              border: Border.all(
                color: _accent.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Thumbnail(url: thumbnail, accent: _accent),
                AppSpacing.width(14),
                Expanded(child: _TitleAndDesc(title: title, desc: desc)),
                AppSpacing.width(8),
                _Chevron(color: _accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;
  final Color accent;
  const _Thumbnail({required this.url, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: MantraTile._thumbSize,
          width: MantraTile._thumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: accent.withValues(alpha: 0.12),
                child: Icon(
                  Icons.music_note_rounded,
                  color: accent,
                  size: 32,
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: accent.withValues(alpha: 0.08),
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleAndDesc extends StatelessWidget {
  final String title;
  final String desc;
  const _TitleAndDesc({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppDimensions.fontSize16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.black87,
          ),
        ),
        AppSpacing.height(4),
        Text(
          desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  final Color color;
  const _Chevron({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: color,
      ),
    );
  }
}