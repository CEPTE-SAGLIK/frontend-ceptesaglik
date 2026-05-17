import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Bileşenler
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/components/calendar_card.dart';
import 'package:health_asistants/presentation/components/empty_state_widget.dart';

// ViewModel
import 'package:health_asistants/presentation/calendar/viewmodel/calendar_viewmodel.dart';

// Model
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart';

// Yardımcılar / Bileşenler
import 'package:health_asistants/core/utils/audience_helper.dart';
import 'package:health_asistants/presentation/components/add_person_sheet.dart';

// Renkler ve Sabitler
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().loadEvents();
    });
  }

  String _formatSelectedDate(DateTime date) {
    return "${DateFormat('d MMMM', 'tr_TR').format(date)} Detayları";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Consumer<CalendarViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TAKVİM KARTI
                  CalendarCard(
                    selectedDay: viewModel.selectedDay,
                    focusedDay: viewModel.focusedDay,
                    eventLoader: viewModel.getEventsForDay,
                    onDaySelected: (date) {
                      viewModel.selectDay(date, date);
                    },
                    onPageChanged: viewModel.onPageChanged,
                  ),

                  const SizedBox(height: 25),

                  // 2. TARİH DETAY BAŞLIĞI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatSelectedDate(viewModel.selectedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "${viewModel.selectedDayEvents.length} etkinlik",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 3. ETKİNLİK LİSTESİ
                  if (viewModel.selectedDayEvents.isEmpty)
                    EmptyStateWidget.noEvents(
                      onAction: () => _showAddEventBottomSheet(context),
                    )
                  else
                    ...viewModel.selectedDayEvents.map(
                      (event) => _buildEventCard(context, viewModel, event),
                    ),

                  const SizedBox(height: 20),

                  // 4. YENİ ETKİNLİK EKLE BUTONU
                  CustomButton(
                    text: "Yeni Etkinlik Ekle",
                    icon: Icons.add_circle,
                    backgroundColor: AppColors.primaryBlue,
                    borderRadius: 30.0,
                    onPressed: () => _showAddEventBottomSheet(context),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    CalendarViewModel viewModel,
    Reminder event,
  ) {
    final timeFormat = DateFormat('HH:mm');
    final eventColor = viewModel.getEventColor(event.type);
    final eventIcon = viewModel.getEventIcon(event.type);
    final sepIdx = event.title.indexOf(' — ');
    final displayTitle =
        sepIdx > 0 ? event.title.substring(sepIdx + 3) : event.title;
    final personName = sepIdx > 0 ? event.title.substring(0, sepIdx) : null;

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final ok = await viewModel.deleteEvent(event.id);
        if (!ok && context.mounted) {
          SnackbarHelper.showError(context, viewModel.errorMessage ?? 'Silinemedi');
        }
        return ok;
      },
      onDismissed: (_) {
        // Liste viewModel içinde güncelleniyor
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: AppShadows.soft,
          border: Border(left: BorderSide(color: eventColor, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: eventColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(eventIcon, color: eventColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: !event.isActive
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (personName != null) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: eventColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        personName,
                        style: TextStyle(
                          fontSize: 10,
                          color: eventColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (event.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeFormat.format(event.dateTime),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.repeatType != RepeatType.none)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: eventColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRepeatLabel(event.repeatType),
                      style: TextStyle(
                        fontSize: 10,
                        color: eventColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: !event.isActive,
                onChanged: (_) async {
                    final ok = await viewModel.toggleEventCompletion(event.id);
                    if (!ok && context.mounted) {
                      SnackbarHelper.showError(context, viewModel.errorMessage ?? 'Güncellenemedi');
                    }
                  },
                activeColor: AppColors.checkboxActive,
                side: const BorderSide(
                  color: AppColors.textSecondary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _audienceLabel(AudienceGroup g) {
    switch (g) {
      case AudienceGroup.adult:
        return 'Yetişkin';
      case AudienceGroup.elderly:
        return 'Yaşlı';
      case AudienceGroup.child:
        return 'Çocuk';
    }
  }

  String _getRepeatLabel(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return 'Günlük';
      case RepeatType.weekly:
        return 'Haftalık';
      case RepeatType.monthly:
        return 'Aylık';
      case RepeatType.none:
        return '';
    }
  }

  Future<void> _showAddEventBottomSheet(BuildContext context) async {
    final viewModel = context.read<CalendarViewModel>();
    await viewModel.loadPersons();
    if (!context.mounted) return;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedTypeIndex = 0;
    RepeatType selectedRepeatType = RepeatType.none;
    Person? selectedPerson = viewModel.selfPerson;
    AudienceGroup selectedAudience = viewModel.selfPerson != null
        ? audienceForPerson(viewModel.selfPerson!)
        : AudienceGroup.adult;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredPersons = viewModel.persons
                .where((p) => audienceForPerson(p) == selectedAudience)
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Yeni Etkinlik Ekle",
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      DateFormat(
                        'd MMMM yyyy',
                        'tr_TR',
                      ).format(viewModel.selectedDay),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 24),

                    // Etkinlik Türü Seçimi
                    Text(
                      "Etkinlik Türü",
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.eventTypes.length,
                        itemBuilder: (context, index) {
                          final type = viewModel.eventTypes[index];
                          final isSelected = selectedTypeIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedTypeIndex = index;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? type.color.withValues(alpha: 0.15)
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? type.color
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(type.icon, color: type.color, size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    type.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? type.color
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Yaş Grubu Seçimi
                    Text(
                      "Yaş Grubu",
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final g in AudienceGroup.values) ...[
                          if (g != AudienceGroup.values.first)
                            const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Text(
                                _audienceLabel(g),
                                style: const TextStyle(fontSize: 13),
                              ),
                              selected: selectedAudience == g,
                              onSelected: (_) => setModalState(() {
                                selectedAudience = g;
                                if (selectedPerson != null &&
                                    audienceForPerson(selectedPerson!) != g) {
                                  final m = viewModel.persons
                                      .where(
                                          (p) => audienceForPerson(p) == g)
                                      .toList();
                                  selectedPerson =
                                      m.isNotEmpty ? m.first : null;
                                }
                              }),
                              selectedColor: AppColors.primaryBlue,
                              labelStyle: TextStyle(
                                color: selectedAudience == g
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Başlık Input
                    Text(
                      "Başlık",
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Etkinlik başlığı girin",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // Kişi Seçimi (seçili yaş grubundaki kişiler)
                    ...[
                      const SizedBox(height: 16),
                      Text(
                        "Kişi",
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (filteredPersons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Bu yaş grubunda kişi yok. "Ekle" ile yeni kişi ekleyebilirsiniz.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredPersons.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == filteredPersons.length) {
                              return GestureDetector(
                                onTap: () async {
                                  final draft =
                                      await showAddPersonSheet(context);
                                  if (draft != null) {
                                    final newPerson =
                                        await viewModel.addPerson(draft);
                                    if (newPerson != null) {
                                      setModalState(() {
                                        selectedAudience =
                                            audienceForPerson(newPerson);
                                        selectedPerson = newPerson;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.primaryBlue),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add,
                                          size: 16,
                                          color: AppColors.primaryBlue),
                                      const SizedBox(width: 4),
                                      Text('Ekle',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.primaryBlue)),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final Person person = filteredPersons[index];
                            final bool isSelected =
                                selectedPerson?.id == person.id;
                            final bool isSelf =
                                person.id == viewModel.selfPerson?.id;
                            final String label = isSelf ? 'Ben' : person.name;
                            return ChoiceChip(
                              label: Text(
                                label,
                                style: const TextStyle(fontSize: 13),
                              ),
                              selected: isSelected,
                              onSelected: (_) => setModalState(() {
                                selectedPerson = person;
                              }),
                              selectedColor: AppColors.primaryBlue,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              side: isSelected
                                  ? BorderSide.none
                                  : const BorderSide(color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Açıklama Input
                    Text(
                      "Açıklama (Opsiyonel)",
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: "Açıklama girin",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Saat ve Tekrar Satırı
                    Row(
                      children: [
                        // Saat Seçici
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setModalState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedTime.format(context),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Tekrar Seçici
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<RepeatType>(
                                value: selectedRepeatType,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.primaryBlue,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: RepeatType.none,
                                    child: Text("Tekrar Yok"),
                                  ),
                                  DropdownMenuItem(
                                    value: RepeatType.daily,
                                    child: Text("Günlük"),
                                  ),
                                  DropdownMenuItem(
                                    value: RepeatType.weekly,
                                    child: Text("Haftalık"),
                                  ),
                                  DropdownMenuItem(
                                    value: RepeatType.monthly,
                                    child: Text("Aylık"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedRepeatType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            SnackbarHelper.showError(context, 'Lütfen bir başlık girin');
                            return;
                          }

                          final selectedType =
                              viewModel.eventTypes[selectedTypeIndex];
                          final title = titleController.text.trim();

                          final isSelf = selectedPerson == null ||
                              selectedPerson!.id ==
                                  viewModel.selfPerson?.id;
                          final String? personName = isSelf
                              ? null
                              : '${selectedPerson!.name} ${selectedPerson!.surname}'
                                  .trim();

                          final success = await viewModel.addEvent(
                            title: title,
                            description:
                                descriptionController.text.trim().isNotEmpty
                                ? descriptionController.text.trim()
                                : null,
                            type: selectedType.type,
                            time: selectedTime,
                            repeatType: selectedRepeatType,
                            audienceGroup: selectedAudience,
                            audienceBirthDate:
                                (selectedPerson ?? viewModel.selfPerson)
                                    ?.birthDate,
                            personName: personName,
                            targetPersonId:
                                isSelf ? null : selectedPerson!.id,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          if (success) {
                            SnackbarHelper.showSuccess(context, '$title eklendi');
                          } else {
                            SnackbarHelper.showError(context, viewModel.errorMessage ?? 'Etkinlik eklenemedi');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Etkinlik Ekle",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
