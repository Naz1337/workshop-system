import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            Provider.of(context, listen: false), // AuthService
          ),
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (viewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.loginUser(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (viewModel.errorMessage == null) {
                          context.go('/home'); // Navigate on successful login
                        }
                      },
                      child: const Text('Login'),
                    ),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.push('/register/foreman'); // Navigate to registration
                    },
                    child: const Text('Don\'t have an account? Register here.'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
