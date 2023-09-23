import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/calendar/events_example.dart';
import 'package:medical_app_belinda_full/calendar/multi_example.dart';


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
        title: const Text('TableCalendar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            // ElevatedButton(
            //   child: Text('Basics'),
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => TableBasicsExample()),
            //   ),
            // ),
            // const SizedBox(height: 12.0),
            // ElevatedButton(
            //   child: Text('Range Selection'),
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => TableRangeExample()),
            //   ),
            // ),
            // const SizedBox(height: 12.0),
            ElevatedButton(
              child: const Text('Events'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TableEventsExample()),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              child: const Text('Multiple Selection'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableMultiExample()),
              ),
            ),
            // const SizedBox(height: 12.0),
            // ElevatedButton(
            //   child: Text('Complex'),
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => TableComplexExample()),
            //   ),
            // ),
            // const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}