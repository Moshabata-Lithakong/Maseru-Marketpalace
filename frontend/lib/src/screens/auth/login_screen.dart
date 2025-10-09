import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/providers/language_provider.dart';
import 'package:maseru_marketplace/src/providers/theme_provider.dart';
import 'package:maseru_marketplace/src/widgets/auth/role_selector.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopLocationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  bool _isLogin = true;
  String _selectedRole = 'passenger';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopLocationController.dispose();
    _licenseController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context);

    authProvider.clearError();

    try {
      if (_isLogin) {
        // Login without timeout
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Registration without timeout
        if (_passwordController.text != _confirmPasswordController.text) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.translate('auth.password_mismatch')),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        final userData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
          if (_selectedRole == 'vendor')
            'vendorInfo': jsonEncode({
              'shopName': _shopNameController.text.trim(),
              'shopLocation': _shopLocationController.text.trim(),
            }),
          if (_selectedRole == 'taxi_driver')
            'taxiDriverInfo': jsonEncode({
              'licenseNumber': _licenseController.text.trim(),
              'vehicleType': _vehicleTypeController.text.trim(),
              'vehiclePlate': _vehiclePlateController.text.trim(),
            }),
        };

        await authProvider.register(userData);
      }

      if (!mounted) return;
      
      if (authProvider.error == null) {
        _handleSuccess(authProvider, appLocalizations);
      } else {
        _showErrorDialog(authProvider.error!, appLocalizations);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString(), appLocalizations);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleSuccess(AuthProvider authProvider, AppLocalizations appLocalizations) {
    if (_isLogin) {
      // Login success - navigate to appropriate dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.translate('auth.login_success')),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        _getHomeRoute(authProvider.user?.role),
        (route) => false,
      );
    } else {
      // Registration success - show success dialog and navigate to login
      _showRegistrationSuccessDialog();
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Registration Successful'),
          ],
        ),
        content: const Text('Your account has been created successfully! Please log in with your credentials.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Continue to Login'),
          ),
        ],
      ),
    );
  }

  String _getHomeRoute(String? role) {
    switch (role) {
      case 'passenger':
        return '/passenger';
      case 'vendor':
        return '/vendor';
      case 'taxi_driver':
        return '/driver';
      case 'admin':
        return '/admin';
      default:
        return '/home';
    }
  }

  void _showErrorDialog(String message, AppLocalizations appLocalizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(appLocalizations.translate('common.error')),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.translate('common.ok')),
          ),
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _shopNameController.clear();
      _shopLocationController.clear();
      _licenseController.clear();
      _vehicleTypeController.clear();
      _vehiclePlateController.clear();
      _selectedRole = 'passenger';
      _isSubmitting = false;
    });
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('common.required');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('common.required');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context).translate('auth.invalid_email');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('common.required');
    }
    if (value.length < 6) {
      return AppLocalizations.of(context).translate('auth.invalid_password');
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('common.required');
    }
    if (!RegExp(r'^\+?[\d\s-()]{10,}$').hasMatch(value)) {
      return AppLocalizations.of(context).translate('auth.invalid_phone');
    }
    return null;
  }

  Widget _buildRoleSpecificFields() {
    if (_isLogin) return const SizedBox();

    switch (_selectedRole) {
      case 'vendor':
        return Column(
          children: [
            _buildTextField(
              controller: _shopNameController,
              label: 'auth.shop_name',
              icon: Icons.store,
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _shopLocationController,
              label: 'auth.shop_location',
              icon: Icons.location_on,
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
          ],
        );
      case 'taxi_driver':
        return Column(
          children: [
            _buildTextField(
              controller: _licenseController,
              label: 'auth.license_number',
              icon: Icons.card_membership,
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _vehicleTypeController,
              label: 'auth.vehicle_type',
              icon: Icons.directions_car,
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _vehiclePlateController,
              label: 'auth.vehicle_plate',
              icon: Icons.confirmation_number,
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool? showVisibilityToggle = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).translate(label),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: showVisibilityToggle == true
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(appLocalizations.translate('auth.welcome')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!isDarkMode),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        Colors.grey[900]!,
                        Colors.grey[800]!,
                      ]
                    : [
                        Colors.blue[50]!,
                        Colors.white,
                      ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isLogin ? Icons.login : Icons.person_add,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isLogin 
                              ? appLocalizations.translate('auth.login')
                              : appLocalizations.translate('auth.register'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Sign in to your account'
                              : 'Create your account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Role Selector (Registration only)
                    if (!_isLogin) ...[
                      RoleSelector(
                        selectedRole: _selectedRole,
                        onRoleChanged: (role) => setState(() => _selectedRole = role),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Personal Information Fields (Registration only)
                    if (!_isLogin) ...[
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'auth.first_name',
                        icon: Icons.person,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'auth.last_name',
                        icon: Icons.person_outline,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'auth.phone_number',
                        icon: Icons.phone,
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Common Fields
                    _buildTextField(
                      controller: _emailController,
                      label: 'auth.email',
                      icon: Icons.email,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'auth.password',
                      icon: Icons.lock,
                      validator: _validatePassword,
                      obscureText: _obscurePassword,
                      showVisibilityToggle: true,
                      onVisibilityToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password (Registration only)
                    if (!_isLogin)
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'auth.confirm_password',
                        icon: Icons.lock_outline,
                        validator: _validateRequired,
                        obscureText: _obscureConfirmPassword,
                        showVisibilityToggle: true,
                        onVisibilityToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    if (!_isLogin) const SizedBox(height: 16),

                    // Role Specific Fields
                    _buildRoleSpecificFields(),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isLogin
                                    ? appLocalizations.translate('auth.login')
                                    : appLocalizations.translate('auth.register'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Toggle Mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account?"
                              : "Already have an account?",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _isSubmitting ? null : _toggleMode,
                          child: Text(
                            _isLogin ? 'Sign up' : 'Sign in',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Language Toggle
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.language, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            appLocalizations.translate('common.language'),
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _isSubmitting ? null : () => languageProvider.toggleLanguage(),
                            child: Text(
                              languageProvider.currentLanguage == 'en' ? 'Sesotho' : 'English',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}