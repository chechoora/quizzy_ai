import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_restore_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/user/user_quota_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Wipes all local device state (database + SharedPreferences) on sign-out /
/// account deletion, so the next user to sign in on this device starts from
/// a clean local slate.
class LogoutManager {
  LogoutManager({
    required this.appDatabase,
    required this.userQuotaRepository,
    required this.icloudRestoreService,
    required this.inAppPurchaseService,
    required this.logger,
  });

  final AppDatabase appDatabase;
  final UserQuotaRepository userQuotaRepository;
  final ICloudRestoreService icloudRestoreService;
  final InAppPurchaseService inAppPurchaseService;
  final Logger logger;

  Future<void> clearLocalData() async {
    logger.i('clearLocalData: starting');
    try {
      await appDatabase.clearAllTables();
      await userQuotaRepository.clearCache();
      await icloudRestoreService.clearPromptShownFlag();
      await _logOutPurchases();
      logger.i('clearLocalData: success');
    } catch (e, stackTrace) {
      logger.e('clearLocalData: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _logOutPurchases() async {
    try {
      await inAppPurchaseService.logOutUser();
    } catch (e, stackTrace) {
      logger.e('clearLocalData: RevenueCat logOut failed',
          ex: e, stacktrace: stackTrace);
    }
  }
}
