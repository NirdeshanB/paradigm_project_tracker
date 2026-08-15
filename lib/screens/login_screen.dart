import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/avatar_circle.dart';
import '../models/user.dart' as app_user;
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Dark/Light mode toggle switch at top right
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  ),
                  label: Text(
                    isDark ? 'Light' : 'Dark',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEEF2F6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Dynamic brand logo asset (borderless & large)
              Image.asset(
                isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
                height: 72,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              Text(
                'Paradigm Projects',
                style: TextStyle(fontFamily: 'Outfit', 
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineMedium?.color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Paradigm Digital Solutions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'Welcome back',
                style: TextStyle(fontFamily: 'Outfit', 
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineMedium?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your workspace',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Email input field
              Text(
                'EMAIL',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'alex@paradigmdigital.co',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted),
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
                ),
              ),

              const SizedBox(height: 20),

              // Password input field
              Text(
                'PASSWORD',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isLoading ? null : _signIn(),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted),
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

              // Error messages
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3E1F1F) : AppTheme.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Sign In Action button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(fontFamily: 'Outfit', 
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Forgot your password? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Reset it',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 56),

              // Workspace team member list dynamic avatars
              StreamBuilder<List<app_user.User>>(
                stream: _authService.getActiveTeamMembersStream(),
                builder: (context, snapshot) {
                  final team = snapshot.data ?? [];
                  if (team.isEmpty) return const SizedBox.shrink();

                  final displayList = team.take(3).toList();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 28,
                        width: (displayList.length * 20.0) + 12,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: List.generate(displayList.length, (index) {
                            final member = displayList[index];
                            return Positioned(
                              left: index * 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                                ),
                                child: AvatarCircle.team(
                                  initial: member.initial,
                                  colorHex: member.avatarColor,
                                  size: 24,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Text(
                        '${team.length} ${team.length == 1 ? "team member" : "team members"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
