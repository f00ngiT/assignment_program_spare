import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl; // For time formatting
import 'dart:math';

final supabase = Supabase.instance.client;

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bookingIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _bookingIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Enter Booking ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final bookingId = _bookingIdController.text.trim();
                if (bookingId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        bookingId: bookingId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a Booking ID')),
                  );
                }
              },
              child: const Text('Go to Payment Screen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    super.dispose();
  }
}

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String? phoneNum;
  final String? carPlate;
  final String? description;
  final DateTime? date;
  final String? time;
  final String? serviceType;
  final double? amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    this.phoneNum,
    this.carPlate,
    this.description,
    this.date,
    this.time,
    this.serviceType,
    this.amount,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String paymentStatus = 'Pending';
  String paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';
  String issueDate = '';
  String issueTime = '';

  String? fetchedServiceType;
  double? fetchedAmount;

  // Payment method variables
  String _selectedPaymentMethod = 'credit_card';
  final Map<String, String> _paymentMethods = {
    'credit_card': 'Credit Card',
    'debit_card': 'Debit Card',
    'paypal': 'PayPal',
    'bank_transfer': 'Bank Transfer',
    'touch_n_go': 'Touch \'n Go',
    'boost': 'Boost',
  };

  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isValidBookingId(String bookingId) {
    return bookingId.isNotEmpty && RegExp(r'^\d+$').hasMatch(bookingId);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    issueDate = intl.DateFormat('dd/MM/yyyy').format(now);
    issueTime = intl.DateFormat('h:mm a').format(now);
    if (widget.phoneNum != null) {
      _fetchBookingDetailsFromParams(); // Use params if provided
    } else {
      _fetchBookingDetails(); // Fallback to original logic
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // fetchBookingDetails
  Future<void> _fetchBookingDetails() async {
    try {
      if (!_isValidBookingId(widget.bookingId)) {
        setState(() => paymentStatus = 'Failed');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Booking ID format'))
        );
        return;
      }

      final int bookingId = int.parse(widget.bookingId);
      final booking = await supabase
          .from('Booking')
          .select('ServiceType')
          .eq('BookingId', bookingId)
          .maybeSingle();

      if (booking == null) {
        setState(() => paymentStatus = 'Failed');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No booking found')));
        return;
      }

      final serviceType = widget.serviceType ?? booking['ServiceType'] as String;

      final serviceData = await supabase
          .from('ServiceType')
          .select('ServicePrice')
          .eq('ServiceTypeName', serviceType)
          .maybeSingle();

      if (serviceData == null || serviceData['ServicePrice'] == null) {
        setState(() => paymentStatus = 'Failed');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch service price')));
        return;
      }

      setState(() {
        fetchedServiceType = serviceType;
        fetchedAmount = widget.amount ?? (serviceData['ServicePrice'] as num).toDouble();
      });

      if (fetchedServiceType == null || fetchedAmount == null) {
        setState(() => paymentStatus = 'Failed');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch booking details')));
        return;
      }
    } catch (e) {
      print('Error: $e');
      setState(() => paymentStatus = 'Failed');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching booking: $e')));
    }
  }

  Future<void> _fetchBookingDetailsFromParams() async {
    try {
      final serviceType = widget.serviceType;
      if (serviceType == null) {
        throw Exception('Service type is required');
      }
      double? amount = widget.amount;
      if (amount == null) {
        final serviceData = await supabase
            .from('ServiceType')
            .select('ServicePrice')
            .eq('ServiceTypeName', serviceType)
            .maybeSingle();

        if (serviceData == null || serviceData['ServicePrice'] == null) {
          throw Exception('Failed to fetch service price');
        }

        amount = (serviceData['ServicePrice'] as num).toDouble();
      }

      setState(() {
        fetchedServiceType = serviceType;
        fetchedAmount = amount;
        paymentStatus = 'Pending';
      });
    } catch (e) {
      print('Error: $e');
      setState(() => paymentStatus = 'Failed');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching booking details: $e')));
    }
  }

  Future<void> _initPaymentProcess() async {
    try {
      if (_selectedPaymentMethod == 'credit_card' || _selectedPaymentMethod == 'debit_card') {
        if (_cardNumberController.text.isEmpty ||
            _expiryController.text.isEmpty ||
            _cvvController.text.isEmpty ||
            _cardHolderController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all card details')),
          );
          return;
        }
      } else if (_selectedPaymentMethod == 'touch_n_go' || _selectedPaymentMethod == 'boost') {
        if (_phoneNumberController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your phone number')),
          );
          return;
        }
      }

      // Simulate payment processing with the selected method
      setState(() => paymentStatus = 'Processing ${_paymentMethods[_selectedPaymentMethod]}...');

      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time

      setState(() => paymentStatus = 'Completed');
      await _savePayment();

      // Show success message with payment method
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment completed successfully with ${_paymentMethods[_selectedPaymentMethod]}!')),
      );

    } catch (e) {
      setState(() => paymentStatus = 'Failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: $e')),
      );
    }
  }

  Future<void> _savePayment() async {
    try {
      if (!_isValidBookingId(widget.bookingId)) {
        throw Exception('Invalid Booking ID: ${widget.bookingId}');
      }

      final int bookingId = int.parse(widget.bookingId);
      await supabase.from('payments').insert({
        'bookingId': bookingId,
        'serviceType': fetchedServiceType,
        'amount': fetchedAmount?.toInt(),
        'paymentDate': DateTime.now().toIso8601String(),
        'paymentStatus': paymentStatus,
        'paymentMethod': _selectedPaymentMethod,
      });
    } catch (e) {
      print('Error saving payment: $e');
    }
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _paymentMethods.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.value),
              selected: _selectedPaymentMethod == entry.key,
              onSelected: (selected) {
                setState(() {
                  _selectedPaymentMethod = entry.key;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
      case 'debit_card':
        return _buildCreditCardForm();
      case 'paypal':
        return _buildPayPalForm();
      case 'bank_transfer':
        return _buildBankTransferInfo();
      case 'touch_n_go':
      case 'boost':
        return _buildEWalletForm();
      default:
        return Container();
    }
  }

  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card Details', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'MM/YY',
                  hintText: '12/25',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardExpiryFormatter(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PayPal', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('You will be redirected to PayPal to complete your payment.'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For demonstration purposes, no actual redirection will occur.',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Please transfer the exact amount to:'),
        const SizedBox(height: 8),
        const ListTile(
          title: Text('Bank: Maybank'),
          subtitle: Text('Account Number: 1234 5678 9012 3456\nAccount Name: CarCare Services'),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Use your Booking ID as the payment reference. Payment will be verified within 24 hours.',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildEWalletForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _paymentMethods[_selectedPaymentMethod]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneNumberController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '01X-XXXX XXX',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
            suffixIcon: IconButton(
              icon: const Icon(Icons.contacts),
              onPressed: () {
                // Simulate contacts access
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contacts access simulated')),
                );
              },
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'You will receive a payment request on your phone. Please approve it to complete payment.',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  void _showReceipt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Payment ID: $paymentId', style: const TextStyle(fontSize: 16)),
              Text('Payment Method: ${_paymentMethods[_selectedPaymentMethod]}', style: const TextStyle(fontSize: 16)),
              Text('Issue Date: $issueDate', style: const TextStyle(fontSize: 16)),
              Text('Issue Time: $issueTime', style: const TextStyle(fontSize: 16)),
              Text('Service Type: $fetchedServiceType', style: const TextStyle(fontSize: 16)),
              Text('Amount: \$${fetchedAmount?.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              if (widget.phoneNum != null) Text('Phone Number: ${widget.phoneNum}', style: const TextStyle(fontSize: 16)),
              if (widget.carPlate != null) Text('Car Plate: ${widget.carPlate}', style: const TextStyle(fontSize: 16)),
              if (widget.description != null) Text('Description: ${widget.description}', style: const TextStyle(fontSize: 16)),
              if (widget.date != null) Text('Date: ${intl.DateFormat('dd/MM/yyyy').format(widget.date!)}', style: const TextStyle(fontSize: 16)),
              if (widget.time != null) Text('Time: ${widget.time}', style: const TextStyle(fontSize: 16)),
              Text('Status: $paymentStatus', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Billing / Payment')),
      body: Container(
        color: Colors.purple[100],
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            InkWell(
              onTap: paymentStatus == 'Completed' ? _showReceipt : null,
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.receipt, size: 40, color: Colors.blue),
                      Text('Payment ID: $paymentId', style: const TextStyle(fontSize: 18)),
                      Text('Issue Date: $issueDate', style: const TextStyle(fontSize: 16)),
                      Text('Issue Time: $issueTime', style: const TextStyle(fontSize: 16)),
                      Text('Service Type: $fetchedServiceType', style: const TextStyle(fontSize: 16)),
                      Text('Amount: \$${fetchedAmount?.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Status: $paymentStatus', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: paymentStatus == 'Completed' ? Colors.green :
                          paymentStatus == 'Failed' ? Colors.red : Colors.orange
                      )),

                      const SizedBox(height: 20),

                      if (paymentStatus == 'Pending') _buildPaymentMethodSelector(),

                      if (paymentStatus == 'Pending') _buildPaymentForm(),

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: paymentStatus == 'Pending' ? _initPaymentProcess : null,
                          child: const Text('Pay Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    if (newValue.text.length > oldValue.text.length) {
      if (newValue.text.length == 4 ||
          newValue.text.length == 9 ||
          newValue.text.length == 14) {
        return TextEditingValue(
          text: '${newValue.text} ',
          selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
        );
      }
    }
    return newValue;
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    if (newValue.text.length > oldValue.text.length) {
      if (newValue.text.length == 2) {
        return TextEditingValue(
          text: '${newValue.text}/',
          selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
        );
      }
    }
    return newValue;
  }
}