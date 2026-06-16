# Shellby Onboarding Goal and Action Tables

Source reviewed:

- `lib/features/preparation/preparation_screens.dart`
- `lib/core/app_state.dart`

Notes:

- `Default Data = TRUE` means the field has an initialized default in `AppState` before the user edits it.
- `Default Data = FALSE` means the value is selected, entered, derived later, or implied by a future tracking flow.
- The app stores selected actions as action IDs only. Action names and descriptions below are reconstructed from the IDs' usage in onboarding.
- The current app intentionally uses four onboarding goal layers: `Cash Flow & Basic Needs`, `Financial Safety`, `Accumulating Wealth`, and `Financial Freedom`.

## ACTIONS

| Action ID | Action Name | Description |
|---|---|---|
| ACT1 | Set Up Financial Profile | Create the user account and baseline profile: identity, life context, money rhythm, financial defaults, assets, liabilities, consent, and stored onboarding profile. |
| ACT2 | Create & Manage Goals | Create savings, emergency, debt, milestone, or payoff targets with goal boundaries, target amounts, dates, and contribution rules. |
| ACT3 | Track Financial Activity | Track income, expenses, savings progress, assets/liabilities, debt payments, goal allocation, and contextual spending patterns. |
| ACT4 | Collaborate & Share Progress | Enable collaborative goals, shared progress, visibility, permissions, and partner/group contributions. |
| ACT5 | Receive AI Insights | Enable AI or rule-based insights, reminders, forecasts, health scores, shortfall alerts, risk flags, and recommendations. |
| ACT6 | Review & Adjust Plans | Adjust budgets, timelines, contribution rules, and plan assumptions when income, bills, or spending patterns change. |

## GOALS

| Goal ID | Pyramid Layer | Goal | Description |
|---|---|---|---|
| GOAL1 | Cash Flow & Basic Needs | Cash Flow Stability Plan | Map income, fixed costs, and spending patterns so the monthly budget has a clear baseline. |
| GOAL1A | Cash Flow & Basic Needs | Expense Tracking Routine | Set up a simple expense tracking routine with reminders matched to the check-in rhythm. |
| GOAL1B | Cash Flow & Basic Needs | Spending Trigger Tracker | Tag expense context like day, category, merchant, and payday timing so Shellby can spot repeat spending triggers. |
| GOAL1C | Cash Flow & Basic Needs | Irregular Income Buffer | Create a hill-and-valley budget that plans from lower-income months instead of a fixed average. |
| GOAL2 | Financial Safety | Emergency Cushion | Build a practical safety buffer sized around real bills and essential living costs. |
| GOAL2A | Financial Safety | Safety Shield Boundary | Ring-fence emergency savings and add alerts when regular spending starts pulling from it. |
| GOAL2B | Financial Safety | Bill Due-Date Buffer | Build a due-date buffer that reserves money before scheduled bills and flags shortfalls early. |
| GOAL2C | Financial Safety | Payday Safety Sweep | Set up a payday savings rule that builds the emergency cushion before money blends into spending. |
| GOAL3 | Accumulating Wealth | Net Worth Growth Plan | Balance debt reduction, regular saving, and starter investing into one trackable plan. |
| GOAL3A | Accumulating Wealth | Debt Payoff Map | Map a debt snowball or avalanche path so balances start moving in a visible direction. |
| GOAL3B | Accumulating Wealth | Starter Investing Habit | Complete a starter investing checklist and track a small recurring contribution habit. |
| GOAL3C | Accumulating Wealth | Lifestyle Creep Monitor | Monitor fixed expenses and spending creep when income changes so wealth gains do not disappear. |
| GOAL4 | Financial Freedom | Future Lifestyle Fund | Create milestone buckets for meaningful plans while protecting essential money and safety buffers. |
| GOAL4A | Financial Freedom | Milestone Bucket Plan | Separate big goals into trackable buckets with target amounts, dates, and monthly contributions. |
| GOAL4B | Financial Freedom | Shared Future Alignment | Prepare a collaborative goal with visibility, permissions, and shared progress tracking. |
| GOAL4C | Financial Freedom | Planned Experience Fund | Set aside a clear experience fund so hobby and travel spending is planned and separate from essentials. |

## GOAL-ACTIONS TABLE

| Goal | Action | Relationship |
|---|---|---|
| GOAL1 Cash Flow Stability Plan | ACT1 | Initial |
| GOAL1A Expense Tracking Routine | ACT1 | Initial |
| GOAL1A Expense Tracking Routine | ACT3 | Initial |
| GOAL1B Spending Trigger Tracker | ACT1 | Initial |
| GOAL1B Spending Trigger Tracker | ACT3 | Initial |
| GOAL1B Spending Trigger Tracker | ACT5 | Advance |
| GOAL1C Irregular Income Buffer | ACT1 | Initial |
| GOAL1C Irregular Income Buffer | ACT6 | Initial |
| GOAL2 Emergency Cushion | ACT1 | Initial |
| GOAL2A Safety Shield Boundary | ACT1 | Initial |
| GOAL2A Safety Shield Boundary | ACT2 | Initial |
| GOAL2B Bill Due-Date Buffer | ACT1 | Initial |
| GOAL2B Bill Due-Date Buffer | ACT5 | Initial |
| GOAL2C Payday Safety Sweep | ACT1 | Initial |
| GOAL2C Payday Safety Sweep | ACT2 | Initial |
| GOAL3 Net Worth Growth Plan | ACT1 | Initial |
| GOAL3A Debt Payoff Map | ACT1 | Initial |
| GOAL3A Debt Payoff Map | ACT2 | Initial |
| GOAL3B Starter Investing Habit | ACT1 | Initial |
| GOAL3B Starter Investing Habit | ACT5 | Initial |
| GOAL3C Lifestyle Creep Monitor | ACT1 | Initial |
| GOAL3C Lifestyle Creep Monitor | ACT6 | Initial |
| GOAL4 Future Lifestyle Fund | ACT1 | Initial |
| GOAL4A Milestone Bucket Plan | ACT1 | Initial |
| GOAL4A Milestone Bucket Plan | ACT2 | Initial |
| GOAL4B Shared Future Alignment | ACT1 | Initial |
| GOAL4B Shared Future Alignment | ACT4 | Initial |
| GOAL4C Planned Experience Fund | ACT1 | Initial |
| GOAL4C Planned Experience Fund | ACT5 | Initial |

