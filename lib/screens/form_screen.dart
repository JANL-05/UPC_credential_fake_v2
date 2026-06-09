import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import 'credential_screen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _bannerCtrl = TextEditingController();
  final _careerCtrl = TextEditingController();
  final _campusCtrl = TextEditingController();

  // State
  File? _photo;
  DateTime? _baseDate;
  TimeOfDay? _startTime;

  final _picker = ImagePicker();

  // ── Claves SharedPreferences ──
  static const _kName   = 'saved_name';
  static const _kCode   = 'saved_code';
  static const _kBanner = 'saved_banner';
  static const _kCareer = 'saved_career';
  static const _kCampus = 'saved_campus';
  static const _kDate   = 'saved_date';
  static const _kTime   = 'saved_time';
  static const _kPhoto  = 'saved_photo';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text   = prefs.getString(_kName)   ?? '';
      _codeCtrl.text   = prefs.getString(_kCode)   ?? '';
      _bannerCtrl.text = prefs.getString(_kBanner) ?? '';
      _careerCtrl.text = prefs.getString(_kCareer) ?? '';
      _campusCtrl.text = prefs.getString(_kCampus) ?? '';

      final dateStr = prefs.getString(_kDate);
      if (dateStr != null) _baseDate = DateTime.tryParse(dateStr);

      final timeStr = prefs.getString(_kTime);
      if (timeStr != null) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          _startTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }

      final photoPath = prefs.getString(_kPhoto);
      if (photoPath != null && File(photoPath).existsSync()) {
        _photo = File(photoPath);
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName,   _nameCtrl.text.trim().toUpperCase());
    await prefs.setString(_kCode,   _codeCtrl.text.trim().toUpperCase());
    await prefs.setString(_kBanner, _bannerCtrl.text.trim().toUpperCase());
    await prefs.setString(_kCareer, _careerCtrl.text.trim().toUpperCase());
    await prefs.setString(_kCampus, _campusCtrl.text.trim());
    if (_baseDate != null) {
      await prefs.setString(_kDate, _baseDate!.toIso8601String());
    }
    if (_startTime != null) {
      await prefs.setString(_kTime, '${_startTime!.hour}:${_startTime!.minute}');
    }
    if (_photo != null) {
      await prefs.setString(_kPhoto, _photo!.path);
    }
  }

  // ────────── helpers ──────────

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFF7B68EE)),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final xFile = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 85);
                if (xFile != null) {
                  setState(() => _photo = File(xFile.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFF7B68EE)),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final xFile = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 85);
                if (xFile != null) {
                  setState(() => _photo = File(xFile.path));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF7B68EE),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _baseDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF7B68EE),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_baseDate == null) {
      _snack('Selecciona la fecha base');
      return;
    }
    if (_startTime == null) {
      _snack('Selecciona la hora inicial');
      return;
    }

    await _saveData();

    final model = StudentModel(
      photo: _photo,
      fullName: _nameCtrl.text.trim().toUpperCase(),
      studentCode: _codeCtrl.text.trim().toUpperCase(),
      idBanner: _bannerCtrl.text.trim().toUpperCase(),
      career: _careerCtrl.text.trim().toUpperCase(),
      campus: _campusCtrl.text.trim(),
      baseDate: _baseDate!,
      startTime: _startTime!,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CredentialScreen(student: model)),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _bannerCtrl.dispose();
    _careerCtrl.dispose();
    _campusCtrl.dispose();
    super.dispose();
  }

  // ────────── build ──────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Configurar Credencial',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2D3142)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto de perfil ──
              _SectionLabel('Foto de Perfil'),
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: const Color(0xFFDCDAFA),
                        backgroundImage:
                            _photo != null ? FileImage(_photo!) : null,
                        child: _photo == null
                            ? const Icon(Icons.person_rounded,
                                size: 52, color: Color(0xFF7B68EE))
                            : null,
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE31937),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Nombre ──
              _SectionLabel('Nombre y Apellido'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction((old, nw) =>
                      nw.copyWith(text: nw.text.toUpperCase()))
                ],
                decoration: const InputDecoration(
                    hintText: 'Ej: JUAN PÉREZ GÓMEZ',
                    prefixIcon: Icon(Icons.badge_rounded,
                        color: Color(0xFF7B68EE))),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Código alumno ──
              _SectionLabel('Código de Alumno'),
              TextFormField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction((old, nw) =>
                      nw.copyWith(text: nw.text.toUpperCase())),
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                    hintText: 'Ej: U202314616',
                    prefixIcon: Icon(Icons.tag_rounded,
                        color: Color(0xFF7B68EE))),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── ID Banner ──
              _SectionLabel('ID Banner'),
              TextFormField(
                controller: _bannerCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction((old, nw) =>
                      nw.copyWith(text: nw.text.toUpperCase())),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                    hintText: 'Ej: N04242213',
                    prefixIcon: Icon(Icons.numbers_rounded,
                        color: Color(0xFF7B68EE))),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Carrera ──
              _SectionLabel('Carrera'),
              TextFormField(
                controller: _careerCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction((old, nw) =>
                      nw.copyWith(text: nw.text.toUpperCase()))
                ],
                decoration: const InputDecoration(
                    hintText: 'Ej: MEDICINA',
                    prefixIcon: Icon(Icons.school_rounded,
                        color: Color(0xFF7B68EE))),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Campus ──
              _SectionLabel('Campus'),
              TextFormField(
                controller: _campusCtrl,
                decoration: const InputDecoration(
                    hintText: 'Ej: Campus Villa',
                    prefixIcon: Icon(Icons.location_city_rounded,
                        color: Color(0xFF7B68EE))),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Fecha base ──
              _SectionLabel('Fecha Base'),
              _TapField(
                icon: Icons.calendar_today_rounded,
                text: _baseDate == null
                    ? 'Seleccionar fecha…'
                    : DateFormat('EEEE, dd MMM yyyy', 'es')
                        .format(_baseDate!)
                        .capitalizeFirst(),
                onTap: _pickDate,
                isEmpty: _baseDate == null,
              ),
              const SizedBox(height: 14),

              // ── Hora inicial ──
              _SectionLabel('Hora Inicial'),
              _TapField(
                icon: Icons.access_time_rounded,
                text: _startTime == null
                    ? 'Seleccionar hora…'
                    : _startTime!.format(context),
                onTap: _pickTime,
                isEmpty: _startTime == null,
              ),
              const SizedBox(height: 32),

              // ── Botón ──
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.credit_card_rounded),
                label: const Text('GENERAR CREDENCIAL'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Widgets helper internos
// ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF757575),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isEmpty;

  const _TapField({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7B68EE), size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isEmpty
                    ? Colors.grey.shade400
                    : const Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Extension util
// ──────────────────────────────────────────────────────────────
extension StringCapitalize on String {
  String capitalizeFirst() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
