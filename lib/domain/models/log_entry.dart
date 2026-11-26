/// One confirmed set of push-ups.
class LogEntry {
  const LogEntry({
    required this.id,
    required this.createdAt,
    required this.count,
  });

  final int id;
  final DateTime createdAt;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is LogEntry &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.count == count;

  @override
  int get hashCode => Object.hash(id, createdAt, count);
}
