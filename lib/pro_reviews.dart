import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProReviews extends StatefulWidget {
  const ProReviews({super.key});

  @override
  State<ProReviews> createState() => _ProReviewsState();
}

class _ProReviewsState extends State<ProReviews> {
  List<ServiceProviderData> _serviceProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceProviderData();
  }

  Future<void> _fetchServiceProviderData() async {
    try {
      QuerySnapshot serviceSnapshot =
      await FirebaseFirestore.instance.collection('services').get();

      List<ServiceProviderData> tempProviders = [];
      for (var doc in serviceSnapshot.docs) {
        String uid = doc.get('service_provider') as String;
        String averageRatingString =
            (doc.get('average_rating') as String?) ?? "0.0";

        double averageRating = 0.0;
        try {
          averageRating = double.parse(averageRatingString);
        } catch (e) {
          print("Error parsing average_rating: $e");
          averageRating = 0.0;
        }
        String category = doc.get('category') as String? ?? 'No Category';

        String userName = await _fetchUserName(uid);

        tempProviders.add(ServiceProviderData(
            uid: uid,
            userName: userName,
            averageRating: averageRating,
            category: category));
      }

      Map<String, ServiceProviderData> uniqueProviders = {};
      for (var provider in tempProviders) {
        uniqueProviders[provider.uid] = provider;
      }

      _serviceProviders = uniqueProviders.values.toList();

    } catch (e) {
      print("Error fetching service provider data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load service providers.  Please check your connection.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _fetchUserName(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('all_users')
          .doc(uid)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.get('user_name') as String;
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Error Loading Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,

      body: Center( // Center the content horizontally
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500), // Limit width
          padding: const EdgeInsets.only(top: 20), // Padding from above
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white,))
              : _serviceProviders.isEmpty
              ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/empty_state.svg',
                height: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text("No Service Providers Found", style: TextStyle(color: Colors.white)),
            ],
          ))
              : RefreshIndicator(
            onRefresh: _fetchServiceProviderData,
            color: Colors.white,
            backgroundColor: accentColor,
            child: ListView.builder(
              itemCount: _serviceProviders.length,
              padding: const EdgeInsets.all(12.0),
              itemBuilder: (context, index) {
                final provider = _serviceProviders[index];
                return ServiceProviderCard(provider: provider);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceProviderData {
  final String uid;
  final String userName;
  final double averageRating;
  final String category;

  ServiceProviderData(
      {required this.uid,
        required this.userName,
        required this.averageRating,
        required this.category});
}

class ServiceProviderCard extends StatelessWidget {
  const ServiceProviderCard({
    Key? key,
    required this.provider,
  }) : super(key: key);

  final ServiceProviderData provider;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("0.0", "en_US");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColorPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 5.0),
                Text(
                  formatter.format(provider.averageRating),
                  style: const TextStyle(fontSize: 14, color: textColorSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.category, color: accentColor, size: 18),
                const SizedBox(width: 5.0),
                Text(
                  'Category: ${provider.category}',
                  style: const TextStyle(fontSize: 14, color: textColorSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


const Color accentColor = Color(0xFFFFCA28);
const Color cardColor = Color(0xFFE8EAF6);
const Color textColorPrimary = Color(0xFF212121);
const Color textColorSecondary = Color(0xFF757575);