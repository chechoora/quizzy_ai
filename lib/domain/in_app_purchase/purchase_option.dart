import 'package:equatable/equatable.dart';

enum SubscriptionPeriod { monthly, yearly, other }

class PurchaseOption extends Equatable {
  final String packageIdentifier;
  final SubscriptionPeriod period;
  final String priceString;

  const PurchaseOption({
    required this.packageIdentifier,
    required this.period,
    required this.priceString,
  });

  @override
  List<Object?> get props => [packageIdentifier, period, priceString];
}
