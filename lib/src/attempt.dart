class Attempt {
  const Attempt({
    required this.totalDuration,
    required this.counter,
  });

  final Duration totalDuration;
  final int counter;

  @override
  String toString() {
    return '"totalDuration": $totalDuration, "counter": $counter';
  }
}
