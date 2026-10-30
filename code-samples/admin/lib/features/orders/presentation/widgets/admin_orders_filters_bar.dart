import 'package:flutter/material.dart';

import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/design_system/app_palette.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../domain/entities/admin_order_enums.dart';
import '../../domain/entities/admin_order_filters.dart';
import '../view_data/admin_order_view_data.dart';

class AdminOrdersFiltersBar extends StatefulWidget {
  const AdminOrdersFiltersBar({
    required this.filters,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onPaymentMethodChanged,
    required this.onPaymentStatusChanged,
    required this.onDateFromChanged,
    required this.onDateToChanged,
    required this.onSortChanged,
    required this.onClear,
    super.key,
  });

  final AdminOrderFilters filters;
  final void Function(String, {bool applyFilters}) onSearchChanged;
  final ValueChanged<AdminOrderStatus?> onStatusChanged;
  final ValueChanged<AdminPaymentMethod?> onPaymentMethodChanged;
  final ValueChanged<AdminPaymentStatus?> onPaymentStatusChanged;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;
  final ValueChanged<AdminOrderSort> onSortChanged;
  final VoidCallback onClear;

  @override
  State<AdminOrdersFiltersBar> createState() => _AdminOrdersFiltersBarState();
}

class _AdminOrdersFiltersBarState extends State<AdminOrdersFiltersBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.search);
  }

  @override
  void didUpdateWidget(AdminOrdersFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final search = widget.filters.search ?? '';
    if (_searchController.text != search) {
      _searchController.text = search;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);
    final semanticColors = Theme.of(context).semanticColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: semanticColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding(screen)),
        child: screen.isCompact
            ? _CompactFilters(host: this)
            : _WideFilters(host: this),
      ),
    );
  }
}

class _WideFilters extends StatelessWidget {
  const _WideFilters({required this.host});

  final _AdminOrdersFiltersBarState host;

  @override
  Widget build(BuildContext context) {
    final AdminOrderFilters filters = host.widget.filters;

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(width: 260, child: _SearchField(host: host)),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: host._searchController,
          builder: (_, value, _) {
            if (value.text.isNotEmpty) {
              return OutlinedButton(
                onPressed: () {
                  final String searchText = value.text;
                  host.widget.onSearchChanged(searchText, applyFilters: true);
                },
                child: const Text("بحث"),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(
          width: 170,
          child: _StatusDropdown(host: host, value: filters.status),
        ),
        SizedBox(
          width: 150,
          child: _PaymentMethodDropdown(
            host: host,
            value: filters.paymentMethod,
          ),
        ),
        SizedBox(
          width: 160,
          child: _PaymentStatusDropdown(
            host: host,
            value: filters.paymentStatus,
          ),
        ),
        SizedBox(
          width: 150,
          child: _DateButton(
            label: 'من تاريخ',
            value: filters.dateFrom,
            onChanged: host.widget.onDateFromChanged,
          ),
        ),
        SizedBox(
          width: 150,
          child: _DateButton(
            label: 'إلى تاريخ',
            value: filters.dateTo,
            onChanged: host.widget.onDateToChanged,
          ),
        ),
        SizedBox(
          width: 180,
          child: _SortDropdown(host: host, value: filters.sort),
        ),
        TextButton.icon(
          onPressed: host.widget.onClear,
          icon: const Icon(Icons.clear),
          label: const Text('مسح'),
        ),
      ],
    );
  }
}

class _CompactFilters extends StatelessWidget {
  const _CompactFilters({required this.host});

  final _AdminOrdersFiltersBarState host;

  @override
  Widget build(BuildContext context) {
    final AdminOrderFilters filters = host.widget.filters;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text('البحث والفلاتر', style: AppTextStyles.sectionTitle(context)),
      initiallyExpanded: true,
      children: [
        _SearchField(host: host),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: host._searchController,
          builder: (context, value, child) {
            if (value.text.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final String searchText = value.text;
                      host.widget.onSearchChanged(
                        searchText,
                        applyFilters: true,
                      );
                    },
                    child: const Text('بحث'),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _StatusDropdown(host: host, value: filters.status),
        const SizedBox(height: AppSpacing.md),
        _PaymentMethodDropdown(host: host, value: filters.paymentMethod),
        const SizedBox(height: AppSpacing.md),
        _PaymentStatusDropdown(host: host, value: filters.paymentStatus),
        const SizedBox(height: AppSpacing.md),
        _DateButton(
          label: 'من تاريخ',
          value: filters.dateFrom,
          onChanged: host.widget.onDateFromChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _DateButton(
          label: 'إلى تاريخ',
          value: filters.dateTo,
          onChanged: host.widget.onDateToChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _SortDropdown(host: host, value: filters.sort),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: host.widget.onClear,
            icon: const Icon(Icons.clear),
            label: const Text('مسح الفلاتر'),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.host});

  final _AdminOrdersFiltersBarState host;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('admin-orders-search-field'),
      controller: host._searchController,
      onChanged: (value) {
        if (value.isEmpty) {
          host.widget.onSearchChanged(value, applyFilters: true);
        } else {
          host.widget.onSearchChanged(value, applyFilters: false);
        }
      },
      onSubmitted: (value) {
        host.widget.onSearchChanged(value, applyFilters: true);
      },
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        labelText: 'بحث',
        hintText: 'رقم الطلب أو العميل أو الهاتف',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.host, required this.value});

  final _AdminOrdersFiltersBarState host;
  final AdminOrderStatus? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AdminOrderStatus?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'حالة الطلب'),
      items: [
        const DropdownMenuItem(value: null, child: Text('كل الحالات')),
        for (final status in AdminOrderStatus.values)
          DropdownMenuItem(value: status, child: Text(status.arabicLabel)),
      ],
      onChanged: host.widget.onStatusChanged,
    );
  }
}

class _PaymentMethodDropdown extends StatelessWidget {
  const _PaymentMethodDropdown({required this.host, required this.value});

  final _AdminOrdersFiltersBarState host;
  final AdminPaymentMethod? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AdminPaymentMethod?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'طريقة الدفع'),
      items: [
        const DropdownMenuItem(value: null, child: Text('الكل')),
        for (final method in AdminPaymentMethod.values)
          DropdownMenuItem(value: method, child: Text(method.arabicLabel)),
      ],
      onChanged: host.widget.onPaymentMethodChanged,
    );
  }
}

class _PaymentStatusDropdown extends StatelessWidget {
  const _PaymentStatusDropdown({required this.host, required this.value});

  final _AdminOrdersFiltersBarState host;
  final AdminPaymentStatus? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AdminPaymentStatus?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'حالة الدفع'),
      items: [
        const DropdownMenuItem(value: null, child: Text('الكل')),
        for (final status in AdminPaymentStatus.values)
          DropdownMenuItem(value: status, child: Text(status.arabicLabel)),
      ],
      onChanged: host.widget.onPaymentStatusChanged,
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.host, required this.value});

  final _AdminOrdersFiltersBarState host;
  final AdminOrderSort value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AdminOrderSort>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'الترتيب'),
      items: [
        for (final sort in AdminOrderSort.values)
          DropdownMenuItem(value: sort, child: Text(sort.arabicLabel)),
      ],
      onChanged: (value) {
        if (value != null) {
          host.widget.onSortChanged(value);
        }
      },
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _pickDate(context),
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text(value == null ? label : _dateOnly(value!)),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!context.mounted) {
      return;
    }
    onChanged(picked);
  }

  String _dateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
