import 'package:equatable/equatable.dart';

class UserBalance extends Equatable {
  final num weeklyBalanceUsd;
  final num weeklyLimitUsd;
  final num weeklyBalanceReq;
  final num weeklyLimitReq;

  const UserBalance({
    required this.weeklyBalanceUsd,
    required this.weeklyLimitUsd,
    required this.weeklyBalanceReq,
    required this.weeklyLimitReq,
  });

  @override
  List<Object?> get props =>
      [weeklyBalanceUsd, weeklyLimitUsd, weeklyBalanceReq, weeklyLimitReq];
}
