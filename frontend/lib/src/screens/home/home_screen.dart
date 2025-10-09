import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/providers/language_provider.dart';
import 'package:maseru_marketplace/src/providers/theme_provider.dart';
import 'package:maseru_marketplace/src/widgets/common/bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Method to navigate to login screen
  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  // Method to launch Facebook URL
  void _launchFacebook() async {
    const url = 'https://facebook.com/maserumarketplace';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Facebook')),
      );
    }
  }

  // Method to navigate to chat screen
  void _navigateToChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat feature coming soon!')),
    );
  }

  // Method to launch email
  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@maserumarketplace.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Maseru Marketplace Inquiry',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email')),
      );
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with Maseru Background
          _buildHeaderSection(context, appLocalizations),

          // Quick Actions - Big Buttons
          _buildQuickActionsSection(context, appLocalizations),

          // Categories Section
          _buildCategoriesSection(context, appLocalizations),

          // How It Works - Simple Steps
          _buildHowItWorksSection(context, appLocalizations),

          // Contact Section
          _buildContactSection(context, appLocalizations),
        ],
      ),
      bottomNavigationBar: authProvider.isAuthenticated 
          ? BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            )
          : null,
    );
  }

  SliverToBoxAdapter _buildHeaderSection(BuildContext context, AppLocalizations appLocalizations) {
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1598974353355-0b4d87b9b895?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
            ),
            fit: BoxFit.cover,
          ),
          color: Colors.black.withOpacity(0.4),
          backgroundBlendMode: BlendMode.darken,
        ),
        child: Stack(
          children: [
            // Content - Positioned at bottom without center logo
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // App Logo/Title
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'MASERU MARKETPLACE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Shop Local. Support Local.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Big Get Started Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, size: 24),
                            SizedBox(width: 10),
                            Text('START SHOPPING'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickActionsSection(BuildContext context, AppLocalizations appLocalizations) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        color: Colors.grey[50],
        child: Column(
          children: [
            Text(
              'QUICK ACTIONS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 30),
            
            // Big Action Buttons - Always navigate to login for now
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildActionButton(
                  Icons.food_bank,
                  'Food & Drinks',
                  Colors.green,
                  _navigateToLogin,
                ),
                _buildActionButton(
                  Icons.shopping_bag,
                  'Clothing',
                  Colors.blue,
                  _navigateToLogin,
                ),
                _buildActionButton(
                  Icons.phone_android,
                  'Electronics',
                  Colors.purple,
                  _navigateToLogin,
                ),
                _buildActionButton(
                  Icons.home,
                  'Household',
                  Colors.orange,
                  _navigateToLogin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategoriesSection(BuildContext context, AppLocalizations appLocalizations) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        color: Colors.white,
        child: Column(
          children: [
            Text(
              'POPULAR CATEGORIES',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Find what you need quickly',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            
            // Category Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildCategoryItem('Bread', '🍞', Colors.amber),
                _buildCategoryItem('Meat', '🥩', Colors.red),
                _buildCategoryItem('Veggies', '🥬', Colors.green),
                _buildCategoryItem('Drinks', '🥤', Colors.blue),
                _buildCategoryItem('Snacks', '🍪', Colors.orange),
                _buildCategoryItem('Other', '📦', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, String emoji, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHowItWorksSection(BuildContext context, AppLocalizations appLocalizations) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.purple[700]!],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'HOW IT WORKS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // Simple Steps
            _buildSimpleStep('1', 'SIGN UP', 'Create your free account', Icons.person_add),
            const SizedBox(height: 20),
            _buildSimpleStep('2', 'BROWSE', 'Find products you need', Icons.search),
            const SizedBox(height: 20),
            _buildSimpleStep('3', 'ORDER', 'Place your order easily', Icons.shopping_cart),
            const SizedBox(height: 20),
            _buildSimpleStep('4', 'RECEIVE', 'Get delivery at taxi rank', Icons.delivery_dining),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStep(String number, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildContactSection(BuildContext context, AppLocalizations appLocalizations) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        color: Colors.grey[100],
        child: Column(
          children: [
            Text(
              'NEED HELP?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We are here to help you',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            
            // Contact Options
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildContactOption(
                  Icons.phone,
                  'CALL US',
                  '+266 5314 2951',
                  Colors.green,
                  () async {
                    final Uri phoneLaunchUri = Uri(
                      scheme: 'tel',
                      path: '+26653142951',
                    );
                    if (await canLaunchUrl(phoneLaunchUri)) {
                      await launchUrl(phoneLaunchUri);
                    }
                  },
                ),
                _buildContactOption(
                  Icons.facebook,
                  'FACEBOOK',
                  'Visit our page',
                  Colors.blue,
                  _launchFacebook,
                ),
                _buildContactOption(
                  Icons.chat,
                  'CHAT',
                  'Message us',
                  Colors.orange,
                  _navigateToChat,
                ),
                _buildContactOption(
                  Icons.email,
                  'EMAIL',
                  'Send message',
                  Colors.red,
                  _launchEmail,
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Footer Note
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '📍 Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Available at all major taxi ranks in Maseru',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Maseru Central • Bus Stop • Taxi Rank',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}