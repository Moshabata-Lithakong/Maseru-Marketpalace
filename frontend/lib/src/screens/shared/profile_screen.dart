import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('profile.title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Text(
                        authProvider.user?.profile.firstName.substring(0, 1) ?? 'U',
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authProvider.user?.fullName ?? appLocalizations.translate('profile.user'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(authProvider.user?.email ?? ''),
                    Chip(
                      label: Text(
                        (authProvider.user?.role ?? 'user').toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Settings Section
            Text(
              appLocalizations.translate('profile.settings'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Language Setting
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
            const SizedBox(height: 24),
            // Account Actions
            Text(
              appLocalizations.translate('profile.account'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: Text(appLocalizations.translate('profile.edit_profile')),
                    onTap: () {
                      // Navigate to edit profile
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.orange),
                    title: Text(appLocalizations.translate('profile.change_password')),
                    onTap: () {
                      // Navigate to change password
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.green),
                    title: Text(appLocalizations.translate('profile.order_history')),
                    onTap: () {
                      Navigator.pushNamed(context, '/order_history');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(appLocalizations.translate('profile.logout')),
                    onTap: () {
                      _showLogoutConfirmation(context, appLocalizations);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppLocalizations appLocalizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.translate('profile.logout_confirm')),
        content: Text(appLocalizations.translate('profile.logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.translate('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: Text(
              appLocalizations.translate('profile.logout'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}