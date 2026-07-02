UWE Architecture

Let engineers engineer faster—from one tool.

Purpose

This document defines the architectural principles used throughout Ultimate Window Engineer (UWE).

Its purpose is to ensure that future development—whether performed by humans or AI—remains consistent, modular, maintainable, and easy to extend.

When making design decisions, preserving consistency is preferred over introducing unnecessary complexity.

⸻

Design Philosophy

UWE is an engineering toolbox.

Each feature should be independent, easy to maintain, and simple to discover.

The application should continue to grow without becoming difficult to navigate or maintain.

Whenever practical:

* Prefer adding new modules over modifying existing ones.
* Avoid breaking existing workflows.
* Keep engineering calculations independent from UI code.
* Keep shared data centralized.
* Reuse components whenever possible.

⸻

Project Structure

The application is organized into major engineering sections.

Examples include:

* Convert It
* Fabricate It
* Reference It
* Window Testing Tools

Future sections should fit naturally within this structure rather than creating unnecessary top-level categories.

⸻

Calculator Design

Engineering calculators should follow a consistent pattern.

Each calculator should contain:

* Title
* Description
* Inputs
* Default values
* Units
* Calculation engine
* Results
* Engineering notes
* References when appropriate

Calculation logic should remain separate from widget layout whenever practical.

⸻

Material Data

Material properties should exist in a centralized data source.

Multiple calculators should reference the same material definitions rather than maintaining duplicate values.

Example properties include:

* Coefficient of Thermal Expansion
* Density
* Modulus of Elasticity
* Thermal Conductivity
* Engineering Notes

⸻

Search System

The search system should be data-driven.

Search should never depend on manually adding custom keyword logic throughout the application.

Each searchable page or calculator should define its own metadata.

Preferred searchable fields include:

* Title
* Category
* Description
* Tags
* Aliases
* Route

Search should index this metadata automatically.

Adding a new page should require only adding one search entry.

⸻

Navigation

Navigation should remain simple and predictable.

Related engineering tools should remain grouped together.

Avoid deep navigation trees whenever possible.

Users should always understand:

* where they are
* how they arrived
* how to return

⸻

Shared Components

Common UI elements should be reused whenever possible.

Examples include:

* Calculator layout
* Input controls
* Result cards
* Search widgets
* Material selectors
* Unit selectors

Shared widgets should be preferred over duplicated UI.

⸻

Engineering Standards

Whenever engineering references are included:

* Clearly identify the governing standard.
* Do not modify published engineering formulas without explanation.
* Identify assumptions.
* Include units whenever possible.

The application should assist engineering decisions—not replace engineering judgment.

⸻

Development Guidelines

Future development should prioritize:

* Modular design
* Maintainability
* Readability
* Performance
* Expandability

Avoid unnecessary rewrites.

Prefer incremental improvements that preserve existing functionality.

⸻

AI Development Guidelines

AI assistants working on UWE should:

* Inspect existing code before making changes.
* Preserve existing functionality.
* Minimize breaking changes.
* Prefer drop-in additions over large rewrites.
* Explain architectural changes before implementing them.
* Provide testing recommendations.
* Follow this document whenever multiple implementation options exist.

When uncertain, choose the implementation that keeps the project simpler and easier to maintain.