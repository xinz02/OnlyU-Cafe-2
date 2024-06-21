import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/product_management/add_menu_item.dart';
import 'admin_order.dart';
import 'admin_category.dart';
import 'admin_main.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({Key? key}) : super(key: key);

  @override
  _AdminReportPageState createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  int totalOrders = 0;
  int totalOrdersToday = 0;
  int totalCategories = 0;
  int totalItems = 0;
  double totalRevenue = 0.0;
  double totalRevenueToday = 0.0;
  double averageFoodRating = 0.0;
  double averageServiceRating = 0.0;
  String selectedFilter = 'All Time';
  List<String> filters = ['All Time', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchOrdersCount();
    await fetchCategoriesCount();
    await fetchItemsCount();
    await fetchOrdersForTimeFrame(selectedFilter);
    await fetchRatings();
    setState(() {});
  }

  Future<void> fetchOrdersCount() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    totalOrders = ordersSnapshot.size;
  }

  Future<void> fetchCategoriesCount() async {
    final categoriesSnapshot =
        await FirebaseFirestore.instance.collection('Category').get();
    totalCategories = categoriesSnapshot.size;
  }

  Future<void> fetchItemsCount() async {
    final itemsSnapshot =
        await FirebaseFirestore.instance.collection('menu_items').get();
    totalItems = itemsSnapshot.size;
  }

  Future<void> fetchOrdersForTimeFrame(String filter) async {
    final now = DateTime.now();
    DateTime startOfDay;
    DateTime startOfWeek;
    DateTime startOfMonth;
    DateTime startOfTimeFrame;

    startOfDay = DateTime(now.year, now.month, now.day);
    startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfMonth = DateTime(now.year, now.month, 1);

    switch (filter) {
      case 'Today':
        startOfTimeFrame = startOfDay;
        break;
      case 'This Week':
        startOfTimeFrame = startOfWeek;
        break;
      case 'This Month':
        startOfTimeFrame = startOfMonth;
        break;
      default:
        startOfTimeFrame = DateTime(2000);
    }

    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('timestamp', isGreaterThanOrEqualTo: startOfTimeFrame)
        .get();

    int ordersCount = ordersSnapshot.size;
    double revenue = 0.0;

    for (var doc in ordersSnapshot.docs) {
      revenue += doc['totalAmount'];
    }

    setState(() {
      if (filter == 'Today') {
        totalOrdersToday = ordersCount;
        totalRevenueToday = revenue;
      } else {
        totalOrders = ordersCount;
        totalRevenue = revenue;
      }
      selectedFilter = filter;
    });
  }

  Future<void> fetchRatings() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    double totalFoodRating = 0.0;
    double totalServiceRating = 0.0;
    int ratedOrdersCount = 0;

    for (var doc in ordersSnapshot.docs) {
      if (doc.data().containsKey('foodRating') &&
          doc['foodRating'] != null &&
          doc['foodRating'] != 0 &&
          doc.data().containsKey('serviceRating') &&
          doc['serviceRating'] != null &&
          doc['serviceRating'] != 0) {
        totalFoodRating += doc['foodRating'];
        totalServiceRating += doc['serviceRating'];
        ratedOrdersCount++;
      }
    }

    setState(() {
      averageFoodRating = ratedOrdersCount > 0 ? totalFoodRating / ratedOrdersCount : 0.0;
      averageServiceRating = ratedOrdersCount > 0 ? totalServiceRating / ratedOrdersCount : 0.0;
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40.0),
        title: Text(
          title,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 18.0),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminMainPageState =
        context.findAncestorStateOfType<AdminMainPageState>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        title: Text('Report'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.black87),
                      SizedBox(width: 4.0),
                      DropdownButton<String>(
                        value: selectedFilter,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            fetchOrdersForTimeFrame(newValue);
                          }
                        },
                        items: filters
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.black87),
                            ),
                          );
                        }).toList(),
                        underline: Container(),
                        icon:
                            Icon(Icons.arrow_drop_down, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildStatCard(
              'Total Orders',
              selectedFilter == 'All Time'
                  ? '$totalOrders'
                  : (selectedFilter == 'Today'
                      ? '$totalOrdersToday'
                      : '$totalOrders'),
              Icons.shopping_cart,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrderPage()),
                );
              },
            ),
            _buildStatCard(
              'Total Revenue',
              selectedFilter == 'All Time'
                  ? '\$${totalRevenue.toStringAsFixed(2)}'
                  : (selectedFilter == 'Today'
                      ? '\$${totalRevenueToday.toStringAsFixed(2)}'
                      : '\$${totalRevenue.toStringAsFixed(2)}'),
              Icons.attach_money,
              () {
                // No action needed for revenue stat card
              },
            ),
            SizedBox(height: 20),
            Text(
              'Additional Information',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            _buildStatCard(
              'Total Categories',
              '$totalCategories',
              Icons.category,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminCategoryPage()),
                );
              },
            ),
            _buildStatCard(
              'Total Items',
              '$totalItems',
              Icons.fastfood,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMenuItemPage()),
                );
              },
            ),
            _buildStatCard(
              'Average Food Rating',
              '${averageFoodRating.toStringAsFixed(1)}/5.0',
              Icons.star,
              () {
                // No action needed for rating stat card
              },
            ),
            _buildStatCard(
              'Average Service Rating',
              '${averageServiceRating.toStringAsFixed(1)}/5.0',
              Icons.star_half,
              () {
                // No action needed for rating stat card
              },
            ),
          ],
        ),
      ),
    );
  }
}
