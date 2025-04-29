import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Tambahan untuk ambil foto dari galeri
import '../database/db_helper.dart';
import '../services/pref_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  String email = '';
  File? _imageFile;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final savedEmail = await PrefService.getEmail();
    final savedName = await PrefService.getName();
    final savedProfilePath = await PrefService.getProfileImagePath();
    setState(() {
      email = savedEmail ?? '';
      nameController.text = savedName ?? '';
      _profileImagePath = savedProfilePath;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _profileImagePath = pickedFile.path;
      });
      await PrefService.saveProfileImagePath(pickedFile.path);
    }
  }

  Future<void> _updateProfile() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    await DBHelper.updateUserName(email, newName);
    await PrefService.saveLogin(email, newName);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Nama berhasil diperbarui')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // bisa klik untuk pilih gambar dari galeri
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage('assets/profile_avatar.png')
                            as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
