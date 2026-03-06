import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import 'material_data.dart';
import 'material_models.dart';
import 'material_details_page.dart';

class MaterialReferencePage extends StatefulWidget {
  const MaterialReferencePage({super.key});

  @override
  State<MaterialReferencePage> createState() => _MaterialReferencePageState();
}

class _MaterialReferencePageState extends State<MaterialReferencePage> {
  MaterialCategory? filter; // null = all
  final searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesSearch(MaterialSpec m, String query) {
    if (query.isEmpty) return true;

    final q = query.toLowerCase();

    return m.name.toLowerCase().contains(q) ||
        m.category.name.toLowerCase().contains(q) ||
        (m.commonUse?.toLowerCase().contains(q) ?? false) ||
        (m.notes?.toLowerCase().contains(q) ?? false) ||
        (m.weldNotes?.toLowerCase().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final query = searchCtrl.text.trim();

    final list = materials
        .where((m) => filter == null ? true : m.category == filter)
        .where((m) => _matchesSearch(m, query))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return TerminalScaffold(
      title: "Material Reference",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Search by material, category, use, or notes.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 14),

            // SEARCH BAR
            TextField(
              controller: searchCtrl,
              onChanged: (_) {
                setState(() {});
              },
              style: TextStyle(color: accent),
              decoration: InputDecoration(
                labelText: "Search materials",
                labelStyle: TextStyle(color: accent.withValues(alpha: 0.8)),
                hintText: "ex: 5160, aluminum, Delrin, handle, structural",
                hintStyle: TextStyle(color: accent.withValues(alpha: 0.5)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: accent),
                        onPressed: () {
                          setState(() {
                            searchCtrl.clear();
                          });
                        },
                      )
                    : Icon(Icons.search, color: accent),
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _filterChip(accent, "ALL", null),
                _filterChip(accent, "STEEL", MaterialCategory.steel),
                _filterChip(accent, "ALUMINUM", MaterialCategory.aluminum),
                _filterChip(accent, "PLASTIC", MaterialCategory.plastic),
                _filterChip(accent, "WOOD", MaterialCategory.wood),
              ],
            ),

            const SizedBox(height: 16),

            terminalResultCard(
              accent: accent,
              lines: [
                "Showing: ${filter == null ? 'All' : filter!.name.toUpperCase()}",
                "Search: ${query.isEmpty ? 'None' : query}",
                "Count: ${list.length}",
              ],
            ),

            const SizedBox(height: 16),

            if (list.isEmpty)
              terminalResultCard(
                accent: accent,
                lines: const [
                  "No materials matched your search.",
                ],
              )
            else
              ...list.map((m) => _materialTile(context, accent, m)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(Color accent, String label, MaterialCategory? value) {
    final selected = filter == value;
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: () => setState(() => filter = value),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.80)
              : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(color: accent, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _materialTile(BuildContext context, Color accent, MaterialSpec m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MaterialDetailPage(material: m),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                m.name,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              m.category.name.toUpperCase(),
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}