## ACTION-DATA TABLE

| Action | Data Required | Default Data |
|---|---|---|
| ACT1 | User ID | FALSE |
| ACT1 | Name | FALSE |
| ACT1 | Email | FALSE |
| ACT1 | Profile Photo URL | FALSE |
| ACT1 | Age / Life Stage | FALSE |
| ACT1 | Occupation | FALSE |
| ACT1 | Industry | TRUE |
| ACT1 | Employment Status | TRUE |
| ACT1 | Income Type | TRUE |
| ACT1 | Income Rhythm | TRUE |
| ACT1 | Bills Rhythm | TRUE |
| ACT1 | Check-in Rhythm | TRUE |
| ACT1 | Location Type | TRUE |
| ACT1 | Financial Responsibility | TRUE |
| ACT1 | Monthly Income | TRUE |
| ACT1 | Fixed Expenses | TRUE |
| ACT1 | Variable Expenses | TRUE |
| ACT1 | Savings | TRUE |
| ACT1 | Emergency Months | TRUE |
| ACT1 | Debt Payments | TRUE |
| ACT1 | Investments | TRUE |
| ACT1 | Subscriptions | TRUE |
| ACT1 | Assets | TRUE |
| ACT1 | Liabilities | TRUE |
| ACT1 | Personal Data Consent | TRUE |
| ACT1 | Data Retention Consent | TRUE |
| ACT1 | App Permission Choices | FALSE |
| ACT2 | Selected Goal | TRUE |
| ACT2 | Selected Goal Description | TRUE |
| ACT2 | Selected Goal Monthly Target | TRUE |
| ACT2 | Goal Focus Summary | FALSE |
| ACT2 | Goal Timeframe Summary | FALSE |
| ACT2 | Goal Difficulty / Pace Summary | FALSE |
| ACT2 | Target Rule | FALSE |
| ACT2 | Goal Allocation Tracking Variable | FALSE |
| ACT2 | Savings Progress Tracking Variable | TRUE |
| ACT2 | Debt Repayment Target | FALSE |
| ACT2 | Milestone Bucket Target Amount | FALSE |
| ACT2 | Milestone Bucket Target Date | FALSE |
| ACT3 | Income Tracking Variable | TRUE |
| ACT3 | Expenses Tracking Variable | TRUE |
| ACT3 | Savings Progress Tracking Variable | TRUE |
| ACT3 | Assets and Liabilities Tracking Variable | TRUE |
| ACT3 | Debt Payments Tracking Variable | FALSE |
| ACT3 | Goal Allocation Tracking Variable | FALSE |
| ACT3 | Expense Transactions | FALSE |
| ACT3 | Income Transactions | FALSE |
| ACT3 | Spending Categories | FALSE |
| ACT3 | Merchant / Store Context | FALSE |
| ACT3 | Payday Timing Context | FALSE |
| ACT3 | Emotional Spending Logs | FALSE |
| ACT3 | Useful Reminder Situations | FALSE |
| ACT3 | Hurdles / Challenge Flags | FALSE |
| ACT4 | Social Structure | TRUE |
| ACT4 | Trusted Circle Consent | TRUE |
| ACT4 | Shared Goal Contributions | FALSE |
| ACT4 | Partner Contributions | FALSE |
| ACT4 | Group Savings Progress | FALSE |
| ACT4 | Permission Settings | FALSE |
| ACT4 | Visibility Settings | FALSE |
| ACT5 | AI Consent | TRUE |
| ACT5 | Financial Health Score | FALSE |
| ACT5 | Feasibility Score | FALSE |
| ACT5 | Financial Anxiety Score | TRUE |
| ACT5 | Decision Confidence Score | TRUE |
| ACT5 | Avoidance Score | TRUE |
| ACT5 | Peer Pressure Score | TRUE |
| ACT5 | Stress Indicators Enabled | TRUE |
| ACT5 | Emotional Logs Enabled | TRUE |
| ACT5 | Anonymous Benchmarking Consent | TRUE |
| ACT5 | Goal Completion Forecast | FALSE |
| ACT5 | Cash Flow Stability | FALSE |
| ACT5 | Bill Shortfall Alerts | FALSE |
| ACT5 | Spending Trigger Alerts | FALSE |
| ACT5 | Peer Percentile Benchmark | FALSE |
| ACT5 | Wealth Growth Simulation | FALSE |
| ACT6 | Plan Adjustment Action | FALSE |
| ACT6 | Budget Adjustments | FALSE |
| ACT6 | Timeline Adjustments | FALSE |
| ACT6 | Savings Adjustments | FALSE |
| ACT6 | Investment Adjustments | FALSE |
| ACT6 | Goal Progress History | FALSE |
| ACT6 | Goal Completion Status | FALSE |
| ACT6 | Irregular Income Flag | FALSE |
| ACT6 | Subscription Creep Flag | FALSE |
| ACT6 | Emergency Purchase Flag | FALSE |
| ACT6 | Family Obligations Flag | TRUE |
| ACT6 | Debt Due Dates Flag | TRUE |
