import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_record.dart';

final supabase = Supabase.instance.client;

class AppointmentHistory extends StatefulWidget {
  final String username;
  const AppointmentHistory({super.key, required this.username});

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  List<BookingRecord> appointments = [];
  List<BookingRecord> filteredAppointments = [];
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await supabase
          .from('Booking')
          .select('PhoneNum, CarPlate, Description, Date, Time, ServiceType')
          .eq('UserName', widget.username)
          .order('Date', ascending: false);

      final data = response as List<dynamic>;

      setState(() {
        appointments = data.map((item) => BookingRecord.fromJson(item)).toList();
        filteredAppointments = appointments; // initially show all
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterAppointments(String input) {
    setState(() {
      query = input.toLowerCase();
      filteredAppointments = appointments.where((item) {
        return item.description.toLowerCase().contains(query) ||
            item.serviceTypeName.toLowerCase().contains(query) ||
            item.carPlate.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AutoBest PitStop',
          style: GoogleFonts.inter(
            fontSize: 35,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0x50E0E0E0),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88284780), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Simple Search Box
            TextField(
              decoration: const InputDecoration(
                hintText: "Search appointments...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: _filterAppointments,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: filteredAppointments.isEmpty
                  ? const Center(
                child: Text("No appointments found"),
              )
                  : ListView.builder(
                itemCount: filteredAppointments.length,
                itemBuilder: (context, index) {
                  final booking = filteredAppointments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text(
                        booking.serviceTypeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "${booking.description} • "
                            "${booking.date.toLocal().toString().split(' ')[0]} "
                            "at ${booking.time.format(context)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        booking.carPlate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
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
    );
  }
}
