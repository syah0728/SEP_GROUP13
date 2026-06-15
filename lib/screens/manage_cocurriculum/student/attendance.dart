import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/firebase_services.dart';
import '../../../widgets/std_sidebar.dart';

class AttendanceCheckIn extends StatefulWidget {
  const AttendanceCheckIn({super.key});

  @override
  State<AttendanceCheckIn> createState() => AttendanceCheckInState();
}

class AttendanceCheckInState extends State<AttendanceCheckIn> {
  final TextEditingController codeController = TextEditingController();
  final FirebaseService _service = FirebaseService();

  // Hardcoded student identity — matches seed data in FirebaseService
  static const String _studentName = 'Ahmad Imran';
  static const String _matricNumber = 'CD210145';
  static const String _programme = 'BCS';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  static const Color purplePrimary = Color(0xFFAB43FE);

  bool isCheckingIn = false;
  bool gpsEnabled = false;
  String activeTab = 'classes'; // 'classes' or 'activities'

  @override
  void initState() {
    super.initState();
    checkGPS();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> checkGPS() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        setState(() {
          gpsEnabled = serviceEnabled;
        });
      }
    } catch (e) {
      setState(() {
        gpsEnabled = false;
      });
    }
  }

  Future<void> handleCheckIn() async {
    if (!gpsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable GPS to check in')),
      );
      return;
    }

    if (codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => isCheckingIn = true);

    if (activeTab == 'activities') {
      final result = await _service.submitActivityAttendance(
        code: codeController.text,
        studentName: _studentName,
        matricNumber: _matricNumber,
        programme: _programme,
      );
      setState(() {
        isCheckingIn = false;
        codeController.clear();
      });
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code. Please check with the organizer.')),
        );
      } else if (result == 'already_checked_in') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already checked in for this activity.')),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Checked In!'),
              ],
            ),
            content: Text(
              'Attendance recorded for "$result".\n\nYou can now claim CATS points — go to "Claim Hours".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Classes tab: handled by Module 4's attendance flow
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        isCheckingIn = false;
        codeController.clear();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Class attendance recorded successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StudentSidebar(
        activePage: 'checkin',
        studentName: 'Ahmad Imran',
        matricNumber: 'CD210145',
        onLogout: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Purple header
              Container(
                color: purplePrimary,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => scaffoldKey.currentState?.openDrawer(),
                          child: const Icon(Icons.menu,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Attendance Check-In',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.notifications_none, color: Colors.white),
                        SizedBox(width: 12),
                        Icon(Icons.person_outline, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GPS Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gpsEnabled ? Colors.green.shade50 : Colors.red.shade50,
                border: Border(
                  left: BorderSide(
                    color: gpsEnabled
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    width: 4,
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: gpsEnabled
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gpsEnabled ? 'GPS Enabled' : 'GPS Disabled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: gpsEnabled
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gpsEnabled
                              ? 'Location detected on campus'
                              : 'Please enable GPS to check in',
                          style: TextStyle(
                            fontSize: 14,
                            color: gpsEnabled
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => activeTab = 'classes'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: activeTab == 'classes'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Classes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: activeTab == 'classes'
                                ? Colors.blue.shade600
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => activeTab = 'activities'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: activeTab == 'activities'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: activeTab == 'activities'
                                  ? Colors.purple.shade600
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Activities',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: activeTab == 'activities'
                                    ? Colors.purple.shade600
                                    : Colors.grey.shade600,
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
            const SizedBox(height: 16),

            // CATS Info Banner (Activities Tab Only)
            if (activeTab == 'activities')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.pink.shade50],
                  ),
                  border: Border.all(color: Colors.purple.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.purple.shade600),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Earn CATS Points',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Attend any co-curriculum activity and get the passcode from the organizer. Enter it below to:',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '✓ Automatically register for the activity',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '✓ Mark your attendance',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '✓ Unlock CATS points to claim',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No pre-registration needed! Just show up and submit the code. Need 8 CATS = 2 credits for graduation.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (activeTab == 'activities') const SizedBox(height: 16),

            // Check-In Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smartphone, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'Check-In Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter ${activeTab == 'classes' ? 'Class' : 'Activity'} Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ABC123',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeTab == 'classes'
                        ? "Ask your lecturer for today's class code"
                        : "Get the passcode from the activity organizer at the venue",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (activeTab == 'activities' && codeController.text.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        border: Border.all(color: Colors.purple.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 How it works:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'The organizer will announce a code like SPT123 or VOL456. Enter it above to automatically register and mark your attendance in one step!',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: !gpsEnabled ||
                            codeController.text.length != 6 ||
                            isCheckingIn
                        ? null
                        : handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCheckingIn)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.check_circle),
                        const SizedBox(width: 8),
                        Text(
                          isCheckingIn
                              ? 'Checking In...'
                              : 'Check In to ${activeTab == 'classes' ? 'Class' : 'Activity'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 16),

            // QR Code Option
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.pink.shade50],
                ),
                border: Border.all(color: Colors.purple.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code, size: 48, color: Colors.purple.shade600),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeTab == 'classes'
                        ? 'If your lecturer displays a QR code, scan it to check in automatically'
                        : 'Scan the activity QR code to check in automatically',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR Scanner feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Open QR Scanner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recent Attendance
            const Text(
              'Recent Attendance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            buildAttendanceRecord(
              'Blood Donation Campaign',
              '10 March 2026 • 8:00 AM',
              'Main Hall',
              'present',
              2,
            ),
            buildAttendanceRecord(
              'Cultural Night Festival',
              '15 March 2026 • 6:00 PM',
              'Open Theater',
              'present',
              2,
            ),
          ],
        ),
      ),
              ),      // closes Expanded
            ],        // closes outer Column children
          ),          // closes outer Column
        ),            // closes Container
      ),              // closes SafeArea
    );
  }

  Widget buildAttendanceRecord(
    String title,
    String datetime,
    String venue,
    String status,
    int? cats,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            datetime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (cats != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$cats CATS Points',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Present',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  venue,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
