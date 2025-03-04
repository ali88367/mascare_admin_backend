import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Commission extends StatefulWidget {
  const Commission({super.key});

  @override
  State<Commission> createState() => _CommissionState();
}

class _CommissionState extends State<Commission> {
  double? _currentCommission;
  final TextEditingController _commissionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCommission();
  }

  Future<void> _getCommission() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _currentCommission = (data['platform_commission'] as num?)?.toDouble();
        });
      } else {
        print('Document does not exist'); // Handle case where document is missing
      }
    } catch (e) {
      print('Error getting commission: $e'); // Handle errors
    }
  }

  Future<void> _updateCommission(double newCommission) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin_settings')
          .update({'platform_commission': newCommission});

      setState(() {
        _currentCommission = newCommission;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commission updated successfully!')),
      );
    } catch (e) {
      print('Error updating commission: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update commission: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center( // Wrap the Column in a Center widget
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Current Commission: ${_currentCommission ?? 'Loading...'}%',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 100, // Limit the width of the TextField
                child: TextFormField(
                  controller: _commissionController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                    LengthLimitingTextInputFormatter(2), // Limit to 2 digits
                  ],
                  decoration: const InputDecoration(
                    labelText: 'New (%)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center, // Center the text inside the field
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_commissionController.text.isNotEmpty) {
                    try {
                      double newCommission = double.parse(_commissionController.text);
                      if (newCommission >= 0 && newCommission <= 100) {  //Validate if commission percentage is between 0 to 100
                        _updateCommission(newCommission);
                        _commissionController.clear(); // Clear the text field
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Commission percentage must be between 0 and 100.')),
                        );
                      }

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid input. Please enter a valid number.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a commission value.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Or any other color you prefer
                ),
                child: const Text(
                  'Update Commission',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commissionController.dispose();
    super.dispose();
  }
}