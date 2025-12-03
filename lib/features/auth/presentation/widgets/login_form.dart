import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aa_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:aa_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:aa_app/main_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _prCodeController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _mobNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthEvent.loadConfig());
    if (_userIdController.text.isEmpty) _userIdController.text = '999';
    if (_prCodeController.text.isEmpty) _prCodeController.text = '0';
    if (_groupCodeController.text.isEmpty) _groupCodeController.text = '0';
    if (_pinCodeController.text.isEmpty) _pinCodeController.text = '1122';
    if (_baseUrlController.text.isEmpty) _baseUrlController.text = '137.59.224.222:8080';
    if (_mobNoController.text.isEmpty) _mobNoController.text = '+923457688658';
  }

  bool _hasValidConfiguration() {
    return _baseUrlController.text.isNotEmpty && 
           _userIdController.text.isNotEmpty;
  }

  void _showConfigurationHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuration Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To use server login, you need to configure:'),
            SizedBox(height: 8),
            Text('1. IP Address - Your server IP (e.g., 192.168.1.100)'),
            Text('2. User ID - Your database user ID'),
            Text('3. Other fields as required'),
            SizedBox(height: 8),
            Text('Or use the simple login (admin/pass) for testing.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _prCodeController.dispose();
    _groupCodeController.dispose();
    _pinCodeController.dispose();
    _baseUrlController.dispose();
    _mobNoController.dispose();
    super.dispose();
  }

  void _onSave() {
    context.read<AuthBloc>().add(AuthEvent.saveConfig(
      userId: _userIdController.text,
      prCode: _prCodeController.text,
      groupCode: _groupCodeController.text,
      pinCode: _pinCodeController.text,
      baseUrl: _baseUrlController.text,
      mobNo: _mobNoController.text,
    ));
  }

  void _onTest() {
    if (_baseUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Please configure IP Address first, then save configuration'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthEvent.loginRequested(
      baseUrl: _baseUrlController.text,
      userId: _userIdController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, primary.withOpacity(0.08)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              elevation: 6,
              color: Theme.of(context).cardTheme.color,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      loaded: (user) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(userName: user.userName),
                          ),
                        );
                      },
                      error: (message) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade600,
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 12),
                                const Expanded(child: Text('An error occurred')),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Error Details'),
                                        content: SelectableText(message),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('Details'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      configLoaded: (userId, prCode, groupCode, pinCode, baseUrl, mobNo) {
                        _userIdController.text = userId;
                        _prCodeController.text = prCode;
                        _groupCodeController.text = groupCode;
                        _pinCodeController.text = pinCode;
                        _baseUrlController.text = baseUrl;
                        _mobNoController.text = mobNo;
                      },
                      orElse: () {},
                    );
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      );
                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Avatar/Icon
                            Center(
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: primary.withOpacity(0.12),
                                child: Icon(Icons.home, size: 40, color: primary),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Title
                            Center(
                              child: Text(
                                'Welcome',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                'Sign in to your account',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: primary.withOpacity(0.7),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Form Fields
                            _buildTextField(
                              controller: _userIdController,
                              label: 'User ID',
                              icon: Icons.account_circle,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'User ID required' : null,
                              primary: primary,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _prCodeController,
                              label: 'Pr Code',
                              icon: Icons.code,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'Pr Code required' : null,
                              primary: primary,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _groupCodeController,
                              label: 'Group Code',
                              icon: Icons.group,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'Group Code required' : null,
                              primary: primary,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _pinCodeController,
                              label: 'Pin Code',
                              icon: Icons.lock,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              validator: (v) => v == null || v.isEmpty ? 'Pin Code required' : null,
                              primary: primary,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _baseUrlController,
                              label: 'IP Address',
                              icon: Icons.language,
                              keyboardType: TextInputType.text,
                              validator: (v) => v == null || v.isEmpty ? 'IP Address required' : null,
                              primary: primary,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _mobNoController,
                              label: 'Mobile Number',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.isEmpty ? 'Mobile Number required' : null,
                              primary: primary,
                            ),
                            const SizedBox(height: 32),
                            // Action Buttons
                            ElevatedButton.icon(
                              onPressed: isLoading ? null : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  if (_hasValidConfiguration()) {
                                    _onTest();
                                  } else {
                                    _showConfigurationHelp();
                                  }
                                }
                              },
                              icon: isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.login),
                              label: Text(isLoading ? 'Logging in...' : 'Login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading ? null : () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        _onSave();
                                      }
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primary,
                                      side: BorderSide(color: primary),
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    required Color primary,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade500, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
    );
  }
} 
