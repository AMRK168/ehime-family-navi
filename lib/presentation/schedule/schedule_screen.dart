import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

/// スケジュール画面
/// カレンダー形式の予定表示。予約内容の自動記入。
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // モックスケジュールデータ
  final Map<DateTime, List<_ScheduleEvent>> _scheduleEvents = {
    DateTime(2026, 7, 15): [
      _ScheduleEvent(
        title: '道後温泉本館',
        time: '10:00',
        isReserved: false,
      ),
    ],
    DateTime(2026, 7, 20): [
      _ScheduleEvent(
        title: '松山城',
        time: '9:00',
        isReserved: false,
      ),
    ],
    DateTime(2026, 7, 25): [
      _ScheduleEvent(
        title: 'しまなみ海道サイクリング',
        time: '8:00',
        isReserved: true,
      ),
    ],
    DateTime(2026, 8, 1): [
      _ScheduleEvent(
        title: '愛媛県美術館 夏の特別展',
        time: '10:00',
        isReserved: true,
      ),
    ],
  };

  List<_ScheduleEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _scheduleEvents[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // カレンダー
          TableCalendar<_ScheduleEvent>(
            locale: 'ja_JP',
            firstDay: DateTime(2026, 1, 1),
            lastDay: DateTime(2027, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          // 選択日の予定リスト
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                      '日付を選択してください',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('M月d日').format(_selectedDay!)}の予定はありません',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: event.isReserved
                  ? Colors.green.shade100
                  : Colors.blue.shade100,
              child: Icon(
                event.isReserved ? Icons.check_circle : Icons.event,
                color: event.isReserved ? Colors.green : Colors.blue,
              ),
            ),
            title: Text(event.title),
            subtitle: Text(event.time),
            trailing: event.isReserved
                ? const Chip(
                    label: Text('予約済', style: TextStyle(fontSize: 11)),
                    backgroundColor: Color(0xFFE8F5E9),
                  )
                : null,
          ),
        );
      },
    );
  }
}

/// スケジュールイベント（内部モデル）
class _ScheduleEvent {
  final String title;
  final String time;
  final bool isReserved;

  const _ScheduleEvent({
    required this.title,
    required this.time,
    required this.isReserved,
  });
}
