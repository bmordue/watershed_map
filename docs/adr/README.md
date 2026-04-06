# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) for the Watershed Mapping project.

## What is an ADR?

An Architecture Decision Record (ADR) is a document that captures an important architectural decision made along with its context and consequences.

## Why do we use ADRs?

* **Document key decisions**: Capture the reasoning behind important architectural choices
* **Onboard new team members**: Help newcomers understand why things are the way they are
* **Avoid revisiting settled decisions**: Prevent endless debates on already-decided topics
* **Learn from the past**: Review what worked and what didn't for future decisions
* **Accountability**: Clear record of who decided what and when

## ADR Index

### Active ADRs

* [ADR-0001](0001-use-yaml-for-configuration.md): Use YAML for Configuration Management
* [ADR-0002](0002-choose-grass-gis-for-watershed-analysis.md): Choose GRASS GIS for Watershed Analysis  
* [ADR-0003](0003-use-nix-for-environment-management.md): Use Nix for Environment Management

### Superseded ADRs

_None yet_

### Deprecated ADRs

_None yet_

## Creating a New ADR

1. **Copy the template**:
   ```bash
   cp docs/adr/template.md docs/adr/XXXX-short-title.md
   ```

2. **Use the next available number**:
   - Look at existing ADRs to find the next sequential number
   - Use 4 digits with leading zeros (e.g., 0004, 0005, etc.)

3. **Fill in the template**:
   - **Context**: Describe the problem and constraints
   - **Decision Drivers**: List factors influencing the decision
   - **Options**: Present alternatives considered
   - **Decision**: State what was chosen and why
   - **Consequences**: Both positive and negative outcomes

4. **Set the status**:
   - **Proposed**: Decision is being evaluated
   - **Accepted**: Decision has been made and is active
   - **Deprecated**: Decision is no longer relevant
   - **Superseded**: Replaced by a newer ADR

5. **Get review**:
   - Create a pull request
   - Tag relevant stakeholders for review
   - Discuss in PR comments before merging

6. **Update this index**:
   - Add your ADR to the appropriate section above

## ADR Status Lifecycle

```
┌──────────┐
│ Proposed │
└────┬─────┘
     │
     ├─────> Accepted ────┬─────> Deprecated
     │                    │
     └─────> Rejected     └─────> Superseded
```

## Best Practices

### When to Write an ADR

Write an ADR for decisions that:
* Affect the project structure or architecture
* Are difficult to reverse later
* Will impact how contributors work
* May need justification in the future
* Are not obvious to newcomers

### What NOT to document in ADRs

Don't write ADRs for:
* Implementation details of features
* Bug fixes or minor refactorings
* Decisions easily reversible
* Personal coding preferences
* Routine dependency updates

### Writing Good ADRs

* **Be concise**: Focus on the decision, not implementation details
* **Be specific**: Avoid vague language; state clear reasons
* **Consider alternatives**: Show what options were evaluated
* **Acknowledge tradeoffs**: Every decision has pros and cons
* **Link to resources**: Reference related documentation
* **Update status**: Keep ADRs current as decisions evolve

## Template Sections Explained

### Context and Problem Statement
- What problem are we trying to solve?
- What constraints or requirements exist?
- Why is this decision necessary now?

### Decision Drivers
- What factors influenced the decision?
- What are the key requirements or goals?
- What constraints must be satisfied?

### Considered Options
- What alternatives did we evaluate?
- Briefly describe each option
- List at least 2-3 alternatives

### Decision Outcome
- What option did we choose?
- Why did we choose it?
- What are the expected positive consequences?
- What are the expected negative consequences?

### Pros and Cons of Options
- Detailed analysis of each alternative
- Fair assessment of strengths and weaknesses
- Helps show the decision was well-considered

### Links and References
- Related documentation
- External resources
- Related ADRs
- Implementation PRs

## Modifying Existing ADRs

### Superseding an ADR

When a decision is reversed or replaced:

1. Create a new ADR documenting the new decision
2. Update the old ADR:
   - Change status to "Superseded"
   - Add "Superseded by" link to new ADR
3. Add "Supersedes" link in new ADR
4. Update the index in this README

### Deprecating an ADR

When a decision becomes irrelevant:

1. Update the ADR status to "Deprecated"
2. Add a note explaining why it's deprecated
3. Move to "Deprecated ADRs" section in index

## Resources

* [Architecture Decision Records - GitHub](https://adr.github.io/)
* [ADR Template by Michael Nygard](https://github.com/joelparkerhenderson/architecture-decision-record)
* [When to Use ADRs](https://github.com/joelparkerhenderson/architecture-decision-record#when-to-use-adrs)
* [ADR Tools](https://github.com/npryce/adr-tools)

## Questions?

If you have questions about ADRs or need help writing one, please:
* Open an issue with the "documentation" label
* Ask in pull request discussions
* Reach out to maintainers

---

**Last Updated**: February 2026  
**Maintained by**: Development Team
