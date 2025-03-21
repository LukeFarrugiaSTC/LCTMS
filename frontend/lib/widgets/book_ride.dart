import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class BookRide extends StatefulWidget {
  const BookRide({super.key, this.showScaffold = true});
  final bool showScaffold;

  @override
  State<BookRide> createState() {
    return _BookRide();
  }
}

class _BookRide extends State<BookRide> {
  final _keyForm = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bookingDateController = TextEditingController();
  String _dropOffLocation = '';
  bool _isBooked = false;
  final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  final List<String> _tempDropOffList = ['DropOff1', 'DropOff2'];

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(Duration(days: 2));
    final DateTime lastDate = now.add(Duration(days: 365));

    // First, select a date.
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    // If no date is selected, exit.
    if (pickedDate == null) return;

    // Then, select a time.
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    // If no time is selected, exit.
    if (pickedTime == null) return;

    // Combine the date and time into a single DateTime.
    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      // Assuming you have a DateFormat that handles both date and time, e.g. 'dd/MM/yyyy HH:mm'
      _bookingDateController.text = dateTimeFormatter.format(combinedDateTime);
    });
  }

  bool _bookRide() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      print(_nameController.text);
      print(_surnameController.text);
      print(_emailController.text);
      print(_bookingDateController.text);
      return true;
    }
    return false;
  }

  void _resetForm() {
    //_keyForm.currentState?.reset();   <=== with this I get an error due to thedrop down menu, but without it the form's state will not reset
    _nameController.clear();
    _surnameController.clear();
    _emailController.clear();
    _bookingDateController.clear();

    _dropOffLocation = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _bookingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isBooked) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 120),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your booking is confirmed!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: () {
                        // Return to home
                        setState(() {
                          _isBooked = false;
                          _resetForm();
                        });
                      },
                      child: Text('Back'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = SingleChildScrollView(
        child: Form(
          key: _keyForm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Booking Form',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontSize: 30),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Name',
                  controller: _nameController,
                  textFieldType: TextFieldType.textRequired,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Surname',
                  controller: _surnameController,
                  textFieldType: TextFieldType.textRequired,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Email Address',
                  controller: _emailController,
                  textFieldType: TextFieldType.email,
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bookingDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month),
                    label: Text(
                      _bookingDateController.text.isEmpty
                          ? 'Select Date & Time'
                          : _bookingDateController.text,
                    ),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  // Use the combined picker function
                  onTap: () => _selectDateTime(context),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: _dropOffLocation.isEmpty ? null : _dropOffLocation,
                  decoration: InputDecoration(
                    label: Text(
                      _dropOffLocation.isEmpty
                          ? 'Select Drop Off location'
                          : '',
                    ),
                  ),
                  items:
                      _tempDropOffList.map((String dropOff) {
                        return DropdownMenuItem<String>(
                          value: dropOff,
                          child: Text(dropOff),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _dropOffLocation = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isBooked = _bookRide();
                          });
                        },
                        child: Text('Submit Booking'),
                      ),
                      const SizedBox(height: 5),

                      TextButton(
                        onPressed: () {
                          _resetForm();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size(300, 40),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Reset Booking',
                          textAlign: TextAlign.start,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    //Only returns scaffold if this is accessed through the navbar
    return widget.showScaffold
        ? Scaffold(appBar: AppBar(title: Text('Book a Ride')), body: content)
        : content;
  }
}
