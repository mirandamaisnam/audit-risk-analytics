# Control Testing

SQL scripts implementing Phase 3 control-exception tests against the
synthetic transaction dataset. Every test here flags a **potential exception
requiring investigation** — none of these confirm fraud on their own.

Planned tests:
- Duplicate invoice / payment detection
- Duplicate vendor-payment combinations
- High-value transaction flags
- Approval-threshold violations
- Segregation-of-duties conflicts
- Period-end / weekend / after-hours transaction activity
- Round-number transaction flags
- Vendor concentration analysis

Files to be added once the synthetic dataset design (Phase 3) is finalized.

