import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_page_header.dart';

// Halaman untuk membuat atau mengedit deadline tugas
class AddTugasFormPage extends StatefulWidget {
  final Tugas? tugas;

  const AddTugasFormPage({super.key, this.tugas});

  @override
  _AddTugasFormPageState createState() => _AddTugasFormPageState();
}

class _AddTugasFormPageState extends State<AddTugasFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tugasController = TextEditingController();
  String? _selectedMK;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = 'sedang';
  bool _isReminderActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.tugas != null) {
      _tugasController.text = widget.tugas!.deskripsi;
      _selectedMK = widget.tugas!.mataKuliah;
      _selectedDate = widget.tugas!.tanggal;
      _selectedTime = widget.tugas!.waktu;
      _selectedPriority = widget.tugas!.priority;
      _isReminderActive = widget.tugas!.isReminderActive;
    }
  }

  @override
  void dispose() {
    _tugasController.dispose();
    super.dispose();
  }

  // Menampilkan picker tanggal deadline
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Menampilkan picker waktu deadline
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Theme(
            data: ThemeData.light().copyWith(
              useMaterial3:
                  false, // Try Material 2 for potentially looser constraints
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                helpTextStyle: const TextStyle(fontSize: 12),
                inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  filled: false,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // Validasi dan simpan data tugas ke provider
  void _saveTugas() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon pilih tanggal deadline')),
        );
        return;
      }

      final tugas = Tugas(
        id: widget.tugas?.id, // Keep ID if editing
        deskripsi: _tugasController.text,
        mataKuliah: _selectedMK,
        tanggal: _selectedDate,
        waktu: _selectedTime,
        priority: _selectedPriority,
        isReminderActive: _isReminderActive,
        selesai: widget.tugas?.selesai ?? false,
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (widget.tugas != null) {
        // Find index. Ideally we use ID, but for now we look up by object or index passed?
        // Wait, UserProvider.updateTugas takes an index currently.
        // We probably need to change logic to find index by ID or pass index.
        // For this refactor, let's assume we find it by ID if ID exists or fallback.
        // But since we don't have updateById, we must rely on finding index.
        final index = userProvider.tugasList.indexOf(widget.tugas!);
        if (index != -1) {
          userProvider.updateTugas(index, tugas);
        }
      } else {
        userProvider.addTugas(tugas);
      }

      // Schedule notifications
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).scheduleAllNotifications(context);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan tombol kembali
            const CustomPageHeader(title: 'Kembali'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tugas != null ? 'Edit Tugas' : 'Tambah Tugas',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lengkapi detail tugas di bawah ini',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Input Judul Tugas
                      const Text(
                        'Judul Tugas',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tugasController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan judul tugas..',
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
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Judul tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Pilih Mata Kuliah Terkait
                      const Text(
                        'Mata Kuliah',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedMK,
                            items: userProvider.mataKuliahList.map((mk) {
                              return DropdownMenuItem(
                                value: mk.nama,
                                child: Text(mk.nama),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedMK = value),
                            decoration: InputDecoration(
                              hintText: 'Pilih Matkul',
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
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pilihan Tanggal dan Waktu Deadline
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deadline',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedDate == null
                                              ? 'dd / mm / yy'
                                              : DateFormat(
                                                  'dd / MM / yy',
                                                ).format(_selectedDate!),
                                          style: TextStyle(
                                            color: _selectedDate == null
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Waktu',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickTime,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedTime == null
                                              ? '00:00'
                                              : _selectedTime!.format(context),
                                          style: TextStyle(
                                            color: _selectedTime == null
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Pilihan Tingkat Prioritas
                      const Text(
                        'Prioritas',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityButton('Rendah', 'rendah'),
                          const SizedBox(width: 12),
                          _buildPriorityButton('Sedang', 'sedang'),
                          const SizedBox(width: 12),
                          _buildPriorityButton('Tinggi', 'tinggi'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Toggle Aktifkan Notifikasi Pengingat
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_none),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Atur Notifikasi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Dapatkan notifikasi tugas sebelum deadline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isReminderActive,
                              onChanged: (val) =>
                                  setState(() => _isReminderActive = val),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Simpan Tugas
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTugas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.tugas != null
                                ? 'Simpan Perubahan'
                                : 'Tambah Tugas',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tombol pilihan prioritas (Rendah, Sedang, Tinggi)
  Widget _buildPriorityButton(String label, String value) {
    final isSelected = _selectedPriority == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (value == 'tinggi'
                      ? const Color(0xFFEF5350)
                      : value == 'sedang'
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF4CAF50))
                : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}
