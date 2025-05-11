import 'package:flutter/material.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({Key? key}) : super(key: key);

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _notifikasiNyala = true;
  String _bahasa = 'Indonesia';

  void _navigateToInformasiPribadi() {
    Navigator.pushNamed(context, '/informasi_pribadi');
  }

  void _navigateToHubungiKami() {
    Navigator.pushNamed(context, '/hubungi_kami');
  }

  void _navigateToKebijakanPrivasi() {
    Navigator.pushNamed(context, '/kebijakan_privasi');
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _tampilkanDialogBahasa() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Bahasa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Indonesia'),
                value: 'Indonesia',
                groupValue: _bahasa,
                onChanged: (val) {
                  setState(() {
                    _bahasa = val!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _bahasa,
                onChanged: (val) {
                  setState(() {
                    _bahasa = val!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
    Color? trailingColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: TextStyle(
                color: trailingColor ?? Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.person,
                    title: 'Informasi Pribadi',
                    onTap: _navigateToInformasiPribadi,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary:
                        const Icon(Icons.notifications, color: Colors.black87),
                    title: const Text('Notifikasi'),
                    value: _notifikasiNyala,
                    onChanged: (val) {
                      setState(() {
                        _notifikasiNyala = val;
                      });
                      // Simpan preferensi notifikasi jika diperlukan
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.language,
                    title: 'Bahasa',
                    trailingText: _bahasa,
                    trailingColor: Colors.red,
                    onTap: _tampilkanDialogBahasa,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.contact_mail,
                    title: 'Hubungi Kami',
                    onTap: _navigateToHubungiKami,
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.privacy_tip,
                    title: 'Kebijakan Privasi',
                    onTap: _navigateToKebijakanPrivasi,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _logout,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
