import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../convert_it_page.dart';
import '../fabricate_it_page.dart';
import '../fun_links_page.dart';
import '../settings_page.dart';
import '../terminal_scaffold.dart';
import '../window_testing_tools_page.dart';
import '../reference/reference_home_page.dart';

import 'search/main_menu_search_engine.dart';
import 'search/main_menu_search_overylay.dart';
import 'search/main_menu_search_targets.dart';
import 'search/search_models.dart';

class MainMenuPage extends StatefulWidget {
  final AppThemeController themeController;

  const MainMenuPage({super.key, required this.themeController});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  bool _showSearch = false;

  late final MainMenuSearchEngine _searchEngine;
  late final List<SearchTarget> _targets;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _targets = buildMainMenuSearchTargets(widget.themeController);
    _searchEngine = MainMenuSearchEngine();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });

    if (_showSearch) {
      Future.delayed(const Duration(milliseconds: 40), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _searchFocusNode.unfocus();
      _searchController.clear();
    }
  }

  void _closeSearch() {
    setState(() {
      _showSearch = false;
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  void _openTarget(SearchTarget target) {
    _closeSearch();
    _openPage(target.builder(context));
  }

  List<SearchHit> _buildSearchHits() {
    return _searchEngine.buildHits(
      query: _searchController.text,
      targets: _targets,
      onOpenTarget: _openTarget,
      onOpenConvertIt: () {
        _closeSearch();
        _openPage(const ConverItPage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = widget.themeController.accentColor;

    final verticalSpacing = size.height * 0.02;
    final gridSpacing = size.width * 0.02;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.10,
        child: OutlinedButton(
          onPressed: onPressed,
          style:
              OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  accent.withValues(alpha: 0.08),
                ),
              ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.018,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    Widget bottomCornerButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: size.width * 0.02),
        label: Text(label, style: TextStyle(fontSize: size.width * 0.016)),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: size.width * 0.002),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.02,
            vertical: size.height * 0.012,
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Ultimate Window Engineer Tool",
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: 'Search tools',
                  onPressed: _toggleSearch,
                  icon: Icon(
                    Icons.search,
                    color: accent.withValues(alpha: 0.72),
                    size: size.width > 900 ? 24 : 22,
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.25),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 1.6,
                  children: [
                    terminalButton(context, "Convert it", () {
                      _openPage(const ConverItPage());
                    }),
                    terminalButton(context, "Fabricate it", () {
                      _openPage(const FabricateItPage());
                    }),
                    terminalButton(context, "Reference it", () {
                      _openPage(const ReferenceHomePage());
                    }),
                    terminalButton(context, "Window Testing Tools", () {
                      _openPage(const WindowTestingToolsPage());
                    }),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bottomCornerButton(
                    icon: Icons.videogame_asset_outlined,
                    label: "FUN?",
                    onPressed: () {
                      _openPage(const FunLinksPage());
                    },
                  ),
                  bottomCornerButton(
                    icon: Icons.settings,
                    label: "settings",
                    onPressed: () {
                      _openPage(
                        SettingsPage(themeController: widget.themeController),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
          if (_showSearch)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSearch,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.62),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: MainMenuSearchOverlay(
                        accent: accent,
                        size: size,
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hits: _buildSearchHits(),
                        onClose: _closeSearch,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
