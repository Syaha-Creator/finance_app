import 'package:flutter/material.dart';

class MonthSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final bool showYear;

  const MonthSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.showYear = true,
  });

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
    widget.onDateChanged(_selectedDate);
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
    widget.onDateChanged(_selectedDate);
  }

  void _selectCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, 1);
    });
    widget.onDateChanged(_selectedDate);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentMonth =
        _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Gunakan constraints yang tersedia atau default yang aman
        final availableHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight.clamp(
                  40.0,
                  80.0,
                ) // Clamp antara 40-80 untuk mencegah overflow
                : 56.0; // Default height yang aman

        // Tentukan apakah perlu compact layout
        final isCompact = availableHeight < 50;

        return Container(
          width: double.infinity,
          height: availableHeight,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCompact ? 2 : 8, // Adaptive padding
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous month button
              _MonthButton(
                icon: Icons.chevron_left_rounded,
                onTap: _previousMonth,
                isEnabled: true,
                size: isCompact ? 28 : 36, // Adaptive button size
              ),

              // Current month display
              Expanded(
                child: GestureDetector(
                  onTap: _selectCurrentMonth,
                  child: Container(
                    height: isCompact ? 28 : 40, // Adaptive height
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isCompact ? 1 : 2, // Adaptive padding
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isCurrentMonth
                                ? [
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.8,
                                  ),
                                ]
                                : [
                                  theme.colorScheme.surfaceContainerHighest,
                                  theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.9),
                                ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isCurrentMonth
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                )
                                : theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCurrentMonth
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline)
                              .withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: SizedBox(
                        height:
                            isCompact
                                ? 40
                                : 52, // Height yang lebih besar lagi untuk jarak yang lebih jauh
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Month text - di atas dengan jarak yang sangat jauh
                            Positioned(
                              top: isCompact ? -2 : 0,
                              child: Text(
                                _getMonthName(_selectedDate.month),
                                style: (isCompact
                                        ? theme.textTheme.bodyMedium
                                        : theme.textTheme.bodyLarge)
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700, // Lebih bold
                                      color:
                                          isCurrentMonth
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                      letterSpacing: 0.2,
                                      fontSize:
                                          isCompact
                                              ? 12
                                              : 14, // Font size yang lebih besar
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Year text - di bawah dengan jarak yang sangat jauh
                            Positioned(
                              bottom: isCompact ? -2 : 0,
                              child: Text(
                                _selectedDate.year.toString(),
                                style: (isCompact
                                        ? theme.textTheme.bodySmall
                                        : theme.textTheme.bodyMedium)
                                    ?.copyWith(
                                      color:
                                          isCurrentMonth
                                              ? theme.colorScheme.primary
                                                  .withValues(alpha: 0.7)
                                              : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                      fontSize:
                                          isCompact
                                              ? 9
                                              : 11, // Font size yang lebih kecil dari bulan
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Next month button
              _MonthButton(
                icon: Icons.chevron_right_rounded,
                onTap: _nextMonth,
                isEnabled: true,
                size: isCompact ? 28 : 36, // Adaptive button size
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;
  final double size;

  const _MonthButton({
    required this.icon,
    required this.onTap,
    required this.isEnabled,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size > 32 ? 6 : 3), // Adaptive padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isEnabled
                      ? [
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.8,
                        ),
                      ]
                      : [
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.2,
                        ),
                      ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isEnabled
                      ? theme.colorScheme.outline.withValues(alpha: 0.2)
                      : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: size > 32 ? 20 : 16, // Adaptive icon size
            color:
                isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

// Year selector widget
class YearSelector extends StatefulWidget {
  final int selectedYear;
  final Function(int) onYearChanged;
  final int minYear;
  final int maxYear;

  const YearSelector({
    super.key,
    required this.selectedYear,
    required this.onYearChanged,
    this.minYear = 2020,
    this.maxYear = 2030,
  });

  @override
  State<YearSelector> createState() => _YearSelectorState();
}

class _YearSelectorState extends State<YearSelector> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedYear;
  }

  void _previousYear() {
    if (_selectedYear > widget.minYear) {
      setState(() {
        _selectedYear--;
      });
      widget.onYearChanged(_selectedYear);
    }
  }

  void _nextYear() {
    if (_selectedYear < widget.maxYear) {
      setState(() {
        _selectedYear++;
      });
      widget.onYearChanged(_selectedYear);
    }
  }

  void _selectCurrentYear() {
    final now = DateTime.now();
    setState(() {
      _selectedYear = now.year;
    });
    widget.onYearChanged(_selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentYear = _selectedYear == DateTime.now().year;
    final canGoPrevious = _selectedYear > widget.minYear;
    final canGoNext = _selectedYear < widget.maxYear;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous year button
          _MonthButton(
            icon: Icons.chevron_left_rounded,
            onTap: _previousYear,
            isEnabled: canGoPrevious,
          ),

          const SizedBox(width: 16),

          // Current year display
          Expanded(
            child: GestureDetector(
              onTap: _selectCurrentYear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isCurrentYear
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isCurrentYear
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                  ),
                ),
                child: Text(
                  _selectedYear.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color:
                        isCurrentYear
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Next year button
          _MonthButton(
            icon: Icons.chevron_right_rounded,
            onTap: _nextYear,
            isEnabled: canGoNext,
          ),
        ],
      ),
    );
  }
}

class MonthSelectorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const MonthSelectorAppBar({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.onDateChanged,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SizedBox(
          height: 70,
          child: MonthSelector(
            selectedDate: selectedDate,
            onDateChanged: onDateChanged,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(126); // 56 (AppBar) + 70 (MonthSelector)
}
