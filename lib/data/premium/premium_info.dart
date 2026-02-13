class PremiumLimitInfo {
  static const deckLimit = 3;

  static const quizCardLimit = 8;

  static isLocked({
    required bool featurePurchased,
    required int count,
    required int limit,
  }) {
    if (featurePurchased) {
      return false;
    }
    return count > limit;
  }

  static canAdd({
    required bool featurePurchased,
    required int count,
    required int limit,
  }) {
    return featurePurchased ? true : count < limit;
  }
}
