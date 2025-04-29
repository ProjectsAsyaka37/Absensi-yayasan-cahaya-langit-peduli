import 'package:ujk/layouting/custom_scaffold.dart';
import 'package:ujk/layouting/welcome_button.dart';
import 'package:ujk/screens/login_screen.dart';
import 'package:ujk/screens/signup_screen.dart';
import 'package:ujk/theme/theme.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;

    return CustomScaffold(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenSize.height),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Welcome text section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 30.0,
                  ),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Image.asset(
                              'assets/logo_no_bg.png',
                              width: 200,
                              height: 200,
                            ),
                          ),
                          WidgetSpan(child: SizedBox(height: 16)),
                          TextSpan(
                            text: 'ABSENSI YCALP!\n',
                            style: TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                '\nWeelcome kawan Ycalp, mari mulai hari dengan senyuman',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Spacer to push buttons to bottom when possible
                const Spacer(),

                // Button section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: WelcomeButton(
                          buttonText: 'log in',
                          onTap: LoginScreen(),
                          color: Colors.transparent,
                          textColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: WelcomeButton(
                          buttonText: 'Sign up',
                          onTap: Signupscreen(),
                          color: Colors.white,
                          textColor: lightColorScheme.primary,
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
    );
  }
}
