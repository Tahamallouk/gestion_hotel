import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';

class HotelsFiltersCard extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<String> cities;
  final List<String> countries;
  final String selectedCity;
  final String selectedCountry;
  final String sort;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onCountryChanged;
  final VoidCallback? onClear;
  final bool showMap;
  final ValueChanged<bool> onToggleMap;

  const HotelsFiltersCard({
    super.key,
    required this.searchCtrl,
    required this.cities,
    required this.countries,
    required this.selectedCity,
    required this.selectedCountry,
    required this.sort,
    required this.onSortChanged,
    required this.onCityChanged,
    required this.onCountryChanged,
    required this.onClear,
    required this.showMap,
    required this.onToggleMap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recherche et filtres',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Search field
          TextFormField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Rechercher par nom, ville, adresse...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Filters row
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              // Country dropdown
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCountry.isEmpty ? null : selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Pays',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Tous les pays'),
                    ),
                    ...countries.map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    )),
                  ],
                  onChanged: onCountryChanged,
                ),
              ),
              
              // City dropdown
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCity.isEmpty ? null : selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes les villes'),
                    ),
                    ...cities.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )),
                  ],
                  onChanged: onCityChanged,
                ),
              ),
              
              // Sort dropdown
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  initialValue: sort,
                  decoration: const InputDecoration(
                    labelText: 'Trier par',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Note', child: Text('Note')),
                    DropdownMenuItem(value: 'Prix ↑', child: Text('Prix ↑')),
                    DropdownMenuItem(value: 'Prix ↓', child: Text('Prix ↓')),
                    DropdownMenuItem(value: 'Valeur', child: Text('Valeur')),
                    DropdownMenuItem(value: 'Nom', child: Text('Nom')),
                  ],
                  onChanged: (value) => onSortChanged(value ?? 'Note'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (onClear != null)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear),
                      label: const Text('Effacer filtres'),
                    ),
                ],
              ),
              Row(
                children: [
                  Text('Carte'),
                  const SizedBox(width: AppSpacing.sm),
                  Switch(
                    value: showMap,
                    onChanged: onToggleMap,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}