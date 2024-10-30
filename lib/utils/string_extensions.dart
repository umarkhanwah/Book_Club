extension StringExtension on String {
  String capitalize() {
    return isNotEmpty
        ? '${this[0].toUpperCase()}${substring(1)}'
        : this;
  }
}
