import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/screens/home/home_screen.dart';
import 'package:maseru_marketplace/src/screens/vendor/vendor_dashboard.dart';
import 'package:maseru_marketplace/src/screens/vendor/vendor_orders_screen.dart';
import 'package:maseru_marketplace/src/screens/vendor/vendor_products_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/chat_screen.dart';
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
    final userRole = user?.role?.toLowerCase();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Section
                SliverAppBar(
                  expandedHeight: 220.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Profile Avatar
                            Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 3,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      user?.profile?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // User Name
                            Text(
                              '${user?.profile?.firstName ?? ''} ${user?.profile?.lastName ?? ''}'.trim(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            // Email
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                userRole?.toUpperCase() ?? 'USER',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),

                // Content Sections
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    
                    // Personal Information Section
                    _buildSection(
                      title: appLocalizations.translate('profile.personal_info') ?? 'Personal Information',
                      icon: Icons.person_outline,
                      theme: theme,
                      children: [
                        _buildInfoCard(
                          context,
                          [
                            _buildInfoRow(
                              Icons.person,
                              appLocalizations.translate('profile.full_name') ?? 'Full Name',
                              '${user?.profile?.firstName ?? ''} ${user?.profile?.lastName ?? ''}'.trim(),
                              theme,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              Icons.email,
                              appLocalizations.translate('profile.email') ?? 'Email',
                              user?.email ?? '',
                              theme,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              Icons.phone,
                              appLocalizations.translate('profile.phone') ?? 'Phone',
                              user?.profile?.phone ?? (appLocalizations.translate('profile.not_provided') ?? 'Not provided'),
                              theme,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              Icons.work,
                              appLocalizations.translate('profile.role') ?? 'Role',
                              user?.role?.toUpperCase() ?? '',
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Vendor Dashboard Section
                    if (userRole == 'vendor') ...[
                      _buildSection(
                        title: 'Vendor Dashboard',
                        icon: Icons.storefront,
                        theme: theme,
                        children: [
                          _buildActionGrid(
                            context,
                            [
                              _buildDashboardAction(
                                Icons.dashboard,
                                'Dashboard',
                                Colors.blue,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const VendorDashboard()),
                                ),
                              ),
                              _buildDashboardAction(
                                Icons.inventory_2,
                                'Products',
                                Colors.green,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const VendorProductsScreen()),
                                ),
                              ),
                              _buildDashboardAction(
                                Icons.receipt_long,
                                'Orders',
                                Colors.orange,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const VendorOrdersScreen()),
                                ),
                              ),
                              _buildDashboardAction(
                                Icons.chat,
                                'Messages',
                                Colors.purple,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],

                    // Driver Dashboard Section
                    if (userRole == 'driver') ...[
                      _buildSection(
                        title: 'Driver Dashboard',
                        icon: Icons.directions_car,
                        theme: theme,
                        children: [
                          _buildActionGrid(
                            context,
                            [
                              _buildDashboardAction(
                                Icons.directions_car,
                                'Dashboard',
                                Colors.blue,
                                () {
                                  // Navigate to driver dashboard
                                },
                              ),
                              _buildDashboardAction(
                                Icons.delivery_dining,
                                'Deliveries',
                                Colors.green,
                                () {
                                  // Navigate to driver deliveries
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],

                    // Account Status Section
                    _buildSection(
                      title: appLocalizations.translate('profile.account_status') ?? 'Account Status',
                      icon: Icons.verified_user_outlined,
                      theme: theme,
                      children: [
                        _buildStatusCard(
                          context,
                          [
                            _buildStatusItem(
                              Icons.verified_user,
                              appLocalizations.translate('profile.verification_status') ?? 'Verification Status',
                              user?.isActive == true ? 'Verified' : 'Pending Verification',
                              user?.isActive == true ? Colors.green : Colors.orange,
                              theme,
                            ),
                            _buildDivider(),
                            _buildStatusItem(
                              Icons.calendar_today,
                              appLocalizations.translate('profile.member_since') ?? 'Member Since',
                              user?.createdAt != null 
                                  ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                  : 'N/A',
                              Colors.blue,
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Quick Actions Section
                    _buildSection(
                      title: appLocalizations.translate('profile.actions') ?? 'Quick Actions',
                      icon: Icons.settings_outlined,
                      theme: theme,
                      children: [
                        _buildActionCard(
                          context,
                          [
                            _buildActionItem(
                              Icons.edit,
                              appLocalizations.translate('profile.edit_profile') ?? 'Edit Profile',
                              Colors.blue,
                              () {
                                // Navigate to edit profile screen
                              },
                            ),
                            _buildDivider(),
                            _buildActionItem(
                              Icons.settings,
                              appLocalizations.translate('profile.settings') ?? 'Settings',
                              Colors.grey,
                              () {
                                // Navigate to settings screen
                              },
                            ),
                            _buildDivider(),
                            _buildActionItem(
                              Icons.help_center,
                              'Help & Support',
                              Colors.purple,
                              () {
                                // Navigate to help screen
                              },
                            ),
                            _buildDivider(),
                            _buildActionItem(
                              Icons.privacy_tip,
                              'Privacy Policy',
                              Colors.teal,
                              () {
                                // Navigate to privacy policy
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Logout Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showLogoutDialog(context),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    appLocalizations.translate('profile.logout') ?? 'Logout',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required ThemeData theme, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String value, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.split(' ').first,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: children,
    );
  }

  Widget _buildDashboardAction(IconData icon, String title, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionItem(IconData icon, String title, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: theme.colorScheme.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                appLocalizations.translate('profile.logout_title') ?? 'Logout?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                appLocalizations.translate('profile.logout_message') ?? 'Are you sure you want to logout?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(appLocalizations.translate('common.cancel') ?? 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(appLocalizations.translate('profile.logout') ?? 'Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}