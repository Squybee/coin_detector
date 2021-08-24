class Coin {
  final String value;
  final DateTime createdAt = DateTime.now();
  bool isExpanded = false;

  Coin(this.value);

  @override
  String toString() {
    return 'Coin{value: $value, createdAt: $createdAt, isExpanded: $isExpanded}';
  }
}