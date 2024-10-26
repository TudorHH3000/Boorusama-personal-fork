// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';

class Quote extends StatelessWidget {
  const Quote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: context.colorScheme.hintColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      margin: const EdgeInsets.only(
        top: 3,
        bottom: 6,
      ),
      child: AppHtml(
        style: {
          'body': Style(
            fontSize: FontSize.medium,
            margin: Margins.zero,
            whiteSpace: WhiteSpace.pre,
          ),
        },
        data: text,
        onLinkTap: (url, attributes, element) {
          if (url != null) launchExternalUrl(Uri.parse(url));
        },
      ),
    );
  }
}
