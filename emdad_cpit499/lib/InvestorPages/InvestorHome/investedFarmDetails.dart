import 'package:flutter/material.dart';

import '../../custom_bottom_nav_bar.dart';

class InvestedFarmDetails extends StatelessWidget {
  final Map<String, dynamic> farmData;

  InvestedFarmDetails({required this.farmData});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display top image with overlay and back button
            Stack(
              children: [
                Image.network(
                  farmData['imageUrl'] ?? '',
                  width: double.infinity,
                  height: screenHeight * 0.3,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 70, color: Colors.grey);
                  },
                ),
                // Dark overlay on the image
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.3,
                  color: Colors.black.withOpacity(0.1),
                ),
                // Back button positioned at the top right
                Positioned(
                  top: 50,
                  right: 15,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward,
                        color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            // Main details container
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align content to the right
                  children: [
                    // Title and location section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              farmData['farmName'] ?? 'اسم غير متوفر',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF345E50),
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Color.fromARGB(255, 160, 165, 160),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  farmData['region'] ?? 'غير محدد',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Grid view for project details
                    SizedBox(
                      height: 280,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: [
                          ProjectDetailItem(
                            icon: Icons.timer,
                            title: 'مدة الاستثمار',
                            value: farmData['opportunityDuration'] ?? 'غير متوفر',
                          ),
                          ProjectDetailItem(
                            icon: Icons.attach_money,
                            title: 'مبلغ استثمارك',
                            value: farmData['investmentAmount'] ?? 'غير متوفر',
                          ),
                          ProjectDetailItem(
                            icon: Icons.pie_chart,
                            title: 'نسبة التملك',
                            value: farmData['ownershipPercentage'] ?? 'غير متوفر',
                          ),
                          ProjectDetailItem(
                            icon: Icons.bar_chart,
                            title: 'العائد المتوقع',
                            value: farmData['expectedReturns'] ?? 'غير متوفر',
                          ),
                          ProjectDetailItem(
                            icon: Icons.event_available,
                            title: 'موعد استلام الأرباح',
                            value: farmData['profitDate'] ?? 'غير متوفر',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation bar without any highlighted icon
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: -1,
        onTap: (index) {
          // Handle navigation taps if needed
        },
      ),
    );
  }
}

// Widget for displaying individual project detail items in grid format
class ProjectDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProjectDetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: const Color.fromARGB(255, 131, 176, 134)),
          const SizedBox(height: 0),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 57, 98, 32),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 54, 88, 15),
            ),
          ),
        ],
      ),
    );
  }
}
