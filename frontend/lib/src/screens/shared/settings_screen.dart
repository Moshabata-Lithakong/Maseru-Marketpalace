import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('settings.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(appLocalizations.translate('profile.language')),
              subtitle: Text(
                languageProvider.currentLanguage == 'en'
                    ? appLocalizations.translate('profile.english')
                    : appLocalizations.translate('profile.sesotho'),
              ),
              trailing: Switch(
                value: languageProvider.currentLanguage == 'st',
                onChanged: (value) {
                  languageProvider.setLanguage(value ? 'st' : 'en');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}