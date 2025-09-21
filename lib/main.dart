import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appointment_history.dart';
import 'service_booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseURL = 'https://qaecbfihjfzngpmgnhrw.supabase.co';
const String supabaseKey = 'sb_secret_8-_9ryPN6PKVuEg8os-uGQ_BGwA-cXt';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseURL, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// Only use for UI elements
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                        Text(
                          "Previous Appointment",
                          style: const TextStyle(
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
                        Text("Date: 31/07/2025, Time: 1:30 PM",
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
                        Text(
                          "Upcoming Appointment",
                          style: const TextStyle(
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
                        Text("Date: 31/07/2025, Time: 11:30 PM",
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
                          child: Text(
                            "Current Appointment",
                            style: const TextStyle(
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
                        const Text(
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
      ),
    );
  }
}
