class Attempt {
  const Attempt({
    required this.totalDuration,
    required this.counter,
  });

  /// The total duration spent retrying to load the image, including all delays between attempts.
  final Duration totalDuration;

  /// The number of attempts made to load the image.
  final int counter;

  @override
  String toString() {
    return '"totalDuration": $totalDuration, "counter": $counter';
  }
}
