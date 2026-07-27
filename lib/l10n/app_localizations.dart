import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzy Vanilla'**
  String get appTitle;

  /// No description provided for @appTitlePro.
  ///
  /// In en, this message translates to:
  /// **'Quizzy AI Pro'**
  String get appTitlePro;

  /// No description provided for @homeQuizDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Decks'**
  String get homeQuizDecksTitle;

  /// No description provided for @homeDecksLabel.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get homeDecksLabel;

  /// No description provided for @homeSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsLabel;

  /// No description provided for @homeAddDeckTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Deck'**
  String get homeAddDeckTooltip;

  /// No description provided for @homeDeleteDeckConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {deckTitle}, all your quiz cards also will be deleted'**
  String homeDeleteDeckConfirmation(String deckTitle);

  /// No description provided for @homePremiumDeckLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You can not create more decks, please unlock the full version.'**
  String get homePremiumDeckLimitMessage;

  /// No description provided for @homeUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get homeUnlockButton;

  /// No description provided for @quizExeFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Finished'**
  String get quizExeFinishedTitle;

  /// No description provided for @quizExeInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz in Progress'**
  String get quizExeInProgressTitle;

  /// No description provided for @createDeckTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title of the deck'**
  String get createDeckTitleLabel;

  /// No description provided for @inAppFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'In-App Features'**
  String get inAppFeaturesTitle;

  /// No description provided for @inAppFeaturesPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get inAppFeaturesPurchaseSuccess;

  /// No description provided for @inAppFeaturesRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get inAppFeaturesRestoreSuccess;

  /// No description provided for @inAppFeaturesPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during purchase process'**
  String get inAppFeaturesPurchaseError;

  /// No description provided for @inAppFeaturesUnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited decks & cards'**
  String get inAppFeaturesUnlimitedTitle;

  /// No description provided for @inAppFeaturesUnlimitedDescription.
  ///
  /// In en, this message translates to:
  /// **'Create as many decks and cards as you want. Unlock AI cards generation. No limits.'**
  String get inAppFeaturesUnlimitedDescription;

  /// No description provided for @inAppFeaturesUnlimitedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get inAppFeaturesUnlimitedSubtitle;

  /// No description provided for @inAppFeaturesPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get inAppFeaturesPurchased;

  /// No description provided for @inAppFeaturesSubscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get inAppFeaturesSubscribed;

  /// No description provided for @inAppFeaturesPurchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get inAppFeaturesPurchaseButton;

  /// No description provided for @inAppFeaturesRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get inAppFeaturesRestoreButton;

  /// No description provided for @inAppFeaturesManageSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get inAppFeaturesManageSubscriptionButton;

  /// No description provided for @inAppFeaturesQuizzyAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzy validator'**
  String get inAppFeaturesQuizzyAiTitle;

  /// No description provided for @inAppFeaturesQuizzyAiDescription.
  ///
  /// In en, this message translates to:
  /// **'Use our AI-powered validator to check your quiz answers with high accuracy. Also includes unlimited decks & cards and AI deck generation.'**
  String get inAppFeaturesQuizzyAiDescription;

  /// No description provided for @inAppFeaturesSubscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get inAppFeaturesSubscribeButton;

  /// No description provided for @inAppFeaturesMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get inAppFeaturesMonthlyLabel;

  /// No description provided for @inAppFeaturesYearlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get inAppFeaturesYearlyLabel;

  /// No description provided for @inAppFeaturesBestValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get inAppFeaturesBestValueLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAiValidatorSubtitleTile.
  ///
  /// In en, this message translates to:
  /// **'Configure answer validation settings'**
  String get settingsAiValidatorSubtitleTile;

  /// No description provided for @settingsDeckGenerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck Generation AI'**
  String get settingsDeckGenerationTitle;

  /// No description provided for @settingsDeckGenerationSubtitleTile.
  ///
  /// In en, this message translates to:
  /// **'Choose the AI used to generate decks'**
  String get settingsDeckGenerationSubtitleTile;

  /// No description provided for @settingsDeckGenerationLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck Generation'**
  String get settingsDeckGenerationLabel;

  /// No description provided for @settingsDeckGenerationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which AI generates your decks'**
  String get settingsDeckGenerationSubtitle;

  /// No description provided for @settingsDeckGenerationDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Generation AI'**
  String get settingsDeckGenerationDropdownLabel;

  /// No description provided for @settingsDeckGenerationChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck generation AI changed to {aiName}'**
  String settingsDeckGenerationChangedMessage(String aiName);

  /// No description provided for @settingsInAppFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage premium features'**
  String get settingsInAppFeaturesSubtitle;

  /// No description provided for @settingsImportExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get settingsImportExportTitle;

  /// No description provided for @settingsImportExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import or export your decks and cards'**
  String get settingsImportExportSubtitle;

  /// No description provided for @settingsAiValidatorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Validator'**
  String get settingsAiValidatorTitle;

  /// No description provided for @settingsAiValidatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer Validator'**
  String get settingsAiValidatorLabel;

  /// No description provided for @settingsAiValidatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how quiz answers are validated'**
  String get settingsAiValidatorSubtitle;

  /// No description provided for @settingsAiValidatorApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settingsAiValidatorApiKeyTitle;

  /// No description provided for @settingsAiValidatorApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'{validatorName} API Key'**
  String settingsAiValidatorApiKeyLabel(String validatorName);

  /// No description provided for @settingsAiValidatorApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key'**
  String get settingsAiValidatorApiKeyHint;

  /// No description provided for @settingsAiValidatorApiKeySaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save API Key'**
  String get settingsAiValidatorApiKeySaveTooltip;

  /// No description provided for @settingsAiValidatorChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Answer validator changed to {validatorName}'**
  String settingsAiValidatorChangedMessage(String validatorName);

  /// No description provided for @settingsAiValidatorApiKeySavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Config saved for {validatorName}'**
  String settingsAiValidatorApiKeySavedMessage(String validatorName);

  /// No description provided for @settingsAiValidatorOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Validator Options:'**
  String get settingsAiValidatorOptionsTitle;

  /// No description provided for @settingsAiValidatorOnDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'No API key required. Uses local AI processing for privacy and offline use.'**
  String get settingsAiValidatorOnDeviceDescription;

  /// No description provided for @settingsAiValidatorClaudeDescription.
  ///
  /// In en, this message translates to:
  /// **'Requires an Anthropic API key. Uses Claude models for answer evaluation.'**
  String get settingsAiValidatorClaudeDescription;

  /// No description provided for @settingsAiValidatorClaudeLink.
  ///
  /// In en, this message translates to:
  /// **'https://platform.claude.com/login'**
  String get settingsAiValidatorClaudeLink;

  /// No description provided for @settingsAiValidatorOpenAIDescription.
  ///
  /// In en, this message translates to:
  /// **'Requires an OpenAI API key. Uses GPT models for answer validation.'**
  String get settingsAiValidatorOpenAIDescription;

  /// No description provided for @settingsAiValidatorOpenAILink.
  ///
  /// In en, this message translates to:
  /// **'https://auth.openai.com/log-in'**
  String get settingsAiValidatorOpenAILink;

  /// No description provided for @settingsAiValidatorGeminiDescription.
  ///
  /// In en, this message translates to:
  /// **'Requires a Google Gemini API key. Uses Google AI for intelligent answer validation.'**
  String get settingsAiValidatorGeminiDescription;

  /// No description provided for @settingsAiValidatorGeminiLink.
  ///
  /// In en, this message translates to:
  /// **'https://aistudio.google.com/welcome'**
  String get settingsAiValidatorGeminiLink;

  /// No description provided for @settingsAiValidatorMlDescription.
  ///
  /// In en, this message translates to:
  /// **'No API key required. Uses built-in machine learning models for answer checking.'**
  String get settingsAiValidatorMlDescription;

  /// No description provided for @settingsAiValidatorOllamaDescription.
  ///
  /// In en, this message translates to:
  /// **'Requires Ollama server running locally. Configure server URL and model name.'**
  String get settingsAiValidatorOllamaDescription;

  /// No description provided for @settingsAiValidatorQuizzyAIDescription.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription. Uses our cloud AI service for accurate answer validation.'**
  String get settingsAiValidatorQuizzyAIDescription;

  /// No description provided for @answerValidatorDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Validator Type'**
  String get answerValidatorDropdownLabel;

  /// No description provided for @answerValidatorNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The {validatorName} validator is not available. Please check your configuration or purchase status.'**
  String answerValidatorNotAvailableMessage(String validatorName);

  /// No description provided for @settingsAiValidatorApiConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Api Configuration'**
  String get settingsAiValidatorApiConfigTitle;

  /// No description provided for @settingsAiValidatorServerUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get settingsAiValidatorServerUrlLabel;

  /// No description provided for @settingsAiValidatorServerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://localhost:11434/api'**
  String get settingsAiValidatorServerUrlHint;

  /// No description provided for @settingsAiValidatorModelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get settingsAiValidatorModelNameLabel;

  /// No description provided for @settingsAiValidatorModelNameHint.
  ///
  /// In en, this message translates to:
  /// **'llama3.2'**
  String get settingsAiValidatorModelNameHint;

  /// No description provided for @settingsAiValidatorFillBothFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in both URL and model name'**
  String get settingsAiValidatorFillBothFieldsError;

  /// No description provided for @settingsAiValidatorSaveConfigButton.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get settingsAiValidatorSaveConfigButton;

  /// No description provided for @settingsAiValidatorQuotaTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Usage Quota'**
  String get settingsAiValidatorQuotaTitle;

  /// No description provided for @settingsAiValidatorWeeklyUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get settingsAiValidatorWeeklyUsageLabel;

  /// No description provided for @settingsAiValidatorQuestionsLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Approximately Questions Left'**
  String get settingsAiValidatorQuestionsLeftLabel;

  /// No description provided for @settingsAiValidatorQuotaRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get settingsAiValidatorQuotaRetryButton;

  /// No description provided for @settingsAiValidatorGetApiKeyLink.
  ///
  /// In en, this message translates to:
  /// **'Get API Key'**
  String get settingsAiValidatorGetApiKeyLink;

  /// No description provided for @settingsAiValidatorCouldNotOpenUrlError.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL: {url}'**
  String settingsAiValidatorCouldNotOpenUrlError(String url);

  /// No description provided for @settingsAiValidatorDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsAiValidatorDeleteButton;

  /// No description provided for @settingsAiValidatorApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get settingsAiValidatorApplyButton;

  /// No description provided for @quizCardListPremiumCardLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You can not create more cards, please unlock the full version.'**
  String get quizCardListPremiumCardLimitMessage;

  /// No description provided for @quizCardListDeleteCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete current card?'**
  String get quizCardListDeleteCardConfirmation;

  /// No description provided for @quizCardListBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get quizCardListBackTooltip;

  /// No description provided for @quizCardListAddCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get quizCardListAddCardTooltip;

  /// No description provided for @quizCardListPlayDeckButton.
  ///
  /// In en, this message translates to:
  /// **'Play the Deck'**
  String get quizCardListPlayDeckButton;

  /// No description provided for @quizCardListQuickPlayButton.
  ///
  /// In en, this message translates to:
  /// **'Quick Play'**
  String get quizCardListQuickPlayButton;

  /// No description provided for @quizCardListQuickPlaySelectedButton.
  ///
  /// In en, this message translates to:
  /// **'Quick Play Selected ({count})'**
  String quizCardListQuickPlaySelectedButton(int count);

  /// No description provided for @quizCardListSideSwitched.
  ///
  /// In en, this message translates to:
  /// **'Side switched'**
  String get quizCardListSideSwitched;

  /// No description provided for @quizCardListSidesNotSwitched.
  ///
  /// In en, this message translates to:
  /// **'Sides not switched'**
  String get quizCardListSidesNotSwitched;

  /// No description provided for @quizCardListShuffleCards.
  ///
  /// In en, this message translates to:
  /// **'Cards Shuffled'**
  String get quizCardListShuffleCards;

  /// No description provided for @quizCardListCardsInOrder.
  ///
  /// In en, this message translates to:
  /// **'Cards in Order'**
  String get quizCardListCardsInOrder;

  /// No description provided for @quizCardListEditCardAction.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get quizCardListEditCardAction;

  /// No description provided for @quizCardListDeleteCardAction.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get quizCardListDeleteCardAction;

  /// No description provided for @quizCardListShowStatsAction.
  ///
  /// In en, this message translates to:
  /// **'Show stats'**
  String get quizCardListShowStatsAction;

  /// No description provided for @quizCardListCardStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Card stats'**
  String get quizCardListCardStatsTitle;

  /// No description provided for @quizCardListStatsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get quizCardListStatsAccuracy;

  /// No description provided for @quizCardListStatsAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get quizCardListStatsAttempts;

  /// No description provided for @quizCardListStatsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get quizCardListStatsBestStreak;

  /// No description provided for @quizCardListStatsLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last Played'**
  String get quizCardListStatsLastPlayed;

  /// No description provided for @quizCardListStatsNeverPlayed.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get quizCardListStatsNeverPlayed;

  /// No description provided for @quizCardListStatsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get quizCardListStatsWeek;

  /// No description provided for @quizCardListStatsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get quizCardListStatsMonth;

  /// No description provided for @quizCardListStatsYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get quizCardListStatsYear;

  /// No description provided for @quizCardListSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get quizCardListSelect;

  /// No description provided for @quizCardListSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get quizCardListSelectAll;

  /// No description provided for @quizCardListClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get quizCardListClearSelection;

  /// No description provided for @quizCardListPlaySelectedButton.
  ///
  /// In en, this message translates to:
  /// **'Play Selected ({count})'**
  String quizCardListPlaySelectedButton(int count);

  /// No description provided for @quizCardListNoUnlockedCardsSelected.
  ///
  /// In en, this message translates to:
  /// **'All selected cards are locked. Please select at least one unlocked card or unlock premium features.'**
  String get quizCardListNoUnlockedCardsSelected;

  /// No description provided for @quizExeScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String quizExeScoreLabel(int score);

  /// No description provided for @quizExeDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details: {explanation}'**
  String quizExeDetailsLabel(String explanation);

  /// No description provided for @quizExeCorrectAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {correctAnswer}'**
  String quizExeCorrectAnswerLabel(String correctAnswer);

  /// No description provided for @quizExeNextCardButton.
  ///
  /// In en, this message translates to:
  /// **'Next Card'**
  String get quizExeNextCardButton;

  /// No description provided for @quizExeValidationError.
  ///
  /// In en, this message translates to:
  /// **'Answer validation error, please try again or check your AI credit balance'**
  String get quizExeValidationError;

  /// No description provided for @homeEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get homeEmptyStateTitle;

  /// No description provided for @homeEmptyStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first deck and start learning!'**
  String get homeEmptyStateDescription;

  /// No description provided for @homeNewDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get homeNewDeckTitle;

  /// No description provided for @homeNewDeckDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for your new study collection.'**
  String get homeNewDeckDescription;

  /// No description provided for @homeNewDeckHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. World capitals'**
  String get homeNewDeckHint;

  /// No description provided for @homeEditDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get homeEditDeckTitle;

  /// No description provided for @homeEditDeckDescription.
  ///
  /// In en, this message translates to:
  /// **'Update the name of your deck.'**
  String get homeEditDeckDescription;

  /// No description provided for @homeCreateDeckButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Deck'**
  String get homeCreateDeckButton;

  /// No description provided for @homeSaveDeckButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeSaveDeckButton;

  /// No description provided for @homeCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeCancelButton;

  /// No description provided for @homeDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeDeleteButton;

  /// No description provided for @homeEditDeckAction.
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get homeEditDeckAction;

  /// No description provided for @homeDeleteDeckAction.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get homeDeleteDeckAction;

  /// No description provided for @homePublicDecksButton.
  ///
  /// In en, this message translates to:
  /// **'Public Decks'**
  String get homePublicDecksButton;

  /// No description provided for @publicDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Public Decks'**
  String get publicDecksTitle;

  /// No description provided for @publicDecksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search public decks'**
  String get publicDecksSearchHint;

  /// No description provided for @publicDecksAllCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get publicDecksAllCategoriesLabel;

  /// No description provided for @publicDecksEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No public decks found'**
  String get publicDecksEmptyState;

  /// No description provided for @publicDecksErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load public decks, please try again'**
  String get publicDecksErrorMessage;

  /// No description provided for @publicDeckDetailErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load deck, please try again'**
  String get publicDeckDetailErrorMessage;

  /// No description provided for @publicDeckCopySuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck added to your decks'**
  String get publicDeckCopySuccessMessage;

  /// No description provided for @publicDeckCopyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy deck, please try again'**
  String get publicDeckCopyErrorMessage;

  /// No description provided for @quizDisplayTypeAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Type your answer below'**
  String get quizDisplayTypeAnswerLabel;

  /// No description provided for @quizDisplayTypeAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer'**
  String get quizDisplayTypeAnswerHint;

  /// No description provided for @quizDisplayAnswerButton.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get quizDisplayAnswerButton;

  /// No description provided for @quizDisplayDontKnowButton.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know'**
  String get quizDisplayDontKnowButton;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @importExportImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importExportImportTitle;

  /// No description provided for @importExportImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import from a JSON file or clipboard. Use the matching format:'**
  String get importExportImportDescription;

  /// No description provided for @importExportImportSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Import source'**
  String get importExportImportSourceTitle;

  /// No description provided for @importExportFromFile.
  ///
  /// In en, this message translates to:
  /// **'From file'**
  String get importExportFromFile;

  /// No description provided for @importExportFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'From clipboard'**
  String get importExportFromClipboard;

  /// No description provided for @importExportDecksButton.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get importExportDecksButton;

  /// No description provided for @importExportCardsButton.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get importExportCardsButton;

  /// No description provided for @importExportSelectDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Select deck for import'**
  String get importExportSelectDeckTitle;

  /// No description provided for @importExportCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get importExportCancelButton;

  /// No description provided for @importExportImportDecksSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {deckCount} deck(s)'**
  String importExportImportDecksSuccess(int deckCount);

  /// No description provided for @importExportImportCardsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {cardCount} card(s)'**
  String importExportImportCardsSuccess(int cardCount);

  /// No description provided for @importExportExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get importExportExportTitle;

  /// No description provided for @importExportSelectDecksToExport.
  ///
  /// In en, this message translates to:
  /// **'Select decks to export'**
  String get importExportSelectDecksToExport;

  /// No description provided for @importExportSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get importExportSelectAll;

  /// No description provided for @importExportDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get importExportDeselectAll;

  /// No description provided for @importExportNoDecksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No decks available'**
  String get importExportNoDecksAvailable;

  /// No description provided for @importExportExportSelectedButton.
  ///
  /// In en, this message translates to:
  /// **'Export Selected ({count})'**
  String importExportExportSelectedButton(int count);

  /// No description provided for @importExportCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get importExportCopiedToClipboard;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @deck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get deck;

  /// No description provided for @importLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Import limit exceeded: max {limit} {typeName}(s) allowed. Please purchase pro version to import more.'**
  String importLimitExceeded(int limit, String typeName);

  /// No description provided for @importExportError.
  ///
  /// In en, this message translates to:
  /// **'Import / Export error'**
  String get importExportError;

  /// No description provided for @importExportImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From a JSON file or clipboard'**
  String get importExportImportSubtitle;

  /// No description provided for @importExportImportDecksButton.
  ///
  /// In en, this message translates to:
  /// **'Import Decks'**
  String get importExportImportDecksButton;

  /// No description provided for @importExportImportCardsButton.
  ///
  /// In en, this message translates to:
  /// **'Import Cards'**
  String get importExportImportCardsButton;

  /// No description provided for @importExportViewJsonFormat.
  ///
  /// In en, this message translates to:
  /// **'View JSON matching format'**
  String get importExportViewJsonFormat;

  /// No description provided for @importExportExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Decks as JSON for backup or sharing'**
  String get importExportExportDescription;

  /// No description provided for @importExportAllDecks.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get importExportAllDecks;

  /// No description provided for @importExportJsonFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'JSON matching format'**
  String get importExportJsonFormatTitle;

  /// No description provided for @importExportDecksFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Decks format'**
  String get importExportDecksFormatTitle;

  /// No description provided for @importExportCardsFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards format'**
  String get importExportCardsFormatTitle;

  /// No description provided for @settingsAppCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Credits'**
  String get settingsAppCreditsTitle;

  /// No description provided for @settingsAppCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meet the team behind the app'**
  String get settingsAppCreditsSubtitle;

  /// No description provided for @settingsSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOutTitle;

  /// No description provided for @settingsSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingsSignOutSubtitle;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsSignOutConfirm;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account. This action cannot be undone. Are you sure?'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSubtitle;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authSignInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get authSignInWithApple;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get authTermsAndConditions;

  /// No description provided for @authCouldNotOpenLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String authCouldNotOpenLinkError(String url);

  /// No description provided for @appCreditsRoleFlutterDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Creator / Flutter Developer'**
  String get appCreditsRoleFlutterDeveloper;

  /// No description provided for @appCreditsRoleDesigner.
  ///
  /// In en, this message translates to:
  /// **'Designer'**
  String get appCreditsRoleDesigner;

  /// No description provided for @appCreditsRoleBackendDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Backend Developer'**
  String get appCreditsRoleBackendDeveloper;

  /// No description provided for @appCreditsContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get appCreditsContactUs;

  /// No description provided for @appCreditsFromUkraine.
  ///
  /// In en, this message translates to:
  /// **'From 🇺🇦 with ❤️'**
  String get appCreditsFromUkraine;

  /// No description provided for @homeAiGenerateLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get homeAiGenerateLabel;

  /// No description provided for @aiGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Generate'**
  String get aiGenerateTitle;

  /// No description provided for @aiGenerateInitialTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a deck with AI'**
  String get aiGenerateInitialTitle;

  /// No description provided for @aiGenerateInitialHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the deck you want below and we\'ll create the cards for you.'**
  String get aiGenerateInitialHint;

  /// No description provided for @aiGeneratePromptHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10 cards about the solar system'**
  String get aiGeneratePromptHint;

  /// No description provided for @aiGenerateRefineHint.
  ///
  /// In en, this message translates to:
  /// **'Refine the cards, e.g. make them harder'**
  String get aiGenerateRefineHint;

  /// No description provided for @aiGenerateDeckTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck title'**
  String get aiGenerateDeckTitleLabel;

  /// No description provided for @aiGenerateDeckTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. World capitals'**
  String get aiGenerateDeckTitleHint;

  /// No description provided for @aiGenerateSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Deck'**
  String get aiGenerateSaveButton;

  /// No description provided for @aiGenerateUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock AI generation'**
  String get aiGenerateUnlockTitle;

  /// No description provided for @aiGenerateUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock full version'**
  String get aiGenerateUnlockButton;

  /// No description provided for @aiGenerateUnlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to generate and refine your cards with AI.'**
  String get aiGenerateUnlockMessage;

  /// No description provided for @aiGenerateAddCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get aiGenerateAddCardLabel;

  /// No description provided for @aiGenerateDeleteCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get aiGenerateDeleteCardLabel;

  /// No description provided for @aiGenerateCardQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get aiGenerateCardQuestionLabel;

  /// No description provided for @aiGenerateCardQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the question'**
  String get aiGenerateCardQuestionHint;

  /// No description provided for @aiGenerateCardAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get aiGenerateCardAnswerLabel;

  /// No description provided for @aiGenerateCardAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the answer'**
  String get aiGenerateCardAnswerHint;

  /// No description provided for @aiGenerateCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card {number}'**
  String aiGenerateCardNumber(int number);

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Quizzy AI'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Learn anything with AI-powered flashcards. Here\'s what you can do:'**
  String get onboardingIntro;

  /// No description provided for @onboardingItemApiKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your own AI'**
  String get onboardingItemApiKeysTitle;

  /// No description provided for @onboardingItemApiKeysDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your own API keys for Gemini, Claude, OpenAI or a local Ollama model.'**
  String get onboardingItemApiKeysDescription;

  /// No description provided for @onboardingItemModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your model'**
  String get onboardingItemModelTitle;

  /// No description provided for @onboardingItemModelDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which AI model validates your answers and generates content.'**
  String get onboardingItemModelDescription;

  /// No description provided for @onboardingItemGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate decks with AI'**
  String get onboardingItemGenerateTitle;

  /// No description provided for @onboardingItemGenerateDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe a topic and let AI create a whole deck of quiz cards for you.'**
  String get onboardingItemGenerateDescription;

  /// No description provided for @onboardingItemPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Go unlimited'**
  String get onboardingItemPremiumTitle;

  /// No description provided for @onboardingItemPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited decks and cards with a one-time premium purchase.'**
  String get onboardingItemPremiumDescription;

  /// No description provided for @onboardingItemBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic iCloud backup'**
  String get onboardingItemBackupTitle;

  /// No description provided for @onboardingItemBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Your decks and cards are backed up to your private iCloud and restored on any of your devices.'**
  String get onboardingItemBackupDescription;

  /// No description provided for @onboardingContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingContinueButton;

  /// No description provided for @onboardingPaywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium'**
  String get onboardingPaywallTitle;

  /// No description provided for @onboardingPaywallIntro.
  ///
  /// In en, this message translates to:
  /// **'Get the most out of Quizzy AI with our premium features:'**
  String get onboardingPaywallIntro;

  /// No description provided for @onboardingProPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Generate decks by prompt'**
  String get onboardingProPage1Title;

  /// No description provided for @onboardingProPage1Description.
  ///
  /// In en, this message translates to:
  /// **'Describe any topic and let AI build a full deck of quiz cards for you.'**
  String get onboardingProPage1Description;

  /// No description provided for @onboardingProPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Validate answers with AI'**
  String get onboardingProPage2Title;

  /// No description provided for @onboardingProPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Get instant, accurate feedback on every answer you give.'**
  String get onboardingProPage2Description;

  /// No description provided for @onboardingProPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Sync across devices'**
  String get onboardingProPage3Title;

  /// No description provided for @onboardingProPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Your decks and progress stay up to date on all your devices.'**
  String get onboardingProPage3Description;

  /// No description provided for @onboardingProPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Stats for cards'**
  String get onboardingProPage4Title;

  /// No description provided for @onboardingProPage4Description.
  ///
  /// In en, this message translates to:
  /// **'Track how well you know each card and watch your progress grow.'**
  String get onboardingProPage4Description;

  /// No description provided for @onboardingProNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingProNextButton;

  /// No description provided for @onboardingProGetStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingProGetStartedButton;

  /// No description provided for @onboardingProSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingProSkipButton;

  /// No description provided for @importExportICloudTitle.
  ///
  /// In en, this message translates to:
  /// **'iCloud Backup'**
  String get importExportICloudTitle;

  /// No description provided for @importExportICloudDescription.
  ///
  /// In en, this message translates to:
  /// **'Your decks and cards are backed up automatically to your private iCloud.'**
  String get importExportICloudDescription;

  /// No description provided for @importExportICloudStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'iCloud available'**
  String get importExportICloudStatusAvailable;

  /// No description provided for @importExportICloudStatusNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No iCloud account. Sign in to iCloud in Settings to enable backup.'**
  String get importExportICloudStatusNoAccount;

  /// No description provided for @importExportICloudStatusRestricted.
  ///
  /// In en, this message translates to:
  /// **'iCloud is restricted on this device.'**
  String get importExportICloudStatusRestricted;

  /// No description provided for @importExportICloudStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'iCloud is currently unavailable.'**
  String get importExportICloudStatusUnavailable;

  /// No description provided for @importExportICloudLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String importExportICloudLastBackup(String date);

  /// No description provided for @importExportICloudNoBackup.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get importExportICloudNoBackup;

  /// No description provided for @importExportICloudRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from iCloud'**
  String get importExportICloudRestoreButton;

  /// No description provided for @importExportICloudRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from iCloud?'**
  String get importExportICloudRestoreConfirmTitle;

  /// No description provided for @importExportICloudRestoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This merges your iCloud backup into this device. Existing decks and cards are kept and updated — nothing is duplicated.'**
  String get importExportICloudRestoreConfirmMessage;

  /// No description provided for @importExportICloudRestoreConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get importExportICloudRestoreConfirmButton;

  /// No description provided for @importExportICloudRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {deckCount} deck(s) from iCloud'**
  String importExportICloudRestoreSuccess(int deckCount);

  /// No description provided for @importExportICloudRestoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No iCloud backup found'**
  String get importExportICloudRestoreEmpty;

  /// No description provided for @cleanInstallRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your decks?'**
  String get cleanInstallRestoreTitle;

  /// No description provided for @cleanInstallRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'We found an iCloud backup. Would you like to restore your decks and cards?'**
  String get cleanInstallRestoreMessage;

  /// No description provided for @cleanInstallRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get cleanInstallRestoreButton;

  /// No description provided for @cleanInstallSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get cleanInstallSkipButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
