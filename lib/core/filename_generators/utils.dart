extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  double? toDoubleCommaAware() {
    final index = indexOf(',');
    if (index != -1) {
      return double.tryParse(replaceAll(',', '.'));
    }
    return double.tryParse(this);
  }
}

List<String> cleanAndRemoveDuplicates(List<String> input) {
  final List<String> cleaned = [];

  for (String str in input) {
    final int index = str.indexOf('_(');
    if (index != -1) {
      str = str.substring(0, index);
    }
    if (!cleaned.contains(str)) {
      cleaned.add(str);
    }
  }

  return cleaned;
}
