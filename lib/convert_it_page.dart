import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';
import 'terminal_scaffold.dart';

class ConverItPage extends StatelessWidget {
  const ConverItPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'Convert It',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConvertItBody(accent: accent),
      ),
    );
  }
}

class ConvertItBody extends StatefulWidget {
  final Color accent;
  const ConvertItBody({super.key, required this.accent});

  @override
  State<ConvertItBody> createState() => _ConvertItBodyState();
}

class _ConvertItBodyState extends State<ConvertItBody>
    with SingleTickerProviderStateMixin {
  final TextEditingController valueController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  late final TabController _tabController;

  Direction direction = Direction.to;
  String result = "";

  final List<ConversionCategory> categories = ConversionCategory.values;

  late final Map<ConversionCategory, ConversionTool?> selectedByCategory;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: categories.length, vsync: this);

    selectedByCategory = {
      for (final category in categories)
        category: conversionTools.firstWhere((tool) => tool.category == category),
    };

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        result = "";
        searchController.clear();
      });
    });
  }

  @override
  void dispose() {
    valueController.dispose();
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  ConversionCategory get currentCategory => categories[_tabController.index];

  List<ConversionTool> get currentTools {
    final query = searchController.text.trim().toLowerCase();

    return conversionTools.where((tool) {
      if (tool.category != currentCategory) return false;
      if (query.isEmpty) return true;

      return tool.label.toLowerCase().contains(query) ||
          tool.toUnit.toLowerCase().contains(query) ||
          tool.fromUnit.toLowerCase().contains(query);
    }).toList();
  }

  void convert() {
    final input = double.tryParse(valueController.text.trim());
    final selectedTool = selectedByCategory[currentCategory];

    if (input == null) {
      setState(() {
        result = "Enter a valid number";
      });
      return;
    }

    if (selectedTool == null) {
      setState(() {
        result = "Select a conversion";
      });
      return;
    }

    setState(() {
      result = selectedTool.convert(direction, input);
    });
  }

  Widget _directionButton({
    required String label,
    required Direction value,
  }) {
    final selected = direction == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            direction = value;
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: widget.accent, width: 2),
          backgroundColor: selected
              ? widget.accent.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: widget.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final filteredTools = currentTools;

    if (filteredTools.isNotEmpty &&
        !filteredTools.contains(selectedByCategory[currentCategory])) {
      selectedByCategory[currentCategory] = filteredTools.first;
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: accent,
          unselectedLabelColor: accent.withValues(alpha: 0.65),
          indicatorColor: accent,
          tabs: categories.map((category) {
            return Tab(text: categoryLabel(category));
          }).toList(),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (_) {
                      setState(() {
                        result = "";
                      });
                    },
                    style: TextStyle(color: accent),
                    decoration: InputDecoration(
                      labelText: "Search conversions",
                      labelStyle: TextStyle(color: accent),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accent, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: valueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    style: TextStyle(color: accent),
                    decoration: InputDecoration(
                      labelText: "Enter Value",
                      labelStyle: TextStyle(color: accent),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accent, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: accent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: DropdownButton<ConversionTool>(
                      value: filteredTools.contains(selectedByCategory[currentCategory])
                          ? selectedByCategory[currentCategory]
                          : (filteredTools.isNotEmpty ? filteredTools.first : null),
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Colors.black,
                      style: TextStyle(color: accent),
                      iconEnabledColor: accent,
                      onChanged: filteredTools.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                selectedByCategory[currentCategory] = value;
                                result = "";
                              });
                            },
                      items: filteredTools.map((tool) {
                        return DropdownMenuItem<ConversionTool>(
                          value: tool,
                          child: Text(
                            tool.label,
                            style: TextStyle(color: accent),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _directionButton(label: "To", value: Direction.to),
                      const SizedBox(width: 12),
                      _directionButton(label: "From", value: Direction.from),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: convert,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent, width: 2),
                        backgroundColor: accent.withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Run Conversion",
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: accent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: Text(
                      result.isEmpty ? "Result will appear here" : result,
                      style: TextStyle(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: Opacity(
                      opacity: 0.12,
                      child: Text(
                        'Convert Tool v0.3',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: accent,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
