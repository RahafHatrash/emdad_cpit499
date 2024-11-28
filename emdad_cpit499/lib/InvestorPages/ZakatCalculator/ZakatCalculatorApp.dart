import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../custom_bottom_nav_bar.dart';
import '../InvestorHome/InvestorHome.dart';

class ZakatCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zakat Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ZakatCalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ZakatCalculatorPage extends StatefulWidget {
  @override
  _ZakatCalculatorPageState createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
  final TextEditingController _amountController = TextEditingController();
  double _zakatAmount = 0.0;
  bool _manualInput = true;
  double goldPrice = 240.0; // Price of gold
  double nisab = 85.0; // Nisab in grams
  double investmentWalletBalance = 100000; // Example wallet balance
  int _currentIndex = 1;

  void _calculateZakat() async {
    double amount;

    if (_manualInput) {
      amount = double.tryParse(_amountController.text) ?? 0.0;
    } else {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final walletDoc = await FirebaseFirestore.instance
              .collection('wallets')
              .doc(userId)
              .get();

          if (walletDoc.exists) {
            investmentWalletBalance =
                walletDoc.data()?['currentBalance'] ?? 0.0;
          }
        }
      } catch (e) {
        print("Error fetching wallet balance: $e");
        investmentWalletBalance = 0.0;
      }

      amount = investmentWalletBalance;
    }

    double nisabAmount = nisab * goldPrice;

    setState(() {
      _zakatAmount = (amount >= nisabAmount) ? amount * 0.025 : 0.0;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
            colors: [
              Color(0xFF345E50),
              Color(0xFF49785E),
              Color(0xFFA8B475),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'حاسبة الزكاة',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'احسب زكاتك على أموالك المستثمرة بسهولة \n وفقاً للضوابط الشرعية',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: const TextStyle(color: Color(0xFFA09E9E)),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Color(0xFFA09E9E)),
        ),
        Container(
          height: 1,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF345E50),
                Color(0xFF49785E),
                Color(0xFFA8B475),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSelector() {
    return Container(
      padding: EdgeInsets.all(6),
      margin: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF345E50), Color(0xFFA8B475)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _manualInput = false;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              decoration: BoxDecoration(
                color: !_manualInput
                    ? Color.fromARGB(92, 255, 255, 255)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'رصيد المحفظة',
                style: TextStyle(
                  fontSize: 18,
                  color: !_manualInput ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _manualInput = true;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              decoration: BoxDecoration(
                color: _manualInput
                    ? Color.fromARGB(92, 255, 255, 255)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'إدخال المبلغ يدوياً',
                style: TextStyle(
                  fontSize: 18,
                  color: _manualInput ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: Stack(
        children: [
          _buildAppBar(),
          Padding(
            padding: const EdgeInsets.only(top: 220, left: 16, right: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildWalletSelector(),
                        if (_manualInput)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'أدخل المبلغ الذي ترغب بحساب الزكاة عليه',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(216, 53, 94, 79),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildStyledTextField('القيمة بالريال السعودي'),
                            ],
                          ),
                        if (!_manualInput)
                          Text(
                            'سيتم حساب الزكاة بناءً على رصيد المحفظة الاستثماري',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(216, 53, 94, 79),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: _calculateZakat,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4, // Adjust width as needed
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF345E50),
                                  Color(0xFFA8B475),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'حساب الزكاة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'مبلغ الزكاة الواجب دفعه: ${_zakatAmount.toStringAsFixed(2)} ريال سعودي',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'الزكاة هي 2.5% من المبلغ الذي يبلغ النصاب وحال عليه الحول، ويُعتبر النصاب ما يعادل قيمة 85 غرامًا من الذهب.',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}
