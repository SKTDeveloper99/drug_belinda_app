import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/main.dart';
import 'package:medical_app_belinda_full/screens/add_medicine.dart';
import 'package:intl/intl.dart' as intl;

class DoctorAppointmentPage extends StatefulWidget {
  DoctorAppointmentPage({
    super.key,
  });

  @override
  State<DoctorAppointmentPage> createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
  DateTime date = DateTime.now();
  late User user;

  @override
  void initState() {
    user = auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Appointment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormDatePicker(
              date: date,
              onChanged: (value) {
                setState(() {
                  date = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async{
                final userPostRef = FirebaseFirestore.instance
                    .collection("BeHealthyAppUsers")
                    .doc(user.uid)
                    .collection("doctorAppointments");
                await userPostRef.add({
                  "time": date.millisecondsSinceEpoch,
                });
                if(mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
                child: const Text("Submit Doctor Appointment")),
          ],
        ),
      ),
    );
  }
}

class FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  State<FormDatePicker> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              intl.DateFormat.yMd().format(widget.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        TextButton(
          child: const Text('Edit'),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: widget.date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            // Don't change the date if the date picker returns null.
            if (newDate == null) {
              return;
            }
            widget.onChanged(newDate);
          },
        )
      ],
    );
  }
}