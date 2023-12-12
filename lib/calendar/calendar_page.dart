import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/calendar/events_example.dart';
import 'package:medical_app_belinda_full/calendar/multi_example.dart';
import 'package:medical_app_belinda_full/screens/doctor_appointment/all_appointments.dart';
import 'package:medical_app_belinda_full/screens/doctor_appointment/doctor_appointment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scheduled Events'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: const Text('Events'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TableEventsExample()),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              child: const Text('Doctor Appointment'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  DoctorAppointmentPage()),
              ),
            ),
            const SizedBox(height: 12.0),
            // ElevatedButton(
            //   child: const Text('Upcoming Doctor Appointment'),
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) =>  const AllAppointments()),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}