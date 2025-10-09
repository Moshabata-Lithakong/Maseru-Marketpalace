import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('charts.title')),
      ),
      body: const Center(
        child: Text('Chart Screen - To be implemented'),
      ),
    );
  }
}