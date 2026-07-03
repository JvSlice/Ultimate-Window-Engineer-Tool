import '../../app_theme.dart';
import 'search_models.dart';
import 'search_registry.dart';

List<SearchEntry> buildMainMenuSearchTargets(
  AppThemeController themeController,
) {
  return buildSearchRegistry(themeController);
}
