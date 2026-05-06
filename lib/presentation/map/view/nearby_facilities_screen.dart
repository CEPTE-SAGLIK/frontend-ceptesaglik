import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/data/model/health_facility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:health_asistants/presentation/map/viewmodel/nearby_facilities_viewmodel.dart';

class NearbyFacilitiesScreen extends StatelessWidget {
  const NearbyFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NearbyFacilitiesViewModel(),
      child: const _NearbyFacilitiesContent(),
    );
  }
}

class _NearbyFacilitiesContent extends StatelessWidget {
  const _NearbyFacilitiesContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "Yakındaki Sağlık Kuruluşları",
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<NearbyFacilitiesViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 1. HARİTA ALANI
              Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: viewModel.isLoadingLocation
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: viewModel.initialCameraPosition,
                        onMapCreated: viewModel.onMapCreated,
                        myLocationEnabled: viewModel.hasLocationPermission,
                        myLocationButtonEnabled:
                            viewModel.hasLocationPermission,
                        markers: viewModel.markers,
                        zoomControlsEnabled: false,
                      ),
              ),

              if (viewModel.locationErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    viewModel.locationErrorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                ),

              // 2. FİLTRE BUTONLARI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FilterChip(
                      label: "Hastaneler",
                      isSelected:
                          viewModel.selectedFilter == FacilityFilter.hospital,
                      onTap: () => viewModel.setFilter(FacilityFilter.hospital),
                    ),
                    _FilterChip(
                      label: "Sağlık Ocakları",
                      isSelected:
                          viewModel.selectedFilter == FacilityFilter.clinic,
                      onTap: () => viewModel.setFilter(FacilityFilter.clinic),
                    ),
                    _FilterChip(
                      label: "Nöbetçi Eczaneler",
                      isSelected:
                          viewModel.selectedFilter == FacilityFilter.pharmacy,
                      onTap: () => viewModel.setFilter(FacilityFilter.pharmacy),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. LİSTE
              Expanded(
                child: viewModel.isLoadingFacilities
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.filteredFacilities.isEmpty
                    ? const Center(
                        child: Text(
                          "Bu bölgede sonuç bulunamadı.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: viewModel.filteredFacilities.length,
                        itemBuilder: (context, index) {
                          final facility = viewModel.filteredFacilities[index];
                          return _FacilityCard(facility: facility);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- ALT BİLEŞENLER ---

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final HealthFacility facility;

  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol İkon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(), color: _getIconColor()),
          ),
          const SizedBox(width: AppSpacing.md),

          // Orta Metinler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facility.name,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (facility.isDuty)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          "(NÖBETÇİ)",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      facility.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sağ Mesafe ve Yol Tarifi
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                facility.distanceText,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  context.read<NearbyFacilitiesViewModel>().animateToFacility(
                    facility,
                  );
                },
                child: Text(
                  "Yol Tarifi Al >",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconColor() {
    switch (facility.type) {
      case FacilityType.hospital:
        return Colors.redAccent;
      case FacilityType.clinic:
        return Colors.blueAccent;
      case FacilityType.pharmacy:
        return Colors.green;
    }
  }

  IconData _getIcon() {
    switch (facility.type) {
      case FacilityType.hospital:
        return Icons.add;
      case FacilityType.clinic:
        return Icons.home_rounded;
      case FacilityType.pharmacy:
        return Icons.medication_rounded;
    }
  }
}
