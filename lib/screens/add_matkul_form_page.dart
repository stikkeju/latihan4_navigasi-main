import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

// Halaman untuk menambah atau mengedit data mata kuliah
class AddMatkulFormPage extends StatefulWidget {
  final MataKuliah? mataKuliah;

  const AddMatkulFormPage({super.key, this.mataKuliah});

  @override
  State<AddMatkulFormPage> createState() => _AddMatkulFormPageState();
}

class _AddMatkulFormPageState extends State<AddMatkulFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _sksController;
  late TextEditingController _dosenController;
  late TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.mataKuliah?.nama ?? '',
    );
    _sksController = TextEditingController(
      text: widget.mataKuliah != null ? widget.mataKuliah!.sks.toString() : '',
    );
    _dosenController = TextEditingController(
      text: widget.mataKuliah?.dosen ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.mataKuliah?.deskripsi ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sksController.dispose();
    _dosenController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mataKuliah != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header kustom dengan tombol kembali
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kembali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      isEditing ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi detail mata kuliah di bawah ini',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Form Input Nama Mata Kuliah
                    const Text(
                      'Nama Mata Kuliah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Pemrograman Mobile',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        prefixIcon: const Icon(Icons.book_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nama mata kuliah tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Form Input SKS dan Nama Dosen
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SKS',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _sksController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (int.tryParse(value) == null) {
                                      return 'Angka';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nama Dosen',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _dosenController,
                                decoration: InputDecoration(
                                  hintText: 'Nama Dosen Pengampu',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Form Input Deskripsi (Opsional)
                    const Text(
                      'Deskripsi (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan atau deskripsi...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan Mata Kuliah
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final matkul = MataKuliah(
                              id: widget.mataKuliah?.id,
                              nama: _nameController.text,
                              sks: int.tryParse(_sksController.text) ?? 0,
                              dosen: _dosenController.text,
                              deskripsi: _deskripsiController.text,
                            );

                            if (isEditing) {
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).updateMataKuliah(matkul);
                            } else {
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).addMataKuliah(matkul);
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Tambah Mata Kuliah',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Delete logic
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Mata Kuliah?'),
                                content: const Text(
                                  'Tindakan ini tidak dapat dibatalkan.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Provider.of<UserProvider>(
                                        context,
                                        listen: false,
                                      ).deleteMataKuliah(
                                        widget.mataKuliah!.id!,
                                      );
                                      Navigator.pop(context); // Dialog
                                      Navigator.pop(context); // Page
                                    },
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hapus Mata Kuliah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
