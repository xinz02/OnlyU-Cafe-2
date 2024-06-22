import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/admin/admin_order.dart';
import 'package:onlyu_cafe/admin/admin_report.dart';
import 'package:onlyu_cafe/admin/admin_upcoming_order.dart';

class AdminHomePage extends StatefulWidget {
  final VoidCallback navigateToMenuPage;

  const AdminHomePage({Key? key, required this.navigateToMenuPage})
      : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late DateTime startOfDay;
  late DateTime endOfDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startOfDay = DateTime(now.year, now.month, now.day);
    endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isNotEqualTo: 'Picked Up')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminOrderPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(325, 55),
                    ),
                    child: const SizedBox(
                      width: 315,
                      height: 135,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Upcoming Orders:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              SizedBox(height: 10),
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(width: 40),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  );
                } else {
                  final orders = snapshot.data!.docs.where((doc) {
                    final timestamp = (doc['timestamp'] as Timestamp).toDate();
                    return timestamp.isAfter(startOfDay) &&
                        timestamp.isBefore(endOfDay);
                  }).toList();

                  int totalOrders = orders.length;

                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminUpcomingOrderPage(),
                        //!
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(325, 55),
                    ),
                    child: SizedBox(
                      width: 315,
                      height: 135,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Upcoming Orders:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "$totalOrders",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 110,
                  height: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 237, 219, 219),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: widget.navigateToMenuPage,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book),
                        SizedBox(height: 4),
                        Text('Menu'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 237, 219, 219),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AdminReportPage(),
                        ),
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.summarize),
                        SizedBox(height: 4),
                        Text('Report'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
                    .where('timestamp', isLessThanOrEqualTo: endOfDay)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    final orderData = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    final Map<String, int> itemCount = {};

                    for (var order in orderData) {
                      for (var item in order['items']) {
                        if (itemCount.containsKey(item['name'])) {
                          itemCount[item['name']] =
                              (itemCount[item['name']] ?? 0) +
                                  (item['quantity'] as int);
                        } else {
                          itemCount[item['name']] = item['quantity'] as int;
                        }
                      }
                    }

                    // Sort items by quantity sold
                    final sortedItems = itemCount.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    // Determine the highest sale item
                    String highestSaleItemName =
                        sortedItems.isNotEmpty ? sortedItems.first.key : '';
                    int highestSaleItemQty =
                        sortedItems.isNotEmpty ? sortedItems.first.value : 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.trending_up,
                                color: Colors.green,
                                size: 36), // Icon for highest sale item
                            title: Text(
                              'Top Selling Item Today',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  '$highestSaleItemName',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity Sold: $highestSaleItemQty',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // List of items by sale quantity
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: sortedItems.length,
                            itemBuilder: (context, index) {
                              final item = sortedItems[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item.key),
                                  subtitle: Text('Qty: ${item.value}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
