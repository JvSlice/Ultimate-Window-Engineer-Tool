# Engineering Principles

> **Build software that helps engineers engineer faster—from one tool.**

This document defines the engineering philosophy behind this project. It exists to ensure that every engineering decision—whether made by a human or AI—supports the long-term vision of building practical, reliable engineering software.

These principles apply to architecture, feature development, user experience, documentation, and code quality.

---

# The Mission

Every decision should support one question:

> **Does this help engineers solve real-world problems faster and with greater confidence?**

If the answer is yes, it belongs in the project.

If not, it should be reconsidered.

---

# Engineering Before Software

This project exists to solve engineering problems—not to showcase programming techniques.

Engineering accuracy always takes priority over software cleverness.

Prefer:

- Correct calculations
- Clear assumptions
- Explainable results
- Consistent behavior

over technical novelty.

---

# Solve Real Problems

Every feature should solve a real engineering problem.

Features should come from:

- Daily engineering work
- Design reviews
- Manufacturing
- Product testing
- Fabrication
- Field observations
- Customer needs

Avoid adding features simply because they are interesting.

---

# Simplicity Wins

The best solution is usually the simplest one that satisfies the requirements.

Prefer:

- fewer classes
- fewer files
- fewer abstractions
- fewer dependencies

Do not add complexity in anticipation of hypothetical future needs.

---

# Build Once, Reuse Everywhere

Whenever possible:

Build reusable systems instead of one-off solutions.

Examples:

- Shared calculators
- Shared material databases
- Shared search metadata
- Shared widgets
- Shared engineering references

A feature should become a building block for future features.

---

# Protect Working Code

Working code has value.

Do not rewrite functioning systems without a measurable benefit.

Prefer:

- incremental improvements
- targeted refactoring
- drop-in replacements

Large rewrites require strong justification.

---

# Data Should Live in One Place

Engineering data should have a single source of truth.

Avoid duplicated:

- material properties
- conversion factors
- engineering constants
- standards references

If multiple tools use the same information, that information should be centralized.

---

# Consistency Over Cleverness

Users should never wonder how a tool works.

Every calculator should feel like every other calculator.

Every reference page should feel like every other reference page.

Consistency builds confidence.

---

# Search Is a Core Feature

Search is not an afterthought.

Every new tool should be immediately discoverable.

Search should be:

- metadata driven
- centralized
- easy to extend
- easy to maintain

Adding a new tool should require only one search registration.

---

# Engineering Transparency

Users should understand:

- assumptions
- units
- formulas
- limitations

Engineering software should never hide important information.

When appropriate, explain how results are calculated.

---

# User Interface Philosophy

The interface exists to support engineering—not entertainment.

Prefer:

- clarity
- speed
- readability
- consistency

Avoid unnecessary animations, distractions, or decorative elements.

The software should disappear behind the engineering task.

---

# Documentation Is Part of the Product

If a feature cannot be understood six months later, it is incomplete.

Architecture changes should be documented.

Important engineering assumptions should be documented.

Future developers—including AI—should understand why decisions were made.

---

# AI Is an Engineering Partner

AI exists to accelerate engineering work.

AI should never invent engineering facts.

AI should:

- inspect before changing
- explain before rewriting
- document before finishing

When uncertain, AI should ask questions instead of making assumptions.

---

# Technical Debt

Technical debt is acceptable only when it enables measurable progress and there is a clear plan to resolve it.

Avoid accumulating unnecessary debt.

Leave the project better than you found it.

---

# Performance

Optimize for:

1. Correctness
2. Maintainability
3. Simplicity
4. Performance

Premature optimization should be avoided.

---

# Future-Proofing

Design systems that can grow.

Do not design systems that are more complicated than today's requirements.

Favor modular expansion over speculative architecture.

---

# Definition of Success

Success is not measured by:

- lines of code
- number of features
- complexity

Success is measured by:

- time saved
- engineering confidence
- reduced mistakes
- faster design reviews
- easier manufacturing decisions
- easier testing
- happier engineers

---

# The Product Owner

The Product Owner defines:

- vision
- priorities
- engineering requirements
- acceptance criteria

AI assists in implementation but does not replace engineering judgment.

---

# The Standard

Every pull request should leave the project:

- simpler
- cleaner
- easier to understand
- easier to extend
- easier to maintain

---

# Final Principle

Never lose sight of the mission.

> **Let engineers engineer faster—from one tool.**. 

The goal is not simply to make UWE function.

The goal is to make UWE easy to engineer for the next ten years.

Favor:

• Small focused changes
• Backwards compatibility
• Single sources of truth
• Metadata over duplicated logic
• Extensible architecture
• Incremental refactoring
