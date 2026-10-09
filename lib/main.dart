import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AgeCalculatorApp());
}

class AgeCalculatorApp extends StatelessWidget {
  const AgeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حاسبة العمر المتطورة',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),
      home: const AgeCalculatorScreen(),
    );
  }
}

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _selectedDate;
  
  // نتائج الحساب
  int _years = 0;
  int _months = 0;
  int _days = 0;
  int _totalDays = 0;
  int _totalWeeks = 0;
  int _totalHours = 0;
  
  // عيد الميلاد القادم
  int _nextBirthdayMonths = 0;
  int _nextBirthdayDays = 0;
  String _nextBirthdayDayName = '';

  void _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return;

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      final prevMonthDays = DateTime(now.year, now.month, 0).day;
      days += prevMonthDays;
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final difference = now.difference(birthDate);
    final totalDays = difference.inDays;
    final totalWeeks = totalDays ~/ 7;
    final totalHours = difference.inHours;

    // حساب المتبقي لعيد الميلاد القادم
    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    int nextMonths = nextBirthday.month - now.month;
    int nextDays = nextBirthday.day - now.day;

    if (nextDays < 0) {
      final prevMonthDays = DateTime(now.year, now.month + 1, 0).day;
      nextDays += prevMonthDays;
      nextMonths--;
    }
    if (nextMonths < 0) {
      nextMonths += 12;
    }

    final dayNameArabic = DateFormat('EEEE', 'ar').format(nextBirthday);

    setState(() {
      _selectedDate = birthDate;
      _years = years;
      _months = months;
      _days = days;
      _totalDays = totalDays;
      _totalWeeks = totalWeeks;
      _totalHours = totalHours;
      _nextBirthdayMonths = nextMonths;
      _nextBirthdayDays = nextDays;
      _nextBirthdayDayName = dayNameArabic;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8E44AD),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1B2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _calculateAge(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C20), Color(0xFF15102A), Color(0xFF241442)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // العنوان الرئيسي
                const Text(
                  'حاسبة العمر Precise Age',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // بطاقة اختيار التاريخ
                _buildDatePickerCard(),

                const SizedBox(height: 20),

                // العرض الفرعي للنتائج
                if (_selectedDate != null)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // بطاقة العمر الرئيسي
                          _buildMainAgeCard(),
                          const SizedBox(height: 16),

                          // بطاقة عيد الميلاد القادم
                          _buildNextBirthdayCard(),
                          const SizedBox(height: 16),

                          // شبكة التفاصيل الإضافية
                          _buildExtraDetailsGrid(),
                        ],
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text(
                        'حدد تاريخ ميلادك للبدء في الحساب',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201A38).withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تاريخ الميلاد',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDate == null
                        ? 'لم يتم التحديد'
                        : DateFormat('yyyy / MM / dd').format(_selectedDate!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(_selectedDate == null ? 'اختيار' : 'تغيير'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainAgeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF6C5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            'عمرك الحقيقي الآن',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAgeUnit('سنة', '$_years'),
              _buildDivider(),
              _buildAgeUnit('شهر', '$_months'),
              _buildDivider(),
              _buildAgeUnit('يوم', '$_days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeUnit(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white80, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
    );
  }

  Widget _buildNextBirthdayCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7675).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cake_rounded, color: Color(0xFFFF7675), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عيد الميلاد القادم',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'بعد $_nextBirthdayMonths أشهر و $_nextBirthdayDays يوم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_nextBirthdayDayName.isNotEmpty)
                  Text(
                    'يوافق يوم $_nextBirthdayDayName',
                    style: const TextStyle(color: Color(0xFFFF7675), fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildDetailStatCard('إجمالي الأيام', '$_totalDays', Icons.calendar_month),
        _buildDetailStatCard('إجمالي الأسابيع', '$_totalWeeks', Icons.date_range),
        _buildDetailStatCard('إجمالي الساعات', '$_totalHours', Icons.access_time_filled),
        _buildDetailStatCard('سنة الميلاد', '${_selectedDate?.year}', Icons.history),
      ],
    );
  }

  Widget _buildDetailStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1730),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFA29BFE), size: 20),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}