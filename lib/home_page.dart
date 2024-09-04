import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:coolapp/select_page.dart';
import 'package:coolapp/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Section> section = [];
  bool isGridView = false; // Toggle state for List/Grid view
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    getData(); // Fetch data once during initialization
  }

  Future<void> getData() async {
    if (section.isEmpty) {
      try {
        final response = await http
            .get(Uri.parse('https://api.mocklets.com/p6839/explore-cred'));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          List<dynamic> sections = data['sections'];
          setState(() {
            section = sections.map((item) => Section.fromJson(item)).toList();
            isLoading = false; // Set loading to false after data is fetched
          });
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        setState(() {
          isLoading = false; // Set loading to false even if there's an error
        });
        // Handle error appropriately
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: isGridView ? buildGridView() : buildListView(),
            ),
    );
  }

  Widget buildGridView() {
    return ListView.builder(
      key: const ValueKey<bool>(true), // Unique key to differentiate
      itemCount: section.length + 1, // +1 for the title section
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildHeader();
        } else {
          int sectionIndex = index - 1;
          return buildSectionContent(sectionIndex, isGridView: true);
        }
      },
    );
  }

  Widget buildListView() {
    return ListView.builder(
      key: const ValueKey<bool>(false), // Unique key to differentiate
      itemCount: section.length + 1, // +1 for the title section
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildHeader();
        } else {
          int sectionIndex = index - 1;
          return buildSectionContent(sectionIndex, isGridView: false);
        }
      },
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'explore',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 80, 79, 79)),
              ),
              Text(
                'CRED',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildSectionContent(int sectionIndex, {required bool isGridView}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section[sectionIndex].templateProperties.header.title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 80, 79, 79)),
          ),
          const SizedBox(height: 10),
          isGridView
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount:
                      section[sectionIndex].templateProperties.items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = section[sectionIndex]
                        .templateProperties
                        .items[itemIndex];
                    return buildItemCard(item);
                  },
                )
              : Column(
                  children: section[sectionIndex]
                      .templateProperties
                      .items
                      .map((item) {
                    return Column(
                      children: [
                        buildItemRow(item),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget buildItemCard(item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectPage(
              itemName: item.displayData.name,
              iconUrl: item.displayData.iconUrl,
              itemDesc: item.displayData.description,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 34, 34, 34), width: 1),
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: Image.network(
                item.displayData.iconUrl,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 24);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              item.displayData.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemRow(item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectPage(
              itemName: item.displayData.name,
              iconUrl: item.displayData.iconUrl,
              itemDesc: item.displayData.description,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 34, 34, 34), width: 1),
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: Image.network(
                item.displayData.iconUrl,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 24);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayData.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 4),
                Text(
                  item.displayData.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 80, 79, 79),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
