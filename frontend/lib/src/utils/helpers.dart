import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class Helpers {
  static String formatCurrency(double amount, {String currency = 'LSL'}) {
    final format = NumberFormat.currency(
      symbol: '$currency ',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static void showSnackBar(BuildContext context, String messageKey, {bool isError = false}) {
    final appLocalizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.translate(messageKey)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> showLoadingDialog(BuildContext context, {String messageKey = 'common.loading'}) {
    final appLocalizations = AppLocalizations.of(context);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16), // Made const
            Text(appLocalizations.translate(messageKey)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static bool isEmailValid(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  static bool isPhoneValid(String phone) {
    final regex = RegExp(r'^[+]?[0-9]{10,15}$');
    return regex.hasMatch(phone);
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivering':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getOrderStatusText(String status, BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'pending':
        return appLocalizations.translate('orders.pending');
      case 'confirmed':
        return appLocalizations.translate('orders.confirmed');
      case 'preparing':
        return appLocalizations.translate('orders.preparing');
      case 'ready':
        return appLocalizations.translate('orders.ready');
      case 'delivering':
        return appLocalizations.translate('orders.delivering');
      case 'completed':
        return appLocalizations.translate('orders.completed');
      case 'cancelled':
        return appLocalizations.translate('orders.cancelled');
      default:
        return status;
    }
  }
}