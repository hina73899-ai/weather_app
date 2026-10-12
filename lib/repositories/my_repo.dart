import 'package:flutter/material.dart';

void main() {
  runApp(const StaffCheckInApp());
}

class StaffCheckInApp extends StatelessWidget {
  const StaffCheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Staff Check-In',
      theme: ThemeData(
        fontFamily: 'sans-serif',
      ),
      home: const StaffCheckInScreen(),
    );
  }
}

class StaffMember {
  final String initials;
  final String name;
  final String role;

  StaffMember({
    required this.initials,
    required this.name,
    required this.role,
  });
}

class StaffCheckInScreen extends StatefulWidget {
  const StaffCheckInScreen({super.key});

  @override
  State<StaffCheckInScreen> createState() => _StaffCheckInScreenState();
}

class _StaffCheckInScreenState extends State<StaffCheckInScreen> {
  final List<StaffMember> staffList = [
    StaffMember(initials: 'AK', name: 'Alex Khan', role: 'Manager'),
    StaffMember(initials: 'SJ', name: 'Sarah Johnson', role: 'Supervisor'),
    StaffMember(initials: 'MC', name: 'Maria Clarke', role: 'Server'),
  ];

  int selectedIndex = 0;
  String enteredPin = '';

  void _onKeyPress(String value) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += value;
      });
    }
  }

  void _onBackspace() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStaff = staffList[selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Sidebar Panel
          Container(
            width: 320,
            color: const Color(0xFFED3251), // Primary Red Accent
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CRAVEDASH EPOS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Staff Check-In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '10:41:33',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Text(
                  'Friday, 4 September 2026',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 20),
                const Text(
                  'SELECT STAFF',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Staff List
                Expanded(
                  child: ListView.builder(
                    itemCount: staffList.length,
                    itemBuilder: (context, index) {
                      final staff = staffList[index];
                      final isSelected = index == selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            enteredPin = ''; // Staff switch karne par PIN reset ho jayega
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Colors.white54, width: 1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Text(
                                  staff.initials,
                                  style: const TextStyle(
                                    color: Color(0xFFED3251),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      staff.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      staff.role,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right PIN Keypad Section
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar Header
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFED3251),
                      child: Text(
                        selectedStaff.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedStaff.name,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedStaff.role,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'ENTER PIN',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4-Digit PIN Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < enteredPin.length;
                        return Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isFilled
                                  ? const Color(0xFFED3251)
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isFilled
                                ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                                shape: BoxShape.circle,
                              ),
                            )
                                : null,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Keypad Grid
                    SizedBox(
                      width: 240,
                      child: Column(
                        children: [
                          _buildNumRow(['1', '2', '3']),
                          const SizedBox(height: 12),
                          _buildNumRow(['4', '5', '6']),
                          const SizedBox(height: 12),
                          _buildNumRow(['7', '8', '9']),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 64),
                              _buildNumKey('0'),
                              _buildActionKey(
                                icon: Icons.backspace_outlined,
                                onTap: _onBackspace,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: 240,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: enteredPin.length == 4 ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFED3251),
                          disabledBackgroundColor: const Color(0xFFF1F5F9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            color: enteredPin.length == 4
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
    );
  }

  Widget _buildNumRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildNumKey(key)).toList(),
    );
  }

  Widget _buildNumKey(String value) {
    return Container(
      width: 64,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onKeyPress(value),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 64,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}