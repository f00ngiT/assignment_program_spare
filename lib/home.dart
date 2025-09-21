import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appointment_history.dart';
import 'service_booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_record.dart';

final supabase = Supabase.instance.client;

// Only use for UI elements
class Home extends StatelessWidget {
  final String username;

  const Home({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return HomePage(title: 'Service Booking', username: username);
  }
}


class HomePage extends StatefulWidget {
  final String username;
  final String title;

  const HomePage({
    super.key,
    required this.title,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BookingRecord> _bookingRecords = [];
  BookingRecord? _currentBooking;
  BookingRecord? _nextBooking;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchBookingRecords(widget.username);
  }

  Future<void> _fetchBookingRecords(String username) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch bookings for this user, sorted by Date and Time
      final response = await supabase
          .from('Booking')
          .select()
          .eq('UserName', username)
          .order('Date', ascending: true)
          .order('Time', ascending: true);

      final bookingRecords = (response as List)
          .map((item) => BookingRecord.fromJson(item))
          .toList();

      final now = DateTime.now();
      BookingRecord? currentDT;
      BookingRecord? nextDT;

      for (var booking in bookingRecords) {
        final bookingDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          booking.time.hour,
          booking.time.minute,
        );

        if (bookingDateTime.isAfter(now)) {
          // Keep the soonest future booking
          if (nextDT == null || bookingDateTime.isBefore(
              DateTime(
                nextDT.date.year,
                nextDT.date.month,
                nextDT.date.day,
                nextDT.time.hour,
                nextDT.time.minute,
              ))) {
            nextDT = booking;
          }
        }

        // Appointment happening now (+/- 30 minutes)
        if (currentDT == null &&
            bookingDateTime.isAfter(now.subtract(const Duration(minutes: 30))) &&
            bookingDateTime.isBefore(now.add(const Duration(minutes: 30)))) {
          currentDT = booking;
        }
      }

      setState(() {
        _bookingRecords = bookingRecords;
        _currentBooking = currentDT;
        _nextBooking = nextDT;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch bookings: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatTime24(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}';

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
        body: Container(
          color: const Color(0x24284780), // semi-transparent overlay
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// Background image
              FittedBox(
                fit: BoxFit.cover,
                child: Image.asset('assets/sports_car.jpeg'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    width: 370,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0x9911FF00),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Next Appointment",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 4,
                        ),
                        Text(_nextBooking != null ?
                        "Date: ${_nextBooking!.date.toLocal().toString().split(' ')[0]},"
                            " Time: ${formatTime24(_nextBooking!.time)}" :
                        "No next appointments",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    width: 370,
                    height: 225,
                    decoration: BoxDecoration(
                      color: Color(0x99ECEBF9), // temporary color
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          width: 5,
                          color: Colors.black
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Title
                        Center(
                          child: const Text(
                            "Current Appointment",
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const Divider(
                            thickness: 4,
                            color: Colors.black
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color: Colors.black,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0), // space between icon and border
                            child: Icon(
                              Icons.no_crash,
                              size: 50,
                            ),
                          ),
                        ),
                        Text(_currentBooking != null
                            ? "Date: ${_currentBooking!.date.toLocal().toString().split(' ')[0]}, "
                            "Time: ${formatTime24(_currentBooking!.time)}"
                            : "No current appointment",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        Text("Status: Ready for Collection",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const ServiceBookingApp())
                                );
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(EdgeInsets.all(12)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/appointment_calendar.png',
                                    height: 60,
                                    width: 60,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Service\nBooking",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => AppointmentHistory(username: widget.username))
                                );
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(EdgeInsets.all(12)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/history.webp',
                                    height: 60,
                                    width: 60,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Appointment\nHistory",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(EdgeInsets.all(12)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/billing.png',
                                    height: 60,
                                    width: 60,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "E-billing /\nPayment",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  )

                ],
              ),
            ],
          ),
        ),
      );
  }
}
