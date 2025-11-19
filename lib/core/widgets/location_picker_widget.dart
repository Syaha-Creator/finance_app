import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_providers.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

/// Widget untuk memilih dan menampilkan lokasi
class LocationPickerWidget extends ConsumerStatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final Function(double latitude, double longitude, String? address)? onLocationSelected;
  final bool showLabel;

  const LocationPickerWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    this.onLocationSelected,
    this.showLabel = true,
  });

  @override
  ConsumerState<LocationPickerWidget> createState() =>
      _LocationPickerWidgetState();
}

class _LocationPickerWidgetState
    extends ConsumerState<LocationPickerWidget> {
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _address = widget.initialAddress;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation(
        includeAddress: true,
      );

      if (location != null) {
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
          _address = location.address;
        });

        widget.onLocationSelected?.call(
          location.latitude,
          location.longitude,
          location.address,
        );

        if (!mounted) return;
        CoreSnackbar.showSuccess(
          context,
          'Lokasi berhasil diperoleh',
        );
      } else {
        if (!mounted) return;
        CoreSnackbar.showError(
          context,
          'Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin lokasi sudah diberikan.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(
        context,
        'Error: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _address = null;
    });
    widget.onLocationSelected?.call(0, 0, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = _latitude != null && _longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Lokasi (Opsional)',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasLocation
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLocation) ...[
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi tersimpan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _clearLocation,
                      tooltip: 'Hapus lokasi',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (_address != null && _address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _address!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Koordinat: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ] else
                Row(
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi belum ditambahkan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: Text(
                    _isLoading ? 'Mendapatkan lokasi...' : 'Dapatkan Lokasi Saat Ini',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lokasi membantu melacak pengeluaran berdasarkan tempat untuk budgeting yang lebih akurat',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}



