import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_record.dart';
import 'service_type.dart';

final supabase = Supabase.instance.client;

class AppointmentHistory extends StatefulWidget {
  const AppointmentHistory({super.key});

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  final SearchController _searchController = SearchController();

  // Example appointment history data
  final List<String> appointments = [
    "Service - 12/08/2025",
    "Oil Change - 20/08/2025",
    "Tire Replacement - 05/09/2025",
    "Brake Check - 10/09/2025",
  ];

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
        // leading: IconButton(
        //     onPressed: () {
        //       //Navigator.pop();
        //     },
        //     icon: Icon(Icons.arrow_back)
        // ),
        backgroundColor: Color(0x50E0E0E0),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x88284780),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar at the top
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  hintText: "Search appointments...",
                  leading: const Icon(Icons.search),
                  onTap: () => controller.openView(),
                  onChanged: (_) => controller.openView(),
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                final query = controller.text.toLowerCase();
                final results = appointments.where((item) => item.toLowerCase().contains(query));
                return results.map((item) {
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      controller.closeView(item);
                    },
                  );
                }).toList();
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text(appointments[index]),
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
