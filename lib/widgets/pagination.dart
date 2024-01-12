// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

const _maxSelectablePage = 4;

List<int> generatePage({
  required int current,
  required int? total,
  required int? itemPerPage,
}) {
  final maxPage = total != null && itemPerPage != null
      ? (total / itemPerPage).ceil()
      : null;

  if (current < _maxSelectablePage) {
    return List.generate(
      _maxSelectablePage,
      (index) => maxPage != null ? math.min(index + 1, maxPage) : index + 1,
    ).toSet().toList();
  }

  return List.generate(
    _maxSelectablePage,
    (index) => maxPage != null
        ? math.min(current + index - 1, maxPage)
        : current + index - 1,
  ).toSet().toList();
}

class PageSelector extends StatefulWidget {
  const PageSelector({
    super.key,
    required this.currentPage,
    this.totalResults,
    this.itemPerPage,
    this.onPrevious,
    this.onNext,
    required this.onPageSelect,
  });

  final int currentPage;
  final int? totalResults;
  final int? itemPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(int page) onPageSelect;

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  var pageInputMode = false;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      buttonPadding: EdgeInsets.zero,
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: widget.onPrevious,
          icon: const Icon(
            Symbols.chevron_left,
            size: 32,
          ),
        ),
        ...generatePage(
          current: widget.currentPage,
          total: widget.totalResults,
          itemPerPage: widget.itemPerPage,
        ).map(
          (page) => InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.currentPage != page
                ? () => widget.onPageSelect(page)
                : null,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 50,
                maxWidth: 80,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Text(
                '$page',
                textAlign: TextAlign.center,
                style: page == widget.currentPage
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                    : TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
              ),
            ),
          ),
        ),
        if (!pageInputMode)
          IconButton(
            onPressed: () {
              setState(() {
                pageInputMode = !pageInputMode;
              });
            },
            icon: const Icon(Symbols.more_horiz),
          )
        else
          SizedBox(
            width: 50,
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  setState(() {
                    pageInputMode = false;
                  });
                }
              },
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                onSubmitted: onSubmit,
              ),
            ),
          ),
        IconButton(
          onPressed: widget.onNext,
          icon: const Icon(
            Symbols.chevron_right,
            size: 32,
          ),
        ),
      ],
    );
  }

  void onSubmit(String value) {
    setState(() {
      pageInputMode = !pageInputMode;
    });
    final page = int.tryParse(value);
    if (page != null) {
      widget.onPageSelect(page);
    }
  }
}
