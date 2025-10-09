import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/screens/home/home_screen.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade600,
                            Colors.blue.shade700,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              user?.profile?.firstName?.substring(0, 1) ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${user?.profile?.firstName ?? ''} ${user?.profile?.lastName ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Personal Information
                    _buildSection(
                      title: appLocalizations.translate('profile.personal_info'),
                      children: [
                        _buildInfoItem(
                          Icons.person,
                          appLocalizations.translate('profile.full_name'),
                          '${user?.profile?.firstName ?? ''} ${user?.profile?.lastName ?? ''}',
                        ),
                        _buildInfoItem(
                          Icons.email,
                          appLocalizations.translate('profile.email'),
                          user?.email ?? '',
                        ),
                        _buildInfoItem(
                          Icons.phone,
                          appLocalizations.translate('profile.phone'),
                          user?.profile?.phone ?? appLocalizations.translate('profile.not_provided'),
                        ),
                        _buildInfoItem(
                          Icons.work,
                          appLocalizations.translate('profile.role'),
                          user?.role?.toUpperCase() ?? '',
                        ),
                      ],
                    ),

                    // Account Status
                    _buildSection(
                      title: appLocalizations.translate('profile.account_status'),
                      children: [
                        _buildStatusItem(
                          Icons.verified_user,
                          appLocalizations.translate('profile.verification_status'),
                          user?.isActive == true ? 'Verified' : 'Pending',
                          user?.isActive == true ? Colors.green : Colors.orange,
                        ),
                        _buildStatusItem(
                          Icons.calendar_today,
                          appLocalizations.translate('profile.member_since'),
                          user?.createdAt != null 
                              ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                              : 'N/A',
                          Colors.blue,
                        ),
                      ],
                    ),

                    // Actions
                    _buildSection(
                      title: appLocalizations.translate('profile.actions'),
                      children: [
                        _buildActionItem(
                          Icons.edit,
                          appLocalizations.translate('profile.edit_profile'),
                          () {
                            // Navigate to edit profile screen
                          },
                        ),
                        _buildActionItem(
                          Icons.settings,
                          appLocalizations.translate('profile.settings'),
                          () {
                            // Navigate to settings screen
                          },
                        ),
                        _buildActionItem(
                          Icons.logout,
                          appLocalizations.translate('profile.logout'),
                          () {
                            _showLogoutDialog(context);
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String value, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blue.shade600),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.translate('profile.logout_title')),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(appLocalizations.translate('profile.logout')),
          ),
        ],
      ),
    );
  }
}