import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_record.dart';
import 'service_type.dart';

final supabase = Supabase.instance.client;

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServiceBookingPage(title: 'Service Booking');
  }
}

class ServiceBookingPage extends StatefulWidget {
  const ServiceBookingPage({super.key, required this.title});
  final String title;

  @override
  State<ServiceBookingPage> createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _userNameCtrl = TextEditingController();
  final _phoneNumCtrl = TextEditingController();
  final _carPlateNumCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String? selectedValue; //service type current selected value
  List<ServiceType> _serviceTypes = [];
  ServiceType? _selectedServiceType;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchServiceTypes();
  }

  // insert record into supabase
  Future<void> insertBooking() async {
    try {
      //check if username exist
      final userCheck = await supabase
          .from('user_account')
          .select()
          .eq('username', _userNameCtrl.text);

      //if user not exist
      if(userCheck.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username can not found')));
        return;
      }

      //check crashing
      final existRec = await supabase
          .from('Booking')
          .select()
          .eq('Date', _dateCtrl.text)   //eq = equal
          .eq('Time', _timeCtrl.text);

      if (existRec.length >= 2) {
        // Booking clash found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All slot is already taken.")),
        );
        return; //if crashed, return
      }

      //if no crashing, then insert
      final response = await supabase.from('Booking').insert({
        'PhoneNum': _phoneNumCtrl.text.trim(),
        'CarPlate': _carPlateNumCtrl.text.trim().toUpperCase(),
        'Description': _descriptionCtrl.text,
        'Date': _dateCtrl.text,
        'Time': _timeCtrl.text,
        'ServiceType': _selectedServiceType?.serviceTypeName,
        'UserName': _userNameCtrl.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking saved successfully!")),
      );


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving booking: $e")),
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _timeCtrl.text = formatted; // e.g. "14:05"
      });
    }
  }

  Future<void> _fetchServiceTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.from('ServiceType').select();
      final serviceTypes = (response as List).map((item) => ServiceType.fromJson(item)).toList();
      setState(() {
        _serviceTypes = serviceTypes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch ServiceTypeName: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.call, size: 20),
                          SizedBox(width: 5),
                          Text('0123456789'),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    'Service Booking',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Background Image Container
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage("assets/bookingPage.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        //username
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _userNameCtrl,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                            ],
                            decoration: const InputDecoration(
                              labelText: 'username: ',
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Phone Number
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _phoneNumCtrl,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone Number: e.g. 0121234567',
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (value.length > 11) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Car Plate
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  controller: _carPlateNumCtrl,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    labelText: 'Car Plate:',
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter car plate';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Service Type
                            Expanded(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonFormField<ServiceType>(
                                  isExpanded: true,
                                  value: _selectedServiceType,
                                  hint: const Text("Service Type"),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  dropdownColor: Colors.white,
                                  items: _serviceTypes.map((ServiceType type) {
                                    return DropdownMenuItem<ServiceType>(
                                      value: type,
                                      child: Text(type.serviceTypeName),
                                    );
                                  }).toList(),
                                  onChanged: (ServiceType? newValue) {
                                    setState(() {
                                      _selectedServiceType = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a service type';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Date
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _dateCtrl,
                            readOnly: true, //no keyboard show
                            decoration: const InputDecoration(
                              labelText: "Date:  ",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                //make sure cannot pick past dates
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  //format the date and just take the date
                                  _dateCtrl.text = pickedDate.toIso8601String().split('T')[0];
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a date';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Time
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _timeCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Time (HH:mm): e.g.: 20:00",
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onTap: () => _selectTime(context),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a time';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _descriptionCtrl,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: "Description:",
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          insertBooking();
                          //Navigator.pop(context);
                        }
                      },
                      child: const Text("Confirm"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _phoneNumCtrl.dispose();
    _carPlateNumCtrl.dispose();
    _descriptionCtrl.dispose();
    _timeCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

}


