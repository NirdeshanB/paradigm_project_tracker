import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../models/user.dart' as app_user;

class EditProfileScreen extends StatefulWidget {
  final app_user.User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _initialsController;
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _initialsController = TextEditingController(text: widget.user.initial);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _initialsController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final initials = _initialsController.text.trim().toUpperCase();
      final password = _passwordController.text;

      // 1. Update Firebase Auth Credentials if modified
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (email != widget.user.email) {
          await currentUser.verifyBeforeUpdateEmail(email);
        }
        if (password.isNotEmpty) {
          await currentUser.updatePassword(password);
        }
      }

      // 2. Update Firestore doc
      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
        'name': name,
        'phone': phone.isEmpty ? null : phone,
        'initial': initials.isEmpty ? (name.isNotEmpty ? name[0].toUpperCase() : 'U') : initials,
        'email': email,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? 'Authentication error occurred';
        if (e.code == 'requires-recent-login') {
          msg = 'Please sign out and sign back in to modify your email or password.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(fontFamily: 'Inter', 
        fontSize: 13,
        color: const Color(0xFF64748B),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Outfit', 
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineMedium?.color,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Update your personal information below. Security changes (email/password) might require you to re-authenticate.',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Full Name field
              Text(
                'FULL NAME',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: _inputDecoration('Your name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Full name is required'
                    : null,
              ),
              const SizedBox(height: 24),

              // Initials field
              Text(
                'INITIALS',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _initialsController,
                maxLength: 2,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: _inputDecoration('e.g. JD'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Initials are required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Email Address field
              Text(
                'EMAIL ADDRESS',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: _inputDecoration('you@company.com'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Email address is required'
                    : null,
              ),
              const SizedBox(height: 24),

              // Password field
              Text(
                'NEW PASSWORD (LEAVE EMPTY TO KEEP CURRENT)',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: _inputDecoration('••••••••').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number field
              Text(
                'PHONE NUMBER',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: _inputDecoration('e.g. +1 (555) 000-0000'),
              ),
              const SizedBox(height: 48),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(fontFamily: 'Outfit', 
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
