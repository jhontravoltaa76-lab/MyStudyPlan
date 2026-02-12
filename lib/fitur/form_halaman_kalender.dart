import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'app_models.dart';
import '../services/firestore_service.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

class HalamanKalender extends StatefulWidget {
  final FirestoreService firestoreService = FirestoreService();

  HalamanKalender({Key? key}) : super(key: key);

  @override
  _HalamanKalenderState createState() => _HalamanKalenderState();
}

class _HalamanKalenderState extends State<HalamanKalender> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final LinkedHashMap<DateTime, List<EventItem>> _events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  List<EventItem> _selectedEvents = [];

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAllEvents();
  }

  void _loadAllEvents() {
    // Ambil data dari stream 'getKegiatanStream' (yang mengambil SEMUA kegiatan)
    widget.firestoreService.getKegiatanStream().listen((kegiatanList) {
      _processEvents(kegiatanList);
    });
  }

  void _processEvents(List<Kegiatan>? kegiatanList) {
    final newEvents = LinkedHashMap<DateTime, List<EventItem>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    if (kegiatanList != null) {
      // Hanya ambil kegiatan 'Harian' yang punya tanggal valid
      final kegiatanHarian = kegiatanList.where(
        (k) => k.tipeKegiatan == 'Harian' && k.tanggal != null,
      );

      for (final kegiatan in kegiatanHarian) {
        final day = _normalizeDate(kegiatan.tanggal!);
        final event = EventItem(
          nama: kegiatan.namaKegiatan,
          tipe: "Kegiatan",
          jamMulai: kegiatan.jamMulai,
          warna: Colors.teal, // Warna Teal
        );

        if (newEvents[day] == null) {
          newEvents[day] = [];
        }
        newEvents[day]!.add(event);
      }
    }

    if (mounted) {
      setState(() {
        _events.clear();
        _events.addAll(newEvents);
        _selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);
      });
    }
  }

  List<EventItem> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
        // Sortir berdasarkan jam mulai
        _selectedEvents.sort(
          (a, b) => (a.jamMulai.hour * 60 + a.jamMulai.minute).compareTo(
            b.jamMulai.hour * 60 + b.jamMulai.minute,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Kegiatan'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          TableCalendar<EventItem>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 178, 223, 219),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.black),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(formatButtonShowsNext: false),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Agenda ${DateFormat('dd MMMM yyyy').format(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(
                    child: Text('Tidak ada Kegiatan di tanggal ini.'),
                  )
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.local_activity,
                            color: event.warna,
                          ),
                          title: Text(
                            event.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Pukul: ${event.jamMulai.format(context)}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Helper wajib untuk LinkedHashMap
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
