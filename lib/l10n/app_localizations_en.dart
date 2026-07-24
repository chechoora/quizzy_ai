// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Quizzy AI';

  @override
  String get homeQuizDecksTitle => 'Quiz Decks';

  @override
  String get homeDecksLabel => 'Decks';

  @override
  String get homeSettingsLabel => 'Settings';

  @override
  String get homeAddDeckTooltip => 'Add Deck';

  @override
  String homeDeleteDeckConfirmation(String deckTitle) {
    return 'Are you sure you want to delete $deckTitle, all your quiz cards also will be deleted';
  }

  @override
  String get homePremiumDeckLimitMessage => 'You can not create more decks, please unlock the full version.';

  @override
  String get homeUnlockButton => 'Unlock';

  @override
  String get quizExeFinishedTitle => 'Quiz Finished';

  @override
  String get quizExeInProgressTitle => 'Quiz in Progress';

  @override
  String get createDeckTitleLabel => 'Title of the deck';

  @override
  String get inAppFeaturesTitle => 'In-App Features';

  @override
  String get inAppFeaturesPurchaseSuccess => 'Purchase successful!';

  @override
  String get inAppFeaturesRestoreSuccess => 'Purchases restored successfully!';

  @override
  String get inAppFeaturesPurchaseError => 'Something went wrong during purchase process';

  @override
  String get inAppFeaturesUnlimitedTitle => 'Unlimited decks & cards';

  @override
  String get inAppFeaturesUnlimitedDescription => 'Create as many decks and cards as you want. Unlock AI cards generation. No limits.';

  @override
  String get inAppFeaturesUnlimitedSubtitle => 'One-time purchase';

  @override
  String get inAppFeaturesPurchased => 'Purchased';

  @override
  String get inAppFeaturesSubscribed => 'Subscribed';

  @override
  String get inAppFeaturesPurchaseButton => 'Unlock';

  @override
  String get inAppFeaturesRestoreButton => 'Restore Purchases';

  @override
  String get inAppFeaturesManageSubscriptionButton => 'Manage Subscription';

  @override
  String get inAppFeaturesQuizzyAiTitle => 'Quizzy validator';

  @override
  String get inAppFeaturesQuizzyAiDescription => 'Use our AI-powered validator to check your quiz answers with high accuracy. Also includes unlimited decks & cards and AI deck generation.';

  @override
  String get inAppFeaturesSubscribeButton => 'Subscribe';

  @override
  String get inAppFeaturesMonthlyLabel => 'Monthly';

  @override
  String get inAppFeaturesYearlyLabel => 'Yearly';

  @override
  String get inAppFeaturesBestValueLabel => 'Best value';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAiValidatorSubtitleTile => 'Configure answer validation settings';

  @override
  String get settingsDeckGenerationTitle => 'Deck Generation AI';

  @override
  String get settingsDeckGenerationSubtitleTile => 'Choose the AI used to generate decks';

  @override
  String get settingsDeckGenerationLabel => 'Deck Generation';

  @override
  String get settingsDeckGenerationSubtitle => 'Choose which AI generates your decks';

  @override
  String get settingsDeckGenerationDropdownLabel => 'Generation AI';

  @override
  String settingsDeckGenerationChangedMessage(String aiName) {
    return 'Deck generation AI changed to $aiName';
  }

  @override
  String get settingsInAppFeaturesSubtitle => 'Manage premium features';

  @override
  String get settingsImportExportTitle => 'Import / Export';

  @override
  String get settingsImportExportSubtitle => 'Import or export your decks and cards';

  @override
  String get settingsAiValidatorTitle => 'AI Validator';

  @override
  String get settingsAiValidatorLabel => 'Answer Validator';

  @override
  String get settingsAiValidatorSubtitle => 'Choose how quiz answers are validated';

  @override
  String get settingsAiValidatorApiKeyTitle => 'API Key';

  @override
  String settingsAiValidatorApiKeyLabel(String validatorName) {
    return '$validatorName API Key';
  }

  @override
  String get settingsAiValidatorApiKeyHint => 'Enter your API key';

  @override
  String get settingsAiValidatorApiKeySaveTooltip => 'Save API Key';

  @override
  String settingsAiValidatorChangedMessage(String validatorName) {
    return 'Answer validator changed to $validatorName';
  }

  @override
  String settingsAiValidatorApiKeySavedMessage(String validatorName) {
    return 'Config saved for $validatorName';
  }

  @override
  String get settingsAiValidatorOptionsTitle => 'Validator Options:';

  @override
  String get settingsAiValidatorOnDeviceDescription => 'No API key required. Uses local AI processing for privacy and offline use.';

  @override
  String get settingsAiValidatorClaudeDescription => 'Requires an Anthropic API key. Uses Claude models for answer evaluation.';

  @override
  String get settingsAiValidatorClaudeLink => 'https://platform.claude.com/login';

  @override
  String get settingsAiValidatorOpenAIDescription => 'Requires an OpenAI API key. Uses GPT models for answer validation.';

  @override
  String get settingsAiValidatorOpenAILink => 'https://auth.openai.com/log-in';

  @override
  String get settingsAiValidatorGeminiDescription => 'Requires a Google Gemini API key. Uses Google AI for intelligent answer validation.';

  @override
  String get settingsAiValidatorGeminiLink => 'https://aistudio.google.com/welcome';

  @override
  String get settingsAiValidatorMlDescription => 'No API key required. Uses built-in machine learning models for answer checking.';

  @override
  String get settingsAiValidatorOllamaDescription => 'Requires Ollama server running locally. Configure server URL and model name.';

  @override
  String get settingsAiValidatorQuizzyAIDescription => 'Premium subscription. Uses our cloud AI service for accurate answer validation.';

  @override
  String get answerValidatorDropdownLabel => 'Validator Type';

  @override
  String answerValidatorNotAvailableMessage(String validatorName) {
    return 'The $validatorName validator is not available. Please check your configuration or purchase status.';
  }

  @override
  String get settingsAiValidatorApiConfigTitle => 'Api Configuration';

  @override
  String get settingsAiValidatorServerUrlLabel => 'Server URL';

  @override
  String get settingsAiValidatorServerUrlHint => 'http://localhost:11434/api';

  @override
  String get settingsAiValidatorModelNameLabel => 'Model Name';

  @override
  String get settingsAiValidatorModelNameHint => 'llama3.2';

  @override
  String get settingsAiValidatorFillBothFieldsError => 'Please fill in both URL and model name';

  @override
  String get settingsAiValidatorSaveConfigButton => 'Save Configuration';

  @override
  String get settingsAiValidatorQuotaTitle => 'Weekly Usage Quota';

  @override
  String get settingsAiValidatorWeeklyUsageLabel => 'Usage';

  @override
  String get settingsAiValidatorQuestionsLeftLabel => 'Approximately Questions Left';

  @override
  String get settingsAiValidatorQuotaRetryButton => 'Retry';

  @override
  String get settingsAiValidatorGetApiKeyLink => 'Get API Key';

  @override
  String settingsAiValidatorCouldNotOpenUrlError(String url) {
    return 'Could not open URL: $url';
  }

  @override
  String get settingsAiValidatorDeleteButton => 'Delete';

  @override
  String get settingsAiValidatorApplyButton => 'Apply';

  @override
  String get quizCardListPremiumCardLimitMessage => 'You can not create more cards, please unlock the full version.';

  @override
  String get quizCardListDeleteCardConfirmation => 'Are you sure you want to delete current card?';

  @override
  String get quizCardListBackTooltip => 'Back';

  @override
  String get quizCardListAddCardTooltip => 'Add Card';

  @override
  String get quizCardListPlayDeckButton => 'Play the Deck';

  @override
  String get quizCardListQuickPlayButton => 'Quick Play';

  @override
  String quizCardListQuickPlaySelectedButton(int count) {
    return 'Quick Play Selected ($count)';
  }

  @override
  String get quizCardListSideSwitched => 'Side switched';

  @override
  String get quizCardListSidesNotSwitched => 'Sides not switched';

  @override
  String get quizCardListShuffleCards => 'Cards Shuffled';

  @override
  String get quizCardListCardsInOrder => 'Cards in Order';

  @override
  String get quizCardListEditCardAction => 'Edit card';

  @override
  String get quizCardListDeleteCardAction => 'Delete card';

  @override
  String get quizCardListShowStatsAction => 'Show stats';

  @override
  String get quizCardListCardStatsTitle => 'Card stats';

  @override
  String get quizCardListStatsAccuracy => 'Accuracy';

  @override
  String get quizCardListStatsAttempts => 'Attempts';

  @override
  String get quizCardListStatsBestStreak => 'Best Streak';

  @override
  String get quizCardListStatsLastPlayed => 'Last Played';

  @override
  String get quizCardListStatsNeverPlayed => 'Never';

  @override
  String get quizCardListStatsWeek => 'Week';

  @override
  String get quizCardListStatsMonth => 'Month';

  @override
  String get quizCardListStatsYear => 'Year';

  @override
  String get quizCardListSelect => 'Select';

  @override
  String get quizCardListSelectAll => 'Select all';

  @override
  String get quizCardListClearSelection => 'Clear selection';

  @override
  String quizCardListPlaySelectedButton(int count) {
    return 'Play Selected ($count)';
  }

  @override
  String get quizCardListNoUnlockedCardsSelected => 'All selected cards are locked. Please select at least one unlocked card or unlock premium features.';

  @override
  String quizExeScoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String quizExeDetailsLabel(String explanation) {
    return 'Details: $explanation';
  }

  @override
  String quizExeCorrectAnswerLabel(String correctAnswer) {
    return 'Correct answer: $correctAnswer';
  }

  @override
  String get quizExeNextCardButton => 'Next Card';

  @override
  String get quizExeValidationError => 'Answer validation error, please try again or check your AI credit balance';

  @override
  String get homeEmptyStateTitle => 'No decks yet';

  @override
  String get homeEmptyStateDescription => 'Create your first deck and start learning!';

  @override
  String get homeNewDeckTitle => 'New deck';

  @override
  String get homeNewDeckDescription => 'Enter a name for your new study collection.';

  @override
  String get homeNewDeckHint => 'e.g. World capitals';

  @override
  String get homeEditDeckTitle => 'Edit deck';

  @override
  String get homeEditDeckDescription => 'Update the name of your deck.';

  @override
  String get homeCreateDeckButton => 'Create New Deck';

  @override
  String get homeSaveDeckButton => 'Save';

  @override
  String get homeCancelButton => 'Cancel';

  @override
  String get homeDeleteButton => 'Delete';

  @override
  String get homeEditDeckAction => 'Edit deck';

  @override
  String get homeDeleteDeckAction => 'Delete deck';

  @override
  String get homePublicDecksButton => 'Public Decks';

  @override
  String get publicDecksTitle => 'Public Decks';

  @override
  String get publicDecksSearchHint => 'Search public decks';

  @override
  String get publicDecksAllCategoriesLabel => 'All';

  @override
  String get publicDecksEmptyState => 'No public decks found';

  @override
  String get publicDecksErrorMessage => 'Failed to load public decks, please try again';

  @override
  String get publicDeckDetailErrorMessage => 'Failed to load deck, please try again';

  @override
  String get publicDeckCopySuccessMessage => 'Deck added to your decks';

  @override
  String get publicDeckCopyErrorMessage => 'Failed to copy deck, please try again';

  @override
  String get quizDisplayTypeAnswerLabel => 'Type your answer below';

  @override
  String get quizDisplayTypeAnswerHint => 'Type your answer';

  @override
  String get quizDisplayAnswerButton => 'Answer';

  @override
  String get quizDisplayDontKnowButton => 'Don\'t know';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get importExportImportTitle => 'Import';

  @override
  String get importExportImportDescription => 'Import from a JSON file or clipboard. Use the matching format:';

  @override
  String get importExportImportSourceTitle => 'Import source';

  @override
  String get importExportFromFile => 'From file';

  @override
  String get importExportFromClipboard => 'From clipboard';

  @override
  String get importExportDecksButton => 'Decks';

  @override
  String get importExportCardsButton => 'Cards';

  @override
  String get importExportSelectDeckTitle => 'Select deck for import';

  @override
  String get importExportCancelButton => 'Cancel';

  @override
  String importExportImportDecksSuccess(int deckCount) {
    return 'Successfully imported $deckCount deck(s)';
  }

  @override
  String importExportImportCardsSuccess(int cardCount) {
    return 'Successfully imported $cardCount card(s)';
  }

  @override
  String get importExportExportTitle => 'Export';

  @override
  String get importExportSelectDecksToExport => 'Select decks to export';

  @override
  String get importExportSelectAll => 'Select all';

  @override
  String get importExportDeselectAll => 'Deselect all';

  @override
  String get importExportNoDecksAvailable => 'No decks available';

  @override
  String importExportExportSelectedButton(int count) {
    return 'Export Selected ($count)';
  }

  @override
  String get importExportCopiedToClipboard => 'Copied to clipboard';

  @override
  String get card => 'Card';

  @override
  String get deck => 'Deck';

  @override
  String importLimitExceeded(int limit, String typeName) {
    return 'Import limit exceeded: max $limit $typeName(s) allowed. Please purchase pro version to import more.';
  }

  @override
  String get importExportError => 'Import / Export error';

  @override
  String get importExportImportSubtitle => 'From a JSON file or clipboard';

  @override
  String get importExportImportDecksButton => 'Import Decks';

  @override
  String get importExportImportCardsButton => 'Import Cards';

  @override
  String get importExportViewJsonFormat => 'View JSON matching format';

  @override
  String get importExportExportDescription => 'Decks as JSON for backup or sharing';

  @override
  String get importExportAllDecks => 'All';

  @override
  String get importExportJsonFormatTitle => 'JSON matching format';

  @override
  String get importExportDecksFormatTitle => 'Decks format';

  @override
  String get importExportCardsFormatTitle => 'Cards format';

  @override
  String get settingsAppCreditsTitle => 'App Credits';

  @override
  String get settingsAppCreditsSubtitle => 'Meet the team behind the app';

  @override
  String get settingsSignOutTitle => 'Sign out';

  @override
  String get settingsSignOutSubtitle => 'Sign out of your account';

  @override
  String get settingsSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsDeleteAccountSubtitle => 'Permanently delete your account';

  @override
  String get settingsDeleteAccountConfirm => 'This will permanently delete your account. This action cannot be undone. Are you sure?';

  @override
  String get authSubtitle => 'Sign in to continue';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get authSignInWithApple => 'Sign in with Apple';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get appCreditsRoleFlutterDeveloper => 'Creator / Flutter Developer';

  @override
  String get appCreditsRoleDesigner => 'Designer';

  @override
  String get appCreditsRoleBackendDeveloper => 'Backend Developer';

  @override
  String get appCreditsContactUs => 'Contact us';

  @override
  String get appCreditsFromUkraine => 'From 🇺🇦 with ❤️';

  @override
  String get homeAiGenerateLabel => 'AI';

  @override
  String get aiGenerateTitle => 'AI Generate';

  @override
  String get aiGenerateInitialTitle => 'Generate a deck with AI';

  @override
  String get aiGenerateInitialHint => 'Describe the deck you want below and we\'ll create the cards for you.';

  @override
  String get aiGeneratePromptHint => 'e.g. 10 cards about the solar system';

  @override
  String get aiGenerateRefineHint => 'Refine the cards, e.g. make them harder';

  @override
  String get aiGenerateDeckTitleLabel => 'Deck title';

  @override
  String get aiGenerateDeckTitleHint => 'e.g. World capitals';

  @override
  String get aiGenerateSaveButton => 'Save Deck';

  @override
  String get aiGenerateUnlockTitle => 'Unlock AI generation';

  @override
  String get aiGenerateUnlockButton => 'Unlock full version';

  @override
  String get aiGenerateUnlockMessage => 'Upgrade to generate and refine your cards with AI.';

  @override
  String get aiGenerateAddCardLabel => 'Add card';

  @override
  String get aiGenerateDeleteCardLabel => 'Delete card';

  @override
  String get aiGenerateCardQuestionLabel => 'Question';

  @override
  String get aiGenerateCardQuestionHint => 'Enter the question';

  @override
  String get aiGenerateCardAnswerLabel => 'Answer';

  @override
  String get aiGenerateCardAnswerHint => 'Enter the answer';

  @override
  String aiGenerateCardNumber(int number) {
    return 'Card $number';
  }

  @override
  String get onboardingTitle => 'Welcome to Quizzy AI';

  @override
  String get onboardingIntro => 'Learn anything with AI-powered flashcards. Here\'s what you can do:';

  @override
  String get onboardingItemApiKeysTitle => 'Bring your own AI';

  @override
  String get onboardingItemApiKeysDescription => 'Connect your own API keys for Gemini, Claude, OpenAI or a local Ollama model.';

  @override
  String get onboardingItemModelTitle => 'Pick your model';

  @override
  String get onboardingItemModelDescription => 'Choose which AI model validates your answers and generates content.';

  @override
  String get onboardingItemGenerateTitle => 'Generate decks with AI';

  @override
  String get onboardingItemGenerateDescription => 'Describe a topic and let AI create a whole deck of quiz cards for you.';

  @override
  String get onboardingItemPremiumTitle => 'Go unlimited';

  @override
  String get onboardingItemPremiumDescription => 'Unlock unlimited decks and cards with a one-time premium purchase.';

  @override
  String get onboardingItemBackupTitle => 'Automatic iCloud backup';

  @override
  String get onboardingItemBackupDescription => 'Your decks and cards are backed up to your private iCloud and restored on any of your devices.';

  @override
  String get onboardingContinueButton => 'Get started';

  @override
  String get onboardingPaywallTitle => 'Unlock premium';

  @override
  String get onboardingPaywallIntro => 'Get the most out of Quizzy AI with our premium features:';

  @override
  String get importExportICloudTitle => 'iCloud Backup';

  @override
  String get importExportICloudDescription => 'Your decks and cards are backed up automatically to your private iCloud.';

  @override
  String get importExportICloudStatusAvailable => 'iCloud available';

  @override
  String get importExportICloudStatusNoAccount => 'No iCloud account. Sign in to iCloud in Settings to enable backup.';

  @override
  String get importExportICloudStatusRestricted => 'iCloud is restricted on this device.';

  @override
  String get importExportICloudStatusUnavailable => 'iCloud is currently unavailable.';

  @override
  String importExportICloudLastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get importExportICloudNoBackup => 'No backup yet';

  @override
  String get importExportICloudRestoreButton => 'Restore from iCloud';

  @override
  String get importExportICloudRestoreConfirmTitle => 'Restore from iCloud?';

  @override
  String get importExportICloudRestoreConfirmMessage => 'This merges your iCloud backup into this device. Existing decks and cards are kept and updated — nothing is duplicated.';

  @override
  String get importExportICloudRestoreConfirmButton => 'Restore';

  @override
  String importExportICloudRestoreSuccess(int deckCount) {
    return 'Restored $deckCount deck(s) from iCloud';
  }

  @override
  String get importExportICloudRestoreEmpty => 'No iCloud backup found';

  @override
  String get cleanInstallRestoreTitle => 'Restore your decks?';

  @override
  String get cleanInstallRestoreMessage => 'We found an iCloud backup. Would you like to restore your decks and cards?';

  @override
  String get cleanInstallRestoreButton => 'Restore';

  @override
  String get cleanInstallSkipButton => 'Skip';
}
