import 'dart:io';
import 'package:ujk/screens/absen_keluar_lokasi_screen.dart';
import 'package:ujk/screens/absen_masuk_lokasi_screen.dart';
import 'package:ujk/screens/edit_profile_screen.dart';
import 'package:ujk/screens/history_screen.dart';
import 'package:ujk/screens/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../services/pref_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? _absenMasukTime;
  String? _absenKeluarTime;
  String _statusHarian = 'Loading status...';
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    _loadUserName();
    _loadProfileImage();
  }

  void _loadUserName() async {
    final name = await PrefService.getName();
    setState(() {
      userName = name;
    });
  }

  void _loadProfileImage() async {
    final path = await PrefService.getProfileImagePath();
    setState(() {
      profileImagePath = path;
    });
  }

  void _loadTodayAttendance() async {
    final email = await PrefService.getEmail();
    final now = DateTime.now();
    String today = DateFormat('yyyy-MM-dd').format(now);

    final db = await DBHelper.initDb();
    final result = await db.query(
      'attendance',
      where: 'date = ? AND user_email = ?',
      whereArgs: [today, email],
    );

    String? masuk;
    String? keluar;
    bool hasIzin = false;

    for (var item in result) {
      if (item['type'] == 'Masuk') {
        masuk = item['time']?.toString();
      } else if (item['type'] == 'Keluar') {
        keluar = item['time']?.toString();
      } else if (item['type'] == 'Izin') {
        hasIzin = true;
      }
    }

    String status = 'Anda belum absen hari ini.';
    if (hasIzin) {
      status = 'Anda sudah mengajukan Izin hari ini.';
    } else if (masuk != null && keluar != null) {
      status = 'Anda sudah absen Masuk dan Keluar hari ini.';
    } else if (masuk != null) {
      status = 'Anda sudah absen Masuk hari ini.';
    }

    setState(() {
      _absenMasukTime = masuk;
      _absenKeluarTime = keluar;
      _statusHarian = status;
    });
  }

  void _logout(BuildContext context) async {
    await PrefService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '🗓️ Absensi Hari Ini',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Halo, ${userName ?? "User"} 👋',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            DateFormat(
                              'EEEE, dd MMMM yyyy',
                            ).format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 35, 35, 35),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _statusHarian,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.login,
                                  color:
                                      _absenMasukTime != null
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Masuk:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _absenMasukTime ?? 'Belum Absen',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    _absenMasukTime != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color:
                                      _absenKeluarTime != null
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Keluar:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _absenKeluarTime ?? 'Belum Absen',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    _absenKeluarTime != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: -10,
                      left: -15,
                      child: Image.asset(
                        'assets/logo_no_bg.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 0,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            profileImagePath != null
                                ? FileImage(File(profileImagePath!))
                                : const AssetImage('assets/profile_avatar.png')
                                    as ImageProvider,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.login,
                    label: 'Absen Masuk',
                    color: Colors.lightGreenAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AbsenMasukLokasiScreen(),
                        ),
                      ).then((value) => _loadTodayAttendance());
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.logout,
                    label: 'Absen Keluar',
                    color: Colors.yellowAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AbsenKeluarLokasiScreen(),
                        ),
                      ).then((value) => _loadTodayAttendance());
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.history,
                    label: 'Riwayat Absensi',
                    color: Colors.indigoAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      ).then((value) => _loadTodayAttendance());
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.edit,
                    label: 'Edit Profile',
                    color: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ).then((value) {
                        _loadUserName();
                        _loadProfileImage();
                      });
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.exit_to_app,
                    label: 'Logout',
                    color: Colors.redAccent,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
