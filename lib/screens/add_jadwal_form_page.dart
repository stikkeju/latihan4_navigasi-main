import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_page_header.dart';

// Halaman untuk menambah atau mengedit jadwal kuliah
class AddJadwalFormPage extends StatefulWidget {
  final Jadwal? jadwal;

  const AddJadwalFormPage({super.key, this.jadwal});

  @override
  State<AddJadwalFormPage> createState() => _AddJadwalFormPageState();
}

class _AddJadwalFormPageState extends State<AddJadwalFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMatkulNama;
  String? _selectedJenis;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  late TextEditingController _ruanganController;

  @override
  void initState() {
    super.initState();
    _ruanganController = TextEditingController(
      text: widget.jadwal?.ruangan ?? '',
    );

    if (widget.jadwal != null) {
      _selectedMatkulNama = widget.jadwal!.mataKuliah;
      _selectedJenis = widget.jadwal!.jenis;
      // Parse date dan times jika ada
      if (widget.jadwal!.tanggal != null &&
          widget.jadwal!.tanggal!.isNotEmpty) {
        try {
          _selectedDate = DateFormat(
            'yyyy-MM-dd',
          ).parse(widget.jadwal!.tanggal!);
        } catch (e) {
          _selectedDate = DateTime.now();
        }
      }

      _selectedStartTime = _parseTime(widget.jadwal!.jamMulai);
      _selectedEndTime = _parseTime(widget.jadwal!.jamSelesai);
    }
  }

  // Membantu parsing string jam "HH:mm" ke TimeOfDay
  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _ruanganController.dispose();
    super.dispose();
  }

  // Menampilkan dialog pemilihan tanggal
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

  // Menampilkan dialog pemilihan waktu (jam mulai/selesai)
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_selectedStartTime ?? TimeOfDay.now())
          : (_selectedEndTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Theme(
            data: ThemeData.light().copyWith(
              useMaterial3: false,
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
      setState(() {
        if (isStart) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.jadwal != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan tombol kembali
            const CustomPageHeader(title: 'Kembali'),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Atur jadwal kuliah Anda',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Dropdown pilihan Mata Kuliah
                    const Text(
                      'Mata Kuliah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final matkulList = userProvider.mataKuliahList;
                        return DropdownButtonFormField<String>(
                          value: _selectedMatkulNama,
                          items: matkulList.map((mk) {
                            return DropdownMenuItem(
                              value: mk.nama,
                              child: Text(mk.nama),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedMatkulNama = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Pilih Mata Kuliah',
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
                          validator: (value) =>
                              value == null ? 'Pilih mata kuliah' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dropdown pilihan Jenis Kegiatan (Kuliah, Praktikum, dll)
                    const Text(
                      'Jenis Kegiatan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedJenis,
                      items:
                          [
                            'Kuliah',
                            'Praktikum',
                            'Seminar',
                            'Ujian',
                            'Lainnya',
                          ].map((jenis) {
                            return DropdownMenuItem(
                              value: jenis,
                              child: Text(jenis),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedJenis = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Pilih Jenis Kegiatan',
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
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      validator: (value) =>
                          value == null ? 'Pilih jenis kegiatan' : null,
                    ),
                    const SizedBox(height: 20),

                    // Picker untuk Tanggal
                    const Text(
                      'Tanggal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal'
                                  : DateFormat(
                                      'EEEE, d MMMM yyyy',
                                      'id_ID',
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
                    const SizedBox(height: 20),

                    // Picker untuk Jam Mulai dan Selesai
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Mulai',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _pickTime(true),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedStartTime == null
                                            ? '--:--'
                                            : _selectedStartTime!.format(
                                                context,
                                              ),
                                        style: TextStyle(
                                          color: _selectedStartTime == null
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
                                'Jam Selesai',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _pickTime(false),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_filled,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedEndTime == null
                                            ? '--:--'
                                            : _selectedEndTime!.format(context),
                                        style: TextStyle(
                                          color: _selectedEndTime == null
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

                    // Input nama ruangan
                    const Text(
                      'Ruangan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ruanganController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: R.304',
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
                        prefixIcon: const Icon(Icons.room_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan Jadwal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih tanggal')),
                              );
                              return;
                            }
                            if (_selectedStartTime == null ||
                                _selectedEndTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih waktu')),
                              );
                              return;
                            }

                            final provider = Provider.of<UserProvider>(
                              context,
                              listen: false,
                            );
                            // Find matching MK to get ID
                            final selectedMk = provider.mataKuliahList
                                .firstWhere(
                                  (mk) => mk.nama == _selectedMatkulNama,
                                  orElse: () => MataKuliah(id: 0, nama: ''),
                                );

                            final jadwal = Jadwal(
                              id: widget.jadwal?.id,
                              mkId: selectedMk.id ?? 0,
                              mataKuliah: _selectedMatkulNama!,
                              hari: DateFormat(
                                'EEEE',
                                'id_ID',
                              ).format(_selectedDate!),
                              tanggal: DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDate!),
                              jamMulai:
                                  '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}',
                              jamSelesai:
                                  '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}',
                              ruangan: _ruanganController.text,
                              jenis: _selectedJenis,
                            );

                            if (isEditing) {
                              final index = provider.jadwalList.indexWhere(
                                (j) => j.id == jadwal.id,
                              );
                              if (index != -1) {
                                provider.updateJadwal(index, jadwal);
                              }
                            } else {
                              provider.addJadwal(jadwal);
                            }

                            // Schedule notifications
                            Provider.of<NotificationProvider>(
                              context,
                              listen: false,
                            ).scheduleAllNotifications(context);

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
                          isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
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
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Jadwal?'),
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
                                      final provider =
                                          Provider.of<UserProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final index = provider.jadwalList
                                          .indexWhere(
                                            (j) => j.id == widget.jadwal!.id,
                                          );
                                      if (index != -1) {
                                        provider.deleteJadwal(index);
                                        // Update notifications
                                        Provider.of<NotificationProvider>(
                                          context,
                                          listen: false,
                                        ).scheduleAllNotifications(context);
                                      }
                                      Navigator.pop(context);
                                      Navigator.pop(context);
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
                            'Hapus Jadwal',
                            style: const TextStyle(
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
