import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/calendar/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';


class EventsCalendar extends StatefulWidget {
  const EventsCalendar({super.key});

  @override
  _EventsCalendarState createState() => _EventsCalendarState();
}

class _EventsCalendarState extends State<EventsCalendar> {
  Map<DateTime, List<Event>> _events =  {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String events = jsonEncode(_events);
    prefs.setString('events', events);
    print("love: $prefs");
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('events')) {
      String? events = prefs.getString('events');
      setState(() {
        print("Hug: $events");
        // _events = jsonDecode(events!);
        // _events = LinkedHashMap<DateTime, List<Event>>(
        //   equals: isSameDay,
        //   hashCode: getHashCode,
        // )..addAll(events);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return _events[day] ?? [];
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TableCalendar - All Events'),
      ),
      body: TableCalendar(
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        //eventLoader: _events,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }

  _showAddDialog() async {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Enter the title...',
                    labelText: 'Input your title!',
                  ),
                  onChanged: (value) {
                    setState(() {
                      //_events[_selectedDay]!.add(Event(value));
                      //_saveEvents();
                    });
                  },
                ),
                // TextFormField(
                //   decoration: const InputDecoration(
                //     filled: true,
                //     hintText: 'Enter description',
                //     labelText: 'Input your description!',
                //   ),
                //   onChanged: (value) {
                //     setState(() {
                //       //name = value;
                //     });
                //   },
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(

              onPressed: () async {
                _saveEvents();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}