import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../custom_bottom_nav_bar.dart';
import 'investedFarmDetails.dart';

class MyInvestments extends StatefulWidget {
  @override
  _MyInvestmentsState createState() => _MyInvestmentsState();
}

class _MyInvestmentsState extends State<MyInvestments> {
  String? userId;
  List<Map<String, dynamic>> investments = [];
  double totalReturns = 0.0; // مجموع العوائد
  double totalInvestments = 0.0; // مجموع الاستثمار

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid; // الحصول على userId
    _fetchInvestments(); // جلب بيانات الاستثمارات
  }

  // جلب بيانات الاستثمارات مع الصور والبيانات الإضافية
  Future<void> _fetchInvestments() async {
    if (userId == null) return;

    try {
      // جلب الاستثمارات الخاصة بالمستخدم
      final investmentSnapshot = await FirebaseFirestore.instance
          .collection('investments')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> fetchedInvestments = [];
      double tempTotalReturns = 0.0; // مجموع العوائد الفعلية
      double tempTotalInvestments = 0.0; // مجموع الاستثمارات

      // جلب معاملات المحفظة الخاصة بالمستخدم
      final walletSnapshot = await FirebaseFirestore.instance
          .collection('wallets')
          .doc(userId)
          .get();

      if (!walletSnapshot.exists) {
        setState(() {
          investments = [];
          totalReturns = 0.0;
          totalInvestments = 0.0;
        });
        return;
      }

      final walletData = walletSnapshot.data();
      final transactions = walletData?['transactions'] ?? [];

      for (var investment in investmentSnapshot.docs) {
        String projectName = investment['projectName']; // اسم المشروع
        double investmentAmount = investment['investmentAmount'];
        String projectId = investment['projectId'];

        // حساب العوائد الفعلية الخاصة بالمشروع
        double actualReturns = transactions
            .where((transaction) =>
        transaction['type'] == 'returnDeposit' &&
            transaction['projectId'] == projectId)
            .map((transaction) => transaction['amount'] as double)
            .fold(0.0, (sum, amount) => sum + amount);

        // تحديث المجموعات
        tempTotalInvestments += investmentAmount;
        tempTotalReturns += actualReturns;

        // البحث عن بيانات المشروع في investmentOpportunities
        final opportunitySnapshot = await FirebaseFirestore.instance
            .collection('investmentOpportunities')
            .doc(projectId)
            .get();

        if (opportunitySnapshot.exists) {
          final farmData = opportunitySnapshot.data()!;
          fetchedInvestments.add({
            'farmName': projectName,
            'investmentAmount': investmentAmount.toString() + " ريال",
            'actualReturns': actualReturns.toString() + " ريال", // العوائد الفعلية
            'investmentDate': (investment['investmentDate'] as Timestamp).toDate(),
            'imageUrl': farmData['imageUrl'] ?? '', // رابط الصورة
            'region': farmData['region'] ?? 'غير متوفر', // المنطقة
            'cropType': farmData['cropType'] ?? 'غير متوفر', // نوع المحصول
            'status': farmData['status'] ?? 'غير متوفر', // حالة المزرعة
          });
        }
      }

      setState(() {
        investments = fetchedInvestments;
        totalReturns = tempTotalReturns; // إجمالي العوائد الفعلية
        totalInvestments = tempTotalInvestments; // إجمالي الاستثمارات
      });
    } catch (e) {
      print('Error fetching investments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: Stack(
        children: [
          _buildAppBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 220),
                Center(
                  child: _buildInvestmentContainer(context),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          setState(() {
            // تغيير الصفحة عند الضغط على عنصر في شريط التنقل السفلي
          });
        },
      ),
    );
  }

  // بناء شريط العنوان
  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF345E50), Color(0xFF49785E), Color(0xFFA8B475)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 150.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'استثماراتي',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'يمكنك هنا متابعة جميع استثماراتك في الفُرص الزراعية، \n ومراجعة التفاصيل المتعلقة بها',
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء الحاوية الرئيسية
  Widget _buildInvestmentContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.only(top: 5.0, left: 16.0, right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSummaryCards(), // إضافة البطاقات هنا
          Expanded(child: _buildInvestmentList()),
        ],
      ),
    );
  }

  // بناء بطاقات ملخصة
  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSummaryCard('مجموع العوائد', '${totalReturns.toStringAsFixed(2)} ريال'),
        const SizedBox(width: 7),
        _buildSummaryCard('مجموع الاستثمار', '${(totalInvestments+totalReturns).toStringAsFixed(2)} ريال'),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount) {
    return Expanded(
      child: Card(
        color: const Color(0xFFE5EAE3),
        elevation: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF345E50),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                amount,
                style: const TextStyle(fontSize: 14, color: Color(0xFFA8B475)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء قائمة الاستثمارات
  Widget _buildInvestmentList() {
    return ListView.builder(
      itemCount: investments.length,
      padding: const EdgeInsets.only(top: 30.0),
      itemBuilder: (context, index) {
        final investment = investments[index];
        return _buildInvestmentOption(
          farmData: investment,
        );
      },
    );
  }

  // بناء عنصر استثمار واحد
  Widget _buildInvestmentOption({required Map<String, dynamic> farmData}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0.3,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: _buildImage(farmData['imageUrl']), // استخدم وظيفة لبناء الصورة
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    farmData['farmName'],
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF345E50),
                    ),
                  ),


                  Text(
                    'المبلغ المستثمر: ${farmData['investmentAmount']}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'العوائد الفعلية: ${farmData['actualReturns']}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailsButton(farmData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء الصورة
  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      // إذا كان الرابط من الإنترنت
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 70, color: Colors.grey),
      );
    } else {
      // إذا كان الرابط من الـ assets
      return Image.asset(
        imageUrl.trim(),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 70, color: Colors.grey),
      );
    }
  }

  // بناء زر التفاصيل
  Widget _buildDetailsButton(Map<String, dynamic> farmData) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 90,
        height: 25,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B7960), Color(0xFFA2AA6D)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InvestedFarmDetails(farmData: farmData),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'تفاصيل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

