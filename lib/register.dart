import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;

    final username = _userCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    try {
      // Insert into your table
      final inserted = await supabase
          .from('user_account') // table name
          .insert({
        'username': username,
        'email': email,
        'password': password,
      })
          .select()
          .single();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered: ${inserted['username']}')),
      );

      // go back to Login
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insert failed: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: const Color(0xFFE6ECF2),
        title: const Text('AutoBest PitStop', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                color: const Color(0xFFE6ECF2),
                child: const Text(
                  'Join us now! Let us fix your vehicle’s problem!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFBFB6F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create your account!', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username:',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email:',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v); // <-- fixed
                          return ok ? null : 'Enter a valid email';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _hidePass,
                        decoration: InputDecoration(
                          labelText: 'Password:',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hidePass = !_hidePass),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _hideConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password:',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_hideConfirm ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                          ),
                        ),
                        validator: (v) => (v != _passCtrl.text) ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5800D6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _submit,
                        child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
