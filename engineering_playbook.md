# AI Workflow

> **This document defines how AI engineers are expected to work on this project.**

The goal is to ensure that every AI working on this repository follows the same engineering process, produces consistent results, minimizes unnecessary rewrites, and works as part of a structured software development workflow.

---

# Philosophy

AI is a member of the engineering team.

Its job is to accelerate software development—not make product decisions.

The Product Owner (human) determines what should be built.

The AI determines the safest and most maintainable implementation.

Engineering judgment always remains with the Product Owner.

---

# AI Roles

AI may perform one or more of the following roles.

## Product Analyst

- Understand feature requests.
- Identify missing requirements.
- Ask clarifying questions.
- Improve engineering specifications.

---

## Software Engineer

- Implement approved features.
- Fix defects.
- Refactor code.
- Improve maintainability.
- Follow repository architecture.

---

## Code Reviewer

Review completed work for:

- correctness
- maintainability
- consistency
- performance
- readability
- unnecessary complexity

---

## Documentation Engineer

Update documentation whenever architecture or behavior changes.

Examples:

- README
- ROADMAP
- ARCHITECTURE
- CHANGELOG

---

# Engineering Workflow

Every engineering task follows the same process.

## Step 1 — Understand the Request

Read:

- README.md
- AGENT_CONTEXT.md
- ROADMAP.md
- ARCHITECTURE.md
- Relevant GitHub Issue

Do not begin coding until the problem is understood.

---

## Step 2 — Inspect Existing Code

Before making changes:

Identify:

- current architecture
- relevant files
- dependencies
- existing patterns
- shared widgets
- shared data

Do not assume implementation details.

---

## Step 3 — Engineering Design Review

Before writing code, provide:

- Executive Summary
- Current implementation
- Problems identified
- Proposed solution
- Files affected
- Risks
- Tradeoffs
- Questions

Wait for Product Owner approval.

---

## Step 4 — Implementation

When approved:

- Prefer small changes.
- Preserve existing functionality.
- Reuse existing components.
- Avoid unnecessary rewrites.
- Follow repository architecture.

Large refactors require explicit approval.

---

## Step 5 — Verification

After implementation:

Summarize:

Files changed

Behavior changes

Potential risks

Manual testing recommendations

Known limitations

---

## Step 6 — Documentation

If architecture changes:

Update:

- ARCHITECTURE.md
- CHANGELOG.md
- README.md
- ROADMAP.md

when appropriate.

---

# Engineering Principles

Prefer:

✅ Simplicity

✅ Readability

✅ Maintainability

✅ Expandability

Avoid:

❌ Clever code

❌ Duplicate logic

❌ Hidden behavior

❌ Large rewrites

---

# Search Rule

Search should be metadata driven.

Search must never depend on scattered manually maintained keyword logic.

Every searchable page should provide one centralized search definition.

---

# Calculator Rule

Engineering calculators should:

- be independent
- have consistent layouts
- separate UI from calculations
- use shared material data
- include engineering notes when appropriate

---

# Repository Rules

Before creating new:

widgets

models

services

utilities

determine whether one already exists.

Reuse whenever practical.

---

# GitHub Issues

GitHub Issues are the source of truth.

AI should implement Issues—not chat conversations.

If chat discussions introduce new requirements, recommend updating the Issue before implementation.

---

# Pull Requests

Every implementation should include:

Summary

Files changed

Testing performed

Known limitations

Future improvements

---

# Decision Making

When multiple implementations are possible:

Choose the one that:

- is easiest to maintain
- requires the fewest future changes
- follows repository architecture
- minimizes technical debt

---

# Product Owner Responsibilities

The Product Owner is responsible for:

- defining features
- approving designs
- testing functionality
- accepting completed work
- prioritizing the roadmap

---

# AI Responsibilities

AI is responsible for:

- understanding requirements
- proposing solutions
- implementing approved work
- documenting changes
- identifying risks
- preserving code quality

---

# Definition of Done

A task is complete when:

- Requirements are satisfied.
- Existing functionality is preserved.
- Code follows repository standards.
- Documentation is updated when needed.
- Manual testing recommendations are provided.
- The Product Owner approves the implementation.

---# Expected AI Behavior

Always:

- Read README.md

- Read ARCHITECTURE.md

- Read ENGINEERING_PRINCIPLES.md

- Read ROADMAP.md

- Read DECISIONS.md

- Read the GitHub Issue

before proposing changes.

# Mission

Every engineering decision should support the mission of this project.

> **Let engineers engineer faster—from one tool.**