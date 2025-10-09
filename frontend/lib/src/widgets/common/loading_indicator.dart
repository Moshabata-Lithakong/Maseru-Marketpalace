import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class LoadingIndicator extends StatelessWidget {
  final String? messageKey; // Changed to translation key

  const LoadingIndicator({super.key, this.messageKey});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (messageKey != null) ...[
            const SizedBox(height: 16), // Made const
            Text(
              appLocalizations.translate(messageKey!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }
}