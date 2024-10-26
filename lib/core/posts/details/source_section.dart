// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/widgets/widgets.dart';

class SourceSection extends StatelessWidget {
  const SourceSection({
    super.key,
    required this.source,
    this.title,
  });

  final String? title;
  final WebSource source;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Text(
            title ?? 'post.detail.source_label'.tr(),
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.hintColor,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () => launchExternalUrlString(source.url),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorScheme.hintColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      WebsiteLogo(url: source.faviconUrl),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: Text(
                          _mapUriToSourceText(Uri.parse(source.sourceHost)),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Symbols.arrow_outward)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _mapUriToSourceText(Uri uri) {
  return uri.host.replaceAll('www.', '');
}
