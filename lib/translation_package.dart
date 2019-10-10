library translation_package;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';

/// This singleton class is use to manage the supported languages for the application
class TranslationsSupport {
  static final TranslationsSupport _singleton = TranslationsSupport._internal();

  factory TranslationsSupport() {
    return _singleton;
  }

  TranslationsSupport._internal();

  /// List of supported languages
  List<String> supportedLanguages = [];

  /// Getter that returns a list of locale based on the supported languages
  List<Locale> get supportedLocales =>
      supportedLanguages.map((language) => Locale(language, '')).toList();

  String translationFilePath = 'assets/locale/';
}

/// Class handling the translations
class Translations {
  Locale locale;
  static Map<String, dynamic> _localizedValues;

  Translations(Locale locale) {
    this.locale = locale;
    _localizedValues = null;
  }

  /// Return the current language
  get currentLanguage => locale.languageCode;

  /// The data from the closest [Translations] instance that encloses the given
  /// context.
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Text(Translations.of(context).valueOf('exampleKey'));
  /// }
  /// ```
  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  /// Return the translated value for the accorded key
  ///
  /// [key] Key for the wanted translation
  /// [args] Arguments of the translated value
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Text(Translations.of(context).valueOf('hello', ['Bob']));
  /// }
  String valueOf(String key, {args}) {
    if (_localizedValues == null || _localizedValues[key] == null) {
      return key;
    } else {
      if (args is List) {
        return sprintf(_localizedValues[key], args);
      }

      return _localizedValues[key];
    }
  }

  /// Load the appropriate values of a translation file according to the locale
  ///
  /// [locale] Locale use to load the translation file
  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);

    // Get the path of the translations folder
    String path = TranslationsSupport().translationFilePath;

    // If the path doesn't end with a '/', add it to the path
    if (!path.endsWith('/')) {
      path += '/';
    }

    // Load the file and parse it
    String jsonContent =
    await rootBundle.loadString("$path${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    return translations;
  }
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return TranslationsSupport().supportedLocales.contains(locale);
  }

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}
