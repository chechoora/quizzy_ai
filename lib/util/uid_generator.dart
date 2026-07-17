/// Generates stable, unique ids for decks and cards used by iCloud
/// backup/restore to dedupe rows across devices.
///
/// Uses microsecond-resolution epoch time and a monotonically increasing
/// offset so that ids produced within the same microsecond (e.g. a batch
/// insert) never collide.
class UidGenerator {
  UidGenerator._();

  static int _lastMicros = 0;

  static int next() {
    var micros = DateTime.now().microsecondsSinceEpoch;
    if (micros <= _lastMicros) {
      micros = _lastMicros + 1;
    }
    _lastMicros = micros;
    return micros;
  }
}
