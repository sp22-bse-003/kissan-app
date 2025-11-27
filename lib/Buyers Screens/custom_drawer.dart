import 'package:flutter/material.dart';
import 'dart:io';
import 'orders_screen.dart';
import 'liked_articles_screen.dart';
import '../screens/sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import 'package:kissan/localization/locale_controller.dart';
import '../Seller/main 1.dart';
import 'package:kissan/core/services/auth_service.dart';

class CustomDrawer extends StatefulWidget {
  final String? imagePath;
  const CustomDrawer({super.key, this.imagePath});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _authService = AuthService.instance;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _authService.currentUser;
      final userId = currentUser?.uid;

      if (userId != null) {
        // Get from Firestore
        final data = await _authService.getUserData(userId);

        if (mounted) {
          setState(() {
            if (data != null && data.isNotEmpty) {
              _userData = data;
            } else {
              // Use Firebase Auth data as fallback
              _userData = {
                'name': currentUser?.displayName ?? 'User',
                'phone': currentUser?.phoneNumber ?? '',
                'profilePicture': currentUser?.photoURL,
              };
            }
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } catch (e) {
      debugPrint('Drawer load error: $e');
      if (mounted) {
        setState(() {
          _userData = {
            'name': _authService.currentUser?.displayName ?? 'User',
            'phone': _authService.currentUser?.phoneNumber ?? '',
          };
          _loading = false;
        });
      }
    }
  }

  Future<void> _launchYouTubeVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF4CAF50);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 40, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                _loading
                                    ? Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey[500],
                                      ),
                                    )
                                    : (_userData?['profilePicture'] != null
                                        ? Image.network(
                                          _userData!['profilePicture'],
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.grey[500],
                                              ),
                                            );
                                          },
                                        )
                                        : Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey[500],
                                          ),
                                        )),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _loading
                                  ? 'Loading...'
                                  : (_userData?['name'] ?? 'User'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _loading ? '' : (_userData?['phone'] ?? ''),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person_add,
                    label: AppLocalizations.of(context)!.becomeSeller,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SellerStart()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.help_outline,
                    label: AppLocalizations.of(context)!.howToUse,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _launchYouTubeVideo(
                        'https://www.youtube.com/watch?v=he-aCCA2ONI',
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.language,
                    label: AppLocalizations.of(context)!.changeLanguage,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      _showLanguageSelectionDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.favorite,
                    label: AppLocalizations.of(context)!.likedArticles,
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LikedArticlesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.receipt_long,
                    label: AppLocalizations.of(context)!.myOrders,
                    color: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey.withOpacity(0.3)),
                  SizedBox(height: 16),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.logout,
                    label: AppLocalizations.of(context)!.logout,
                    color: Colors.grey[700]!,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutConfirmationDialog(context);
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isLogout
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isLogout ? Colors.red.withOpacity(0.2) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isLogout ? Colors.red : color, size: 22),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.red.withOpacity(0.7) : Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context: context,
                language: AppLocalizations.of(context)!.english,
                flag: '🇺🇸',
                onTap: () {
                  Navigator.pop(context);
                  AppLocaleController.setLocale(const Locale('en'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.languageSetEnglish,
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              Divider(),
              _buildLanguageOption(
                context: context,
                language: AppLocalizations.of(context)!.urdu,
                flag: '🇵🇰',
                onTap: () {
                  Navigator.pop(context);
                  AppLocaleController.setLocale(const Locale('ur'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.languageSetUrdu,
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String language,
    required String flag,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24)),
      title: Text(
        language,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.logoutConfirmation,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppLocalizations.of(context)!.areYouSureLogout,
            style: GoogleFonts.poppins(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.no,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.yes,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
