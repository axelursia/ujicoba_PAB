import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Default to "on"
  String _language = 'Indonesia'; // Default language

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load user preferences when the screen is initialized
  }

  // Fungsi untuk memuat preferensi pengguna dari SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'Indonesia';
    });
  }

  // Fungsi untuk menyimpan pengaturan
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('language', _language);
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
      context,
      '/login',
    ); // Ganti dengan route ke login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Bagian Profil
            ListTile(
              title: Text('Informasi Pribadi'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigasi ke halaman Edit Profil
                Navigator.pushNamed(context, '/editProfile');
              },
            ),
            Divider(),

            // Bagian Notifikasi
            SwitchListTile(
              title: Text('Notifikasi'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings(); // Simpan pengaturan notifikasi
              },
              secondary: Icon(
                _notificationsEnabled
                    ? Icons.notifications
                    : Icons.notifications_off,
              ),
            ),
            Divider(),

            // Bagian Bahasa
            ListTile(
              title: Text('Bahasa'),
              subtitle: Text(_language),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                // Pilih bahasa
                final selectedLanguage = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text('Pilih Bahasa'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 'Indonesia');
                          },
                          child: Text('Indonesia'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 'English');
                          },
                          child: Text('English'),
                        ),
                      ],
                    );
                  },
                );

                if (selectedLanguage != null) {
                  setState(() {
                    _language = selectedLanguage;
                  });
                  _saveSettings(); // Simpan pengaturan bahasa
                }
              },
            ),
            Divider(),

            // Bagian Kebijakan Privasi
            ListTile(
              title: Text('Kebijakan Privasi'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Tampilkan kebijakan privasi
                Navigator.pushNamed(context, '/privacyPolicy');
              },
            ),
            Divider(),

            // Bagian Hubungi Kami
            ListTile(
              title: Text('Hubungi Kami'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Tampilkan informasi kontak
                Navigator.pushNamed(context, '/contactUs');
              },
            ),
            Divider(),

            // Bagian Logout
            ListTile(
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
