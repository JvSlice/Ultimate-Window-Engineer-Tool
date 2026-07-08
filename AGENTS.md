# UWE Codex Instructions

## Project
Ultimate Window Engineer Tool (UWE)

Mission:
Let engineers engineer faster—from one tool.

## Before Work
Always read:
- README.md
- ENGINEERING_PLAYBOOK.md
- ENGINEERING_PRINCIPLES.md
- architecture.md
- roadmap.md
- DECISIONS.md
- RELEASE_CHECKLIST.md
- relevant GitHub Issue if provided

## Workflow
1. Inspect before editing.
2. Produce a short design review before major changes.
3. Wait for Product Owner approval before large edits.
4. Prefer incremental changes.
5. Preserve existing functionality.
6. Avoid broad rewrites unless explicitly approved.
7. Provide a release review after implementation.
8. Update `assets/release_notes.md` for user-facing changes.

## UWE Rules
- Keep the black/green terminal-style UI.
- Do not break existing navigation.
- Prefer shared widgets and shared data.
- Keep calculator logic understandable.
- Include units and engineering assumptions.
- Search entries belong in the centralized search registry.
- New user-facing pages should be searchable.

## Validation
When possible run:
- dart format on changed Dart files
- flutter analyze
- flutter run or flutter build web when needed

If Flutter/Dart commands fail because of sandbox or snap permissions, state that clearly and let the Product Owner run them manually.

## Done Means
- Requirements met
- Existing behavior preserved
- Search/navigation updated if needed
- Documentation updated if architecture changed
- Release notes updated for user-facing changes
- Manual test checklist provided
- update log in splash page to show users changes made