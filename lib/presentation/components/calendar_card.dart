import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/data/model/reminder.dart';

/// Takvim kartı bileşeni - table_calendar paketi kullanır
class CalendarCard extends StatefulWidget {
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final ValueChanged<DateTime>? onDaySelected;
  final void Function(DateTime)? onPageChanged;
  final CalendarFormat initialFormat;
  final List<Reminder> Function(DateTime)? eventLoader;

  const CalendarCard({
    super.key,
    this.selectedDay,
    this.focusedDay,
    this.onDaySelected,
    this.onPageChanged,
    this.initialFormat = CalendarFormat.month,
    this.eventLoader,
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = widget.initialFormat;
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _selectedDay = widget.selectedDay;
  }

  @override
  void didUpdateWidget(CalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      _selectedDay = widget.selectedDay;
    }
    if (widget.focusedDay != oldWidget.focusedDay &&
        widget.focusedDay != null) {
      _focusedDay = widget.focusedDay!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Ay',
          CalendarFormat.twoWeeks: '2 Hafta',
          CalendarFormat.week: 'Hafta',
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDaySelected?.call(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          widget.onPageChanged?.call(focusedDay);
        },
        eventLoader: widget.eventLoader,
        calendarStyle: CalendarStyle(
          // Bugün
          todayDecoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
          // Seçili gün
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Varsayılan günler
          defaultTextStyle: TextStyle(color: AppColors.textPrimary),
          weekendTextStyle: TextStyle(color: AppColors.textSecondary),
          outsideTextStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          // Marker (etkinlik göstergesi)
          markerDecoration: BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primaryBlue,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primaryBlue,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        daysOfWeekHeight: 40,
        rowHeight: 48,
      ),
    );
  }
}
