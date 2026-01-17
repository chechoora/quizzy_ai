import 'package:flutter/material.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';

typedef LocalizedStrings = AppLocalizations;

LocalizedStrings localize(BuildContext context) {
  AppLocalizations? appLocalizations;
  try {
    appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
  } catch (ex) {
    appLocalizations = AppLocalizationsEn();
  }
  return appLocalizations;
}