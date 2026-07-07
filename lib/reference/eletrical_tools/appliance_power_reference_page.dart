import 'package:flutter/material.dart';

import '../../terminal_scaffold.dart';

class AppliancePowerReferencePage extends StatefulWidget {
  const AppliancePowerReferencePage({super.key});

  @override
  State<AppliancePowerReferencePage> createState() =>
      _AppliancePowerReferencePageState();
}

class _AppliancePowerReferencePageState
    extends State<AppliancePowerReferencePage> {
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _filterController.text.trim().toLowerCase();
    final groups = _filteredGroups(query);

    return TerminalScaffold(
      title: 'Appliance Power Usage',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _noticeCard(context),
            const SizedBox(height: 12),
            TextField(
              controller: _filterController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Filter appliances',
                hintText: 'refrigerator, well pump, generator, surge...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (groups.isEmpty)
              _terminalPanel(
                context,
                padding: const EdgeInsets.all(16),
                child: const Text('No appliance matches found.'),
              )
            else
              for (final group in groups) ...[
                _categorySection(context, group),
                const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }

  List<_ApplianceGroup> _filteredGroups(String query) {
    if (query.isEmpty) return appliancePowerGroups;

    return appliancePowerGroups
        .map((group) {
          final entries = group.entries.where((entry) {
            final searchable = [
              group.name,
              entry.name,
              entry.runningAmps,
              entry.startupAmps,
              entry.runningWatts,
              entry.startupWatts,
              entry.voltage,
              entry.breaker,
              entry.notes,
            ].join(' ').toLowerCase();
            return searchable.contains(query);
          }).toList();

          return _ApplianceGroup(group.name, entries);
        })
        .where((group) => group.entries.isNotEmpty)
        .toList();
  }

  Widget _noticeCard(BuildContext context) {
    return _terminalPanel(
      context,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Typical Reference Values',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use these values for quick load estimates, generator sizing, inverter sizing, extension cord planning, and temporary power checks. Actual nameplate ratings vary by manufacturer, model, age, duty cycle, power factor, and installation.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorySection(BuildContext context, _ApplianceGroup group) {
    final accent = Theme.of(context).colorScheme.primary;

    return _terminalPanel(
      context,
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: accent,
        collapsedIconColor: accent,
        initiallyExpanded: group.entries.length <= 8,
        title: Text(
          group.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: accent),
        ),
        subtitle: Text(
          '${group.entries.length} reference loads',
          style: TextStyle(color: accent.withValues(alpha: 0.72)),
        ),
        children: [
          for (var i = 0; i < group.entries.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: accent.withValues(alpha: 0.35)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _applianceEntry(context, group.entries[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _applianceEntry(BuildContext context, _ApplianceLoad entry) {
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.name,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: accent),
        ),
        const SizedBox(height: 10),
        _infoWrap(context, [
          _InfoItem('Run A', entry.runningAmps),
          _InfoItem('Start A', entry.startupAmps),
          _InfoItem('Run W', entry.runningWatts),
          _InfoItem('Start W', entry.startupWatts),
          _InfoItem('Voltage', entry.voltage),
          _InfoItem('Breaker', entry.breaker),
        ]),
        if (entry.notes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            entry.notes,
            style: TextStyle(color: accent.withValues(alpha: 0.78)),
          ),
        ],
      ],
    );
  }

  Widget _terminalPanel(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(0),
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        border: Border.all(color: accent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _infoWrap(BuildContext context, List<_InfoItem> items) {
    final accent = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return SizedBox(
          width: 118,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  color: accent.withValues(alpha: 0.66),
                  fontSize: 12,
                ),
              ),
              Text(
                item.value,
                style: TextStyle(color: accent, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}

class _ApplianceGroup {
  final String name;
  final List<_ApplianceLoad> entries;

  const _ApplianceGroup(this.name, this.entries);
}

class _ApplianceLoad {
  final String name;
  final String runningAmps;
  final String startupAmps;
  final String runningWatts;
  final String startupWatts;
  final String voltage;
  final String breaker;
  final String notes;

  const _ApplianceLoad({
    required this.name,
    required this.runningAmps,
    required this.startupAmps,
    required this.runningWatts,
    required this.startupWatts,
    required this.voltage,
    required this.breaker,
    required this.notes,
  });
}

const appliancePowerGroups = <_ApplianceGroup>[
  _ApplianceGroup('Kitchen', [
    _ApplianceLoad(
      name: 'Refrigerator',
      runningAmps: '3-6 A',
      startupAmps: '9-18 A',
      runningWatts: '350-700 W',
      startupWatts: '1000-2200 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes:
          'Compressor load. Surge varies strongly by size and inverter technology.',
    ),
    _ApplianceLoad(
      name: 'Freezer',
      runningAmps: '3-5 A',
      startupAmps: '9-15 A',
      runningWatts: '350-600 W',
      startupWatts: '1000-1800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Compressor load with intermittent duty cycle.',
    ),
    _ApplianceLoad(
      name: 'Microwave',
      runningAmps: '8-13 A',
      startupAmps: '8-13 A',
      runningWatts: '1000-1500 W',
      startupWatts: '1000-1500 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Input watts are higher than cooking watts.',
    ),
    _ApplianceLoad(
      name: 'Dishwasher',
      runningAmps: '6-10 A',
      startupAmps: '8-12 A',
      runningWatts: '700-1200 W',
      startupWatts: '1000-1500 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Heating cycle is usually the largest steady load.',
    ),
    _ApplianceLoad(
      name: 'Garbage Disposal',
      runningAmps: '4-8 A',
      startupAmps: '12-24 A',
      runningWatts: '500-900 W',
      startupWatts: '1500-3000 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Motor startup can be several times running load.',
    ),
    _ApplianceLoad(
      name: 'Coffee Maker',
      runningAmps: '5-10 A',
      startupAmps: '5-10 A',
      runningWatts: '600-1200 W',
      startupWatts: '600-1200 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Mostly resistive heating load.',
    ),
    _ApplianceLoad(
      name: 'Electric Kettle',
      runningAmps: '10-13 A',
      startupAmps: '10-13 A',
      runningWatts: '1200-1500 W',
      startupWatts: '1200-1500 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'High resistive load.',
    ),
    _ApplianceLoad(
      name: 'Toaster',
      runningAmps: '7-10 A',
      startupAmps: '7-10 A',
      runningWatts: '800-1200 W',
      startupWatts: '800-1200 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Resistive heating load.',
    ),
    _ApplianceLoad(
      name: 'Toaster Oven',
      runningAmps: '10-15 A',
      startupAmps: '10-15 A',
      runningWatts: '1200-1800 W',
      startupWatts: '1200-1800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Resistive heating load.',
    ),
    _ApplianceLoad(
      name: 'Electric Oven',
      runningAmps: '15-25 A',
      startupAmps: '15-25 A',
      runningWatts: '3500-6000 W',
      startupWatts: '3500-6000 W',
      voltage: '240 V',
      breaker: '30-50 A',
      notes: 'Nameplate and circuit vary by appliance.',
    ),
    _ApplianceLoad(
      name: 'Electric Range',
      runningAmps: '25-50 A',
      startupAmps: '25-50 A',
      runningWatts: '6000-12000 W',
      startupWatts: '6000-12000 W',
      voltage: '240 V',
      breaker: '40-50 A',
      notes: 'Large resistive cooking load.',
    ),
    _ApplianceLoad(
      name: 'Air Fryer',
      runningAmps: '10-15 A',
      startupAmps: '10-15 A',
      runningWatts: '1200-1800 W',
      startupWatts: '1200-1800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Heating element plus fan.',
    ),
  ]),
  _ApplianceGroup('Laundry', [
    _ApplianceLoad(
      name: 'Washing Machine',
      runningAmps: '4-8 A',
      startupAmps: '12-20 A',
      runningWatts: '500-1000 W',
      startupWatts: '1500-2400 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Motor load; high-efficiency machines may be lower.',
    ),
    _ApplianceLoad(
      name: 'Gas Dryer',
      runningAmps: '4-6 A',
      startupAmps: '8-12 A',
      runningWatts: '500-750 W',
      startupWatts: '1000-1500 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Motor and controls only; heat is gas-fired.',
    ),
    _ApplianceLoad(
      name: 'Electric Dryer',
      runningAmps: '20-30 A',
      startupAmps: '20-30 A',
      runningWatts: '4500-6000 W',
      startupWatts: '4500-6000 W',
      voltage: '240 V',
      breaker: '30 A',
      notes: 'Large resistive heating load.',
    ),
  ]),
  _ApplianceGroup('HVAC', [
    _ApplianceLoad(
      name: 'Window AC',
      runningAmps: '5-12 A',
      startupAmps: '15-36 A',
      runningWatts: '600-1400 W',
      startupWatts: '1800-4300 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Compressor surge depends on BTU rating and soft-start equipment.',
    ),
    _ApplianceLoad(
      name: 'Portable AC',
      runningAmps: '8-12 A',
      startupAmps: '18-36 A',
      runningWatts: '900-1400 W',
      startupWatts: '2200-4300 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Compressor load; check nameplate.',
    ),
    _ApplianceLoad(
      name: 'Central AC',
      runningAmps: '15-30 A',
      startupAmps: '45-90 A',
      runningWatts: '3500-7000 W',
      startupWatts: '10000-21000 W',
      voltage: '240 V',
      breaker: '30-60 A',
      notes: 'Use equipment nameplate MCA/MOCP and LRA for real sizing.',
    ),
    _ApplianceLoad(
      name: 'Furnace Blower',
      runningAmps: '3-8 A',
      startupAmps: '9-20 A',
      runningWatts: '400-900 W',
      startupWatts: '1200-2400 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Motor load; ECM blowers may run lower.',
    ),
    _ApplianceLoad(
      name: 'Heat Pump',
      runningAmps: '15-35 A',
      startupAmps: '45-100 A',
      runningWatts: '3500-8000 W',
      startupWatts: '10000-24000 W',
      voltage: '240 V',
      breaker: '30-60 A',
      notes: 'Outdoor unit and auxiliary heat can change load dramatically.',
    ),
    _ApplianceLoad(
      name: 'Space Heater',
      runningAmps: '12.5 A',
      startupAmps: '12.5 A',
      runningWatts: '1500 W',
      startupWatts: '1500 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Continuous resistive load. Avoid overloading branch circuits.',
    ),
    _ApplianceLoad(
      name: 'Dehumidifier',
      runningAmps: '3-7 A',
      startupAmps: '9-20 A',
      runningWatts: '350-800 W',
      startupWatts: '1000-2400 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Compressor load.',
    ),
    _ApplianceLoad(
      name: 'Humidifier',
      runningAmps: '0.5-3 A',
      startupAmps: '0.5-3 A',
      runningWatts: '60-350 W',
      startupWatts: '60-350 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Small fan or ultrasonic load; steam units can be much higher.',
    ),
  ]),
  _ApplianceGroup('Garage / Shop', [
    _ApplianceLoad(
      name: 'Air Compressor',
      runningAmps: '10-20 A',
      startupAmps: '30-60 A',
      runningWatts: '1200-2400 W',
      startupWatts: '3600-7200 W',
      voltage: '120/240 V',
      breaker: '20-30 A',
      notes: 'Motor startup is high; tank pressure affects starting load.',
    ),
    _ApplianceLoad(
      name: 'Shop Vacuum',
      runningAmps: '8-12 A',
      startupAmps: '16-24 A',
      runningWatts: '900-1400 W',
      startupWatts: '1900-2900 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Universal motor load.',
    ),
    _ApplianceLoad(
      name: 'Table Saw',
      runningAmps: '12-15 A',
      startupAmps: '30-45 A',
      runningWatts: '1500-1800 W',
      startupWatts: '3600-5400 W',
      voltage: '120/240 V',
      breaker: '15-30 A',
      notes: 'Startup and cutting load vary with blade and feed rate.',
    ),
    _ApplianceLoad(
      name: 'Miter Saw',
      runningAmps: '12-15 A',
      startupAmps: '25-40 A',
      runningWatts: '1500-1800 W',
      startupWatts: '3000-4800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Universal motor load.',
    ),
    _ApplianceLoad(
      name: 'Circular Saw',
      runningAmps: '10-15 A',
      startupAmps: '25-40 A',
      runningWatts: '1200-1800 W',
      startupWatts: '3000-4800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Cutting load can approach breaker limit.',
    ),
    _ApplianceLoad(
      name: 'Drill Press',
      runningAmps: '3-8 A',
      startupAmps: '9-24 A',
      runningWatts: '350-900 W',
      startupWatts: '1000-2900 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Motor size varies widely.',
    ),
    _ApplianceLoad(
      name: 'Bench Grinder',
      runningAmps: '2-6 A',
      startupAmps: '6-18 A',
      runningWatts: '250-700 W',
      startupWatts: '750-2200 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Induction motor startup load.',
    ),
    _ApplianceLoad(
      name: 'Welder - Small 120 V',
      runningAmps: '15-20 A',
      startupAmps: '15-20 A',
      runningWatts: '1800-2400 W',
      startupWatts: '1800-2400 W',
      voltage: '120 V',
      breaker: '20 A',
      notes: 'Input load depends on output current and duty cycle.',
    ),
    _ApplianceLoad(
      name: 'Welder - 240 V',
      runningAmps: '20-50 A',
      startupAmps: '20-50 A',
      runningWatts: '4800-12000 W',
      startupWatts: '4800-12000 W',
      voltage: '240 V',
      breaker: '30-60 A',
      notes: 'Use welder input rating and duty cycle.',
    ),
    _ApplianceLoad(
      name: 'Pressure Washer',
      runningAmps: '12-15 A',
      startupAmps: '25-40 A',
      runningWatts: '1400-1800 W',
      startupWatts: '3000-4800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Motor load; pump pressure affects running current.',
    ),
  ]),
  _ApplianceGroup('Home Electronics', [
    _ApplianceLoad(
      name: 'Television',
      runningAmps: '0.5-2 A',
      startupAmps: '0.5-2 A',
      runningWatts: '60-250 W',
      startupWatts: '60-250 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'LED/LCD TVs are usually lower than older displays.',
    ),
    _ApplianceLoad(
      name: 'Desktop Computer',
      runningAmps: '2-5 A',
      startupAmps: '2-6 A',
      runningWatts: '250-600 W',
      startupWatts: '250-700 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Load depends on power supply and workload.',
    ),
    _ApplianceLoad(
      name: 'Gaming PC',
      runningAmps: '4-8 A',
      startupAmps: '4-10 A',
      runningWatts: '500-1000 W',
      startupWatts: '500-1200 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'High GPU load can dominate.',
    ),
    _ApplianceLoad(
      name: 'Laptop Charger',
      runningAmps: '0.5-2 A',
      startupAmps: '0.5-2 A',
      runningWatts: '45-240 W',
      startupWatts: '45-240 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'USB-C chargers vary widely.',
    ),
    _ApplianceLoad(
      name: 'Monitor',
      runningAmps: '0.2-1 A',
      startupAmps: '0.2-1 A',
      runningWatts: '25-120 W',
      startupWatts: '25-120 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Large displays can be higher.',
    ),
    _ApplianceLoad(
      name: 'Printer',
      runningAmps: '1-8 A',
      startupAmps: '1-10 A',
      runningWatts: '100-900 W',
      startupWatts: '100-1200 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Laser printer fusers draw much more than inkjet printers.',
    ),
    _ApplianceLoad(
      name: 'Ceiling Fan',
      runningAmps: '0.3-1 A',
      startupAmps: '1-3 A',
      runningWatts: '35-120 W',
      startupWatts: '120-360 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Motor load plus light kit if installed.',
    ),
    _ApplianceLoad(
      name: 'Box Fan',
      runningAmps: '0.5-1.5 A',
      startupAmps: '1.5-4 A',
      runningWatts: '60-180 W',
      startupWatts: '180-500 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Small motor load.',
    ),
    _ApplianceLoad(
      name: 'LED Lighting',
      runningAmps: '0.1-2 A',
      startupAmps: '0.1-2 A',
      runningWatts: '10-250 W',
      startupWatts: '10-250 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Total depends on number of lamps and fixtures.',
    ),
    _ApplianceLoad(
      name: 'Vacuum Cleaner',
      runningAmps: '8-12 A',
      startupAmps: '12-20 A',
      runningWatts: '900-1400 W',
      startupWatts: '1500-2400 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Universal motor load.',
    ),
  ]),
  _ApplianceGroup('Water Systems', [
    _ApplianceLoad(
      name: 'Sump Pump - 1/3 HP',
      runningAmps: '4-7 A',
      startupAmps: '12-21 A',
      runningWatts: '500-800 W',
      startupWatts: '1500-2500 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Pump startup can be high under head pressure.',
    ),
    _ApplianceLoad(
      name: 'Sump Pump - 1/2 HP',
      runningAmps: '6-10 A',
      startupAmps: '18-30 A',
      runningWatts: '700-1200 W',
      startupWatts: '2200-3600 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Use nameplate for generator sizing.',
    ),
    _ApplianceLoad(
      name: 'Well Pump - 1/2 HP',
      runningAmps: '5-7 A',
      startupAmps: '15-25 A',
      runningWatts: '1200-1700 W',
      startupWatts: '3500-6000 W',
      voltage: '240 V',
      breaker: '15-20 A',
      notes: 'Deep well pump loads vary by depth and controller.',
    ),
    _ApplianceLoad(
      name: 'Well Pump - 1 HP',
      runningAmps: '8-12 A',
      startupAmps: '25-40 A',
      runningWatts: '2000-3000 W',
      startupWatts: '6000-10000 W',
      voltage: '240 V',
      breaker: '20-30 A',
      notes: 'Use pump controller/nameplate for actual locked rotor data.',
    ),
    _ApplianceLoad(
      name: 'Sewage Ejector Pump',
      runningAmps: '7-12 A',
      startupAmps: '20-36 A',
      runningWatts: '800-1400 W',
      startupWatts: '2400-4300 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Motor load; solids handling pumps may be higher.',
    ),
  ]),
  _ApplianceGroup('Outdoor', [
    _ApplianceLoad(
      name: 'Electric Lawn Mower',
      runningAmps: '10-13 A',
      startupAmps: '20-35 A',
      runningWatts: '1200-1500 W',
      startupWatts: '2400-4200 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Corded motor load; battery chargers are lower.',
    ),
    _ApplianceLoad(
      name: 'String Trimmer',
      runningAmps: '3-7 A',
      startupAmps: '6-14 A',
      runningWatts: '350-800 W',
      startupWatts: '700-1700 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Corded motor load.',
    ),
    _ApplianceLoad(
      name: 'Leaf Blower',
      runningAmps: '7-12 A',
      startupAmps: '12-24 A',
      runningWatts: '800-1400 W',
      startupWatts: '1500-2900 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Universal motor load.',
    ),
  ]),
  _ApplianceGroup('Miscellaneous', [
    _ApplianceLoad(
      name: 'Hair Dryer',
      runningAmps: '12-15 A',
      startupAmps: '12-15 A',
      runningWatts: '1500-1800 W',
      startupWatts: '1500-1800 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'High resistive heating load.',
    ),
    _ApplianceLoad(
      name: 'Curling Iron',
      runningAmps: '0.3-1.5 A',
      startupAmps: '0.3-1.5 A',
      runningWatts: '40-180 W',
      startupWatts: '40-180 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'Small heating load.',
    ),
    _ApplianceLoad(
      name: 'Clothes Iron',
      runningAmps: '8-13 A',
      startupAmps: '8-13 A',
      runningWatts: '1000-1500 W',
      startupWatts: '1000-1500 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Thermostat cycles the heating element.',
    ),
    _ApplianceLoad(
      name: 'Phone Charger',
      runningAmps: '0.1-0.5 A',
      startupAmps: '0.1-0.5 A',
      runningWatts: '5-60 W',
      startupWatts: '5-60 W',
      voltage: '120 V',
      breaker: '15 A',
      notes: 'USB charger load.',
    ),
    _ApplianceLoad(
      name: 'Battery Charger',
      runningAmps: '1-10 A',
      startupAmps: '1-10 A',
      runningWatts: '100-1200 W',
      startupWatts: '100-1200 W',
      voltage: '120 V',
      breaker: '15-20 A',
      notes: 'Tool, automotive, and inverter chargers vary widely.',
    ),
    _ApplianceLoad(
      name: 'CPAP Machine',
      runningAmps: '0.3-1 A',
      startupAmps: '0.3-1 A',
      runningWatts: '30-90 W',
      startupWatts: '30-90 W',
      voltage: '120 V',
      breaker: '15 A',
      notes:
          'Humidifier heater increases load. Critical loads should be verified from the power supply label.',
    ),
  ]),
];
