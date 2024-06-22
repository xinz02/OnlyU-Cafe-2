import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 248, 240, 238), // Set background color for the Scaffold
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Extract list of users
          List<DocumentSnapshot> users = snapshot.data!.docs;

          // Sort users alphabetically by name
          users.sort((a, b) {
            String nameA = a.get('name').toLowerCase();
            String nameB = b.get('name').toLowerCase();
            return nameA.compareTo(nameB);
          });

          // Map to store users grouped by first character of name
          Map<String, List<DocumentSnapshot>> usersByAlphabet = {};

          // Group users by first character of name
          users.forEach((user) {
            String firstChar = user.get('name')[0].toUpperCase();
            if (!usersByAlphabet.containsKey(firstChar)) {
              usersByAlphabet[firstChar] = [];
            }
            usersByAlphabet[firstChar]!.add(user);
          });

          // List of alphabet keys (sections) sorted
          List<String> alphabetSections = usersByAlphabet.keys.toList()..sort();

          // Controller to manage scrolling of the main content area
          final scrollController = ScrollController();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total users box
              Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 195, 133, 134),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Total Users: ${users.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Main content with users list and sections
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main content area with users list
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Alphabetical sections with user list
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: alphabetSections.length,
                              itemBuilder: (context, sectionIndex) {
                                String section = alphabetSections[sectionIndex];
                                List<DocumentSnapshot> usersInSection =
                                    usersByAlphabet[section] ?? [];

                                // Generate section header and user list
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      child: Text(
                                        section,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // User list for current section
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: usersInSection.length,
                                      itemBuilder: (context, index) {
                                        String userName =
                                            usersInSection[index].get('name');
                                        String userEmail =
                                            usersInSection[index].get('email');

                                        return ListTile(
                                          title: Text(userName),
                                          subtitle: Text(userEmail),
                                          // Remove the person icon
                                          onTap: () {
                                            // Handle onTap action if needed
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Sidebar with sections
                    Container(
                      width: 50,
                      child: ListView.builder(
                        itemCount: alphabetSections.length,
                        itemBuilder: (context, index) {
                          String section = alphabetSections[index];
                          return InkWell(
                            onTap: () {
                              // Calculate the scroll position to the section
                              double sectionPosition =
                                  index * 100.0; // Adjust as needed
                              scrollController.animateTo(
                                sectionPosition,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  section,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
