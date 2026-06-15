import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../controllers/manage_attendance/student_attendance_controller.dart';

// ── Shared Student Page Scaffold ──────────────────────────────────────────────

class StudentPageScaffold extends StatelessWidget {
  const StudentPageScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.onMenuTap,
    this.showBack = false,
    this.scaffoldKey,
    this.drawer,
  });

  final String title;
  final Widget child;
  final VoidCallback onMenuTap;
  final bool showBack;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: drawer,
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBF3CFF), Color(0xFF9B2EF4)],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: drawer != null
                        ? () => scaffoldKey?.currentState?.openDrawer()
                        : onMenuTap,
                    icon: Icon(
                      showBack ? Icons.arrow_back_rounded : Icons.menu_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5F5F),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ── Shared Purple Button ──────────────────────────────────────────────────────

class PurpleButton extends StatelessWidget {
  const PurpleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9B2EF4),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0x809B2EF4),
          elevation: 4,
          shadowColor: const Color(0x669B2EF4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// ── Shared GPS Dialog ─────────────────────────────────────────────────────────

class GpsDialog extends StatelessWidget {
  const GpsDialog({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4B66)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFFFEEF2),
            child: Icon(
              Icons.location_off_rounded,
              color: Color(0xFFFF4B66),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPS Location Error',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFFF4B66),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(54, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: const BorderSide(color: Color(0xFFFF4B66)),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 11, color: Color(0xFFFF4B66)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student Dashboard View ────────────────────────────────────────────────────

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({
    super.key,
    required this.controller,
    required this.onSwitchActor,
  });

  final StudentAttendanceController controller;
  final VoidCallback? onSwitchActor;

  @override
  Widget build(BuildContext context) {
    final student = controller.student!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBF3CFF), Color(0xFF7B2EE0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                student.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: onSwitchActor,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Switch',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            student.matricId,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              student.program,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ModuleTile(
                            icon: Icons.qr_code_scanner_rounded,
                            iconBackground: const Color(0xFFE8FFF3),
                            iconColor: const Color(0xFF10B769),
                            title: 'Submit Attendance',
                            subtitle: 'Scan QR or enter code',
                            onTap: controller.openSubmitAttendance,
                          ),
                          const SizedBox(height: 12),
                          _ModuleTile(
                            icon: Icons.bar_chart_rounded,
                            iconBackground: const Color(0xFFF2E3FF),
                            iconColor: const Color(0xFF9A35F4),
                            title: 'View Attendance Record',
                            subtitle: 'Check your attendance history',
                            onTap: controller.openAttendanceRecord,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 68,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      active: true,
                      color: const Color(0xFF9B2EF4),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      active: false,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Student Submit Attendance View ────────────────────────────────────────────

class StudentSubmitView extends StatefulWidget {
  const StudentSubmitView({
    super.key,
    required this.controller,
    this.scaffoldKey,
    this.drawer,
  });
  final StudentAttendanceController controller;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;

  @override
  State<StudentSubmitView> createState() => _StudentSubmitViewState();
}

class _StudentSubmitViewState extends State<StudentSubmitView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQr = widget.controller.inputMethod == AttendanceInputMethod.qrScan;

    return StudentPageScaffold(
      title: 'Attendance Check-In',
      onMenuTap: widget.controller.backToDashboard,
      scaffoldKey: widget.scaffoldKey,
      drawer: widget.drawer,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              if (widget.controller.showGpsError) ...[
                GpsDialog(
                  message: widget.controller.gpsMessage,
                  onRetry: widget.controller.retryGps,
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF9CCBFF)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF2F80ED),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'How to submit attendance:\n1. Make sure you are in the classroom\n2. Get the attendance code from your lecturer\n3. Scan QR code or enter the code manually',
                        style: TextStyle(
                          color: Color(0xFF2176D2),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Scan QR Code',
                        active: isQr,
                        onTap: () => widget.controller.setInputMethod(
                          AttendanceInputMethod.qrScan,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Enter Code',
                        active: !isQr,
                        onTap: () => widget.controller.setInputMethod(
                          AttendanceInputMethod.manualCode,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (isQr)
                _QrScannerPanel(
                  onScan: (code) => widget.controller.onQrCodeScanned(code),
                )
              else
                _ManualCodePanel(
                  textController: _codeController,
                  showInvalidCode: widget.controller.showInvalidCode,
                  onChanged: widget.controller.updateAttendanceCode,
                  onRetry: widget.controller.retryInvalidCode,
                ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: PurpleButton(
              label: 'Submit Attendance',
              isLoading: widget.controller.isLoading,
              onPressed: widget.controller.isLoading
                  ? null
                  : () async {
                      if (!isQr) await widget.controller.verifyAttendanceCode();
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF9B2EF4) : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QrScannerPanel extends StatefulWidget {
  const _QrScannerPanel({required this.onScan});
  final ValueChanged<String> onScan;

  @override
  State<_QrScannerPanel> createState() => _QrScannerPanelState();
}

class _QrScannerPanelState extends State<_QrScannerPanel> {
  MobileScannerController? _scannerController;
  bool _scanned = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(
        () => _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
      );
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QR Code Scanner',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: 240, child: _buildScanner()),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Position QR code within the camera frame',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildScanner() {
    if (_permissionDenied) {
      return Container(
        color: const Color(0xFF050509),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 40),
              SizedBox(height: 12),
              Text(
                'Camera permission denied.\nPlease enable in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    if (_scannerController == null) {
      return Container(
        color: const Color(0xFF050509),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController!,
          onDetect: (BarcodeCapture capture) {
            if (_scanned) return;
            for (final barcode in capture.barcodes) {
              final raw = barcode.rawValue;
              if (raw != null && raw.isNotEmpty) {
                _scanned = true;
                widget.onScan(raw);
                break;
              }
            }
          },
        ),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD36BFF), width: 2.5),
            ),
          ),
        ),
        const Positioned(
          bottom: 14,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Align QR code within the frame',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class _ManualCodePanel extends StatelessWidget {
  const _ManualCodePanel({
    required this.textController,
    required this.showInvalidCode,
    required this.onChanged,
    required this.onRetry,
  });

  final TextEditingController textController;
  final bool showInvalidCode;
  final ValueChanged<String> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendance Code',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: textController,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. ABC123',
            hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFFD1D5DB),
              letterSpacing: 2,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF9B2EF4), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Code is case-insensitive (6 characters)',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
          ),
        ),
        if (showInvalidCode) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFF4B66)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFFFF4B66),
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Invalid attendance code. Please try again.',
                    style: TextStyle(color: Color(0xFFFF4B66), fontSize: 12),
                  ),
                ),
                GestureDetector(
                  onTap: onRetry,
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Color(0xFFFF4B66),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Student Class Details Confirm View ────────────────────────────────────────

class StudentClassDetailsView extends StatelessWidget {
  const StudentClassDetailsView({super.key, required this.controller});
  final StudentAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final details = controller.classDetails!;

    return StudentPageScaffold(
      title: 'Attendance Check-In',
      onMenuTap: controller.openSubmitAttendance,
      showBack: true,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              const Text(
                'Class Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review the class information before confirming',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x409B2EF4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_rounded,
                      color: Color(0xFF9B2EF4),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      details.attendanceCode,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF9B2EF4),
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (controller.showAlreadySubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFFF8A34), width: 4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFFF8A34),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Attendance already submitted for this session.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF8A34),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (controller.showSuccess) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF10B769), width: 4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8FFF3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF10B769),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Your attendance has been successfully recorded!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B769),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B3CFF), Color(0xFFBD2EF3)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.className,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details.classCode,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _DetailsRow(label: 'Section', value: details.section),
                    _DetailsRow(label: 'Date', value: details.date),
                    _DetailsRow(label: 'Time', value: details.time),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9FFF3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF80E0AE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0BBB69),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              details.sessionStatus,
                              style: const TextStyle(
                                color: Color(0xFF00884C),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
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
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: PurpleButton(
              label: controller.showSuccess ? 'Done' : 'Confirm Attendance',
              isLoading: controller.isSubmitting,
              onPressed: controller.isSubmitting
                  ? null
                  : (controller.showSuccess
                        ? controller.backToDashboard
                        : controller.confirmAttendance),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}
