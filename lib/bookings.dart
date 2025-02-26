import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  String selectedStatus = "All";
  TextEditingController searchController = TextEditingController();

  List<Map<String, String>> bookings = [
    {"id": "001", "user": "John Doe", "service": "Checkup", "date": "2025-02-26", "status": "Pending"},
    {"id": "002", "user": "Jane Smith", "service": "Consultation", "date": "2025-02-25", "status": "Closed"},
    {"id": "003", "user": "Mike Johnson", "service": "Therapy", "date": "2025-02-24", "status": "Cancelled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedStatus,
                  items: ["All", "Pending", "Closed", "Cancelled", "Rejected"]
                      .map((status) => DropdownMenuItem(value: status, child: Text(status, style: TextStyle(color: orange))))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedStatus = value!);
                  },
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search by User Name",
                      labelStyle: TextStyle(color: orange),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Booking ID", style: TextStyle(color: orange))),
                    DataColumn(label: Text("User", style: TextStyle(color: orange))),
                    DataColumn(label: Text("Service", style: TextStyle(color: orange))),
                    DataColumn(label: Text("Date", style: TextStyle(color: orange))),
                    DataColumn(label: Text("Status", style: TextStyle(color: orange))),
                    DataColumn(label: Text("Actions", style: TextStyle(color: orange))),
                  ],
                  rows: bookings.where((booking) {
                    if (selectedStatus != "All" && booking["status"] != selectedStatus) return false;
                    if (searchController.text.isNotEmpty && !booking["user"]!.toLowerCase().contains(searchController.text.toLowerCase())) return false;
                    return true;
                  }).map((booking) {
                    return DataRow(cells: [
                      DataCell(Text(booking["id"]!, style: TextStyle(color: Colors.white))),
                      DataCell(Text(booking["user"]!, style: TextStyle(color: Colors.white))),
                      DataCell(Text(booking["service"]!, style: TextStyle(color: Colors.white))),
                      DataCell(Text(booking["date"]!, style: TextStyle(color: Colors.white))),
                      DataCell(Text(booking["status"]!, style: TextStyle(color: Colors.white))),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _updateStatus(booking["id"]!, "Closed"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _updateStatus(booking["id"]!, "Cancelled"),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String id, String newStatus) {
    setState(() {
      bookings = bookings.map((booking) {
        if (booking["id"] == id) {
          return {...booking, "status": newStatus};
        }
        return booking;
      }).toList();
    });
  }
}