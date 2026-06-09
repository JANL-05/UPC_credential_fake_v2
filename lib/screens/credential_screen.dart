import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';

class CredentialScreen extends StatefulWidget {
  final StudentModel student;
  const CredentialScreen({super.key, required this.student});

  @override
  State<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends State<CredentialScreen>
    with TickerProviderStateMixin {
  // ── Reloj ──
  late DateTime _currentTime;
  late Timer _timer;

  // ── Nubes animadas ──
  late AnimationController _cloudController;
  late Animation<double> _cloudOffset;

  @override
  void initState() {
    super.initState();

    // Reloj: arranca desde la hora configurada en el formulario
    final now = DateTime.now();
    _currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.student.startTime.hour,
      widget.student.startTime.minute,
      0,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = _currentTime.add(const Duration(seconds: 1));
      });
    });

    // Nubes: loop infinito de derecha → izquierda (10 seg/ciclo)
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _cloudOffset =
        Tween<double>(begin: 0.0, end: 1.0).animate(_cloudController);
  }

  @override
  void dispose() {
    _timer.cancel();
    _cloudController.dispose();
    super.dispose();
  }

  // ── Getters ──
  String get _timeString => DateFormat('HH:mm:ss').format(_currentTime);

  String get _dateString {
    final d = widget.student.baseDate;
    final raw = DateFormat('EEEE, dd MMM yyyy', 'es').format(d);
    return raw[0].toUpperCase() + raw.substring(1);
  }

  /// "BRANDON AARON RODRIGUEZ MARTINEZ"
  ///   → firstNames  = "BRANDON AARON"
  ///   → maskedNames = "R*** M***"
  (String firstNames, String maskedNames) _splitName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts[0], '');
    if (parts.length == 2) return (parts[0], '${parts[1][0]}***');
    final firstNames = parts.take(2).join(' ');
    final masked =
        parts.skip(2).map((w) => '${w[0].toUpperCase()}***').join(' ');
    return (firstNames, masked);
  }

  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final (firstNames, maskedNames) = _splitName(s.fullName);

    return Scaffold(
      // Capa 1 — Fondo base lavanda (se asoma detrás de la tarjeta)
      backgroundColor: const Color(0xFFEAE9FC),

      // ─── AppBar ───────────────────────────────────────────────
      // El AppBar es parte de la zona superior blanca
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 44,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFFE31937),
            size: 34,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // ⚡ Bebas Neue solo para el título del AppBar
        title: const Text(
          'TIU VIRTUAL',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 22,
            color: Color(0xFF1A1A2E),
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: Column(
        children: [
          // ══════════════════════════════════════════════════════
          // Capa 2 — Zona Superior BLANCA
          // (AppBar ya usa Colors.white, esta sección continúa ese fondo)
          // ══════════════════════════════════════════════════════
          Expanded(
            flex: 55,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 6),

                  // ── 1. Reloj (solo hora) ──────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 52),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDAFA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _timeString,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3142),
                            fontFeatures: [FontFeature.tabularFigures()],
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),

                  // ── 2. Fecha (fuera del reloj) ────────────────
                  Text(
                    _dateString,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF5A5A8E),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── 3. Nubes animadas + Avatar ────────────────
                  // Capa 3 (nubes) sobre fondo blanco; Avatar encima
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Nubes en movimiento (seamless: 2 copias)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _cloudOffset,
                            builder: (_, __) => CustomPaint(
                              painter: _CloudPainter(_cloudOffset.value),
                            ),
                          ),
                        ),
                        // Avatar estático por encima de las nubes
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: const Color(0xFFDCDAFA),
                            backgroundImage: s.photo != null
                                ? FileImage(s.photo!)
                                : null,
                            child: s.photo == null
                                ? const Icon(Icons.person_rounded,
                                    size: 58, color: Color(0xFF7B68EE))
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════
          // Capa 4 — Zona Inferior LAVANDA + Tarjeta Flotante
          // El fondo lavanda se asoma por los márgenes de la tarjeta
          // ══════════════════════════════════════════════════════
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ⚡ Bebas Neue: Nombre (línea 1)
                    Text(
                      firstNames,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 40,
                        color: Color(0xFFE31937),
                        letterSpacing: 1.0,
                        height: 1.05,
                      ),
                    ),
                    // ⚡ Bebas Neue: Apellidos enmascarados (línea 2)
                    if (maskedNames.isNotEmpty)
                      Text(
                        maskedNames,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 40,
                          color: Color(0xFFE31937),
                          letterSpacing: 1.0,
                          height: 1.05,
                        ),
                      ),
                    const SizedBox(height: 12),

                    // ── Código de alumno ──
                    const Text(
                      'Código de alumno:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      s.studentCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3142),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── ID Banner ──
                    const Text(
                      'ID Banner:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      s.idBanner,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3142),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Carrera ──
                    Text(
                      s.career,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Campus ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_pin,
                            color: Color(0xFFE31937), size: 15),
                        const SizedBox(width: 3),
                        Text(
                          s.campus,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ), // SingleChildScrollView
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Spec de cada nube independiente
// ──────────────────────────────────────────────────────────────────
class _CloudSpec {
  final double yFraction;  // posición Y relativa al área (0.0 – 1.0)
  final double scale;      // tamaño de la nube
  final double phase;      // desfase inicial de la nube (0.0 – 1.0)

  const _CloudSpec({
    required this.yFraction,
    required this.scale,
    required this.phase,
  });
}

// 5 nubes independientes, fases equiespaciadas (0.2 apart)
// → siempre hay nubes repartidas por toda la pantalla
// → el reset de cada nube ocurre FUERA del área visible (no hay saltos)
const List<_CloudSpec> _cloudSpecs = [
  _CloudSpec(yFraction: 0.12, scale: 1.10, phase: 0.00),
  _CloudSpec(yFraction: 0.55, scale: 0.78, phase: 0.20),
  _CloudSpec(yFraction: 0.28, scale: 0.62, phase: 0.40),
  _CloudSpec(yFraction: 0.72, scale: 0.92, phase: 0.60),
  _CloudSpec(yFraction: 0.42, scale: 0.70, phase: 0.80),
];

// ──────────────────────────────────────────────────────────────────
// CustomPainter
//
// Cada nube tiene su propia "fase efectiva" = (progress + phase) % 1.
// La X de cada nube es:
//   cx = screenWidth - effectivePhase * (screenWidth + kBuffer)
//
// Cuando effectivePhase va de ~1.0 → 0.0, la nube salta de
// cx ≈ -kBuffer  (fuera por la izquierda)  a
// cx ≈ screenWidth (fuera por la derecha)
// → el salto es completamente invisible.
// ──────────────────────────────────────────────────────────────────
class _CloudPainter extends CustomPainter {
  final double progress;
  const _CloudPainter(this.progress);

  // Margen extra para que la nube esté completamente fuera antes de resetear
  static const double kBuffer = 350.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDCDAFA).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final travel = size.width + kBuffer;

    for (final spec in _cloudSpecs) {
      final effectivePhase = (progress + spec.phase) % 1.0;
      final cx = size.width - effectivePhase * travel + 150.0;
      final cy = size.height * spec.yFraction;
      _drawCloud(canvas, paint, cx, cy, spec.scale);
    }
  }

  void _drawCloud(Canvas canvas, Paint p, double cx, double cy, double s) {
    final r = 16.0 * s;
    canvas.drawCircle(Offset(cx,            cy),             r,        p);
    canvas.drawCircle(Offset(cx + r * 1.1,  cy - r * 0.35), r * 1.25, p);
    canvas.drawCircle(Offset(cx + r * 2.4,  cy),             r * 0.90, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - r * 0.15, cy, r * 2.85, r * 0.88),
        const Radius.circular(7),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(_CloudPainter old) => old.progress != progress;
}
