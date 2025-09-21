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
  BookingRecord? _previousBooking;
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
      final response = await supabase.from('Booking').select().eq('UserName', username);
      final bookingRecords = (response as List)
          .map((item) => BookingRecord.fromJson(item))
          .toList();

      final now = DateTime.now();
      BookingRecord? previous;
      BookingRecord? current;
      BookingRecord? next;

      for (var booking in bookingRecords) {
        final bookingDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          booking.time.hour,
          booking.time.minute,
        );

        if (bookingDateTime.isBefore(now)) previous = booking;
        if (bookingDateTime.isAfter(now) && next == null) next = booking;

        if ((bookingDateTime.isAfter(now.subtract(const Duration(minutes: 30))) &&
            bookingDateTime.isBefore(now.add(const Duration(minutes: 30))))) {
          current = booking;
        }
      }

      setState(() {
        _bookingRecords = bookingRecords;
        _previousBooking = previous;
        _currentBooking = current;
        _nextBooking = next;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch bookings: $e'))
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
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: 370,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0x99FFB5B5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Previous Appointment",
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
                        Text(_previousBooking != null ?
                        "Date: ${_previousBooking!.date.toLocal().toString().split(' ')[0]},"
                            " Time: ${formatTime24(_previousBooking!.time)}" :
                          "No previous appointments",
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
                    margin: EdgeInsets.symmetric(vertical: 10),
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
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 370,
                    height: 300,
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
                        Text("Date: 29/07/2025, Time: 1:30 PM",
                            style: TextStyle(
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
                        const Divider(
                            thickness: 2,
                            color: Colors.black),
                        /// Notes section
                        const Text(
                          "Notes:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        Text(
                          "Hooray! Your car is ready to pick up!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                                  context, MaterialPageRoute(builder: (context) => const AppointmentHistory())
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
                ],
              ),
            ],
          ),
        ),
      );
  }
}
