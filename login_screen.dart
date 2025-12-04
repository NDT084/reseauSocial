import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _AnimatedLogo(),
                  const SizedBox(height: 20),
                  const _AnimatedTitle(),
                  const SizedBox(height: 40),
                  const _LoginButton(),
                  const SizedBox(height: 20),
                  _ThemeToggleButton(
                    onToggle: () {
                      // Appel global pour toggle thème (via Provider)
                      Provider.of<dynamic>(
                        context,
                        listen: false,
                      ).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget animé pour le logo, responsive.
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.4; // Responsive
    return Semantics(
      label: 'Logo de l\'application',
      child:
          FlutterLogo(
                size: size.clamp(80.0, 120.0), // Clamp pour éviter les extrêmes
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .rotate(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeInOut,
              )
              .shimmer(), // Effet scintillant pour plus de fun
    );
  }
}

/// Titre animé avec slide et fade.
class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mini Réseau Social',
      child:
          const Text(
                'Mini Réseau Social',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white, // Ou Theme.of(context).colorScheme.onPrimary
                ),
                textAlign: TextAlign.center,
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.2, end: 0.0),
    );
  }
}

/// Bouton de login avec état de chargement simulé.
class _LoginButton extends StatefulWidget {
  const _LoginButton();

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    _loadingNotifier.value = true;
    // Simulation de login Firebase (remplace par FirebaseAuth.signInWithEmailAndPassword)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
      _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loadingNotifier,
      builder: (context, isLoading, child) {
        return Semantics(
          label: 'Se connecter à l\'application',
          child:
              ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleLogin,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      isLoading ? 'Connexion...' : 'Se connecter (Simulation)',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                    ),
                  )
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0.0),
        );
      },
    );
  }
}

/// Bouton pour toggle thème.
class _ThemeToggleButton extends StatelessWidget {
  final VoidCallback onToggle;
  const _ThemeToggleButton({required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Basculer en mode ${isDark ? 'clair' : 'sombre'}',
      child: TextButton.icon(
        onPressed: onToggle,
        icon: Icon(isDark ? Icons.brightness_high : Icons.brightness_6),
        label: Text(isDark ? 'Mode clair' : 'Mode sombre'),
        style: TextButton.styleFrom(foregroundColor: Colors.white70),
      ),
    );
  }
}
