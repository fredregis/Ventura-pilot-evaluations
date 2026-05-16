# Ventura Pilot Evaluations - User Manual

## Overview

Ventura Pilot Evaluations is an iOS application developed for Ventura Air Services to evaluate pilots during their Initial Operating Experience (IOE), PIC Upgrades, and Random evaluations. The app replaces the paper-based VAS Pilot Evaluation Worksheet, allowing evaluators to grade pilots across 12 sections covering all phases of flight operations.

---

## Getting Started

When the app launches, you will see the Ventura Air Services splash screen followed by the main **Pilot Evaluations** screen.

### Main Screen

The main screen displays all evaluations organized into two sections:

- **In Progress** - Evaluations that are currently being worked on
- **Completed** - Evaluations that have been finalized

Each evaluation row shows:
- Pilot name
- Status badge (New, In Progress, Session #, or Complete)
- Evaluation type (IOE, PIC Upgrade, or Random)
- Position (PIC or SIC)
- Aircraft type
- Date created
- Progress bar (orange if unsatisfactory items exist, green otherwise)

### Navigation

- **Gear icon** (top left) - Opens Settings
- **Plus icon** (top right) - Opens a menu to create a new evaluation or import one
- **Swipe left** on any evaluation to delete it

---

## Creating a New Evaluation

1. Tap the **+** icon and select **New Evaluation**
2. Fill in the form:
   - **Evaluation Type** - Select IOE, PIC Upgrade, or Random
   - **Evaluator** - Enter the evaluator's name
   - **Pilot Information** - Enter the pilot's last name, first name, and middle initial
   - **Position** - Select PIC or SIC
   - **Aircraft** - Select Citation or Challenger, and optionally enter N Number(s)
3. Tap **Create** to save

The pilot's last name and first name are required. The new evaluation will appear at the top of the In Progress list.

---

## Evaluation Detail Screen

Tap on any evaluation to open its detail screen. This screen is the hub for all evaluation activities and displays the following sections:

### Action Buttons (In Progress evaluations only)

- **Start Grading / Continue Grading** - Opens the grading form to evaluate all items
- **Flight Log** - Opens the flight log to record flights (shows count of logged flights)
- **Review Unsatisfactory Items** - Appears after all items are graded if any items received a grade of 1 or 2. This starts a new session and shows only unsatisfactory items for re-evaluation
- **Complete Evaluation** - Appears after all items are graded. Prompts for the certifying pilot's name to finalize the evaluation

### Pilot Information

Displays all pilot and evaluation details including evaluation type, evaluator name, pilot name, position, aircraft type, N numbers, date created, and current session number.

### Progress

Shows a progress bar and grade breakdown:
- **Proficient** (green) - Items graded 3
- **Unsat.** (orange) - Items graded 1 or 2
- **N/A** (gray) - Items marked Not Applicable
- **Not Eval'd** (gray) - Items marked Not Evaluated

### Comments

Displays all items that have comments, showing the element code, grade, item name, and comment text.

### Generate PDF Report

Available when all items are graded or the evaluation is complete. Generates a 3-page PDF report.

### Export Evaluation

Exports the evaluation as a JSON file for sharing with other devices via AirDrop, Messages, email, or other sharing methods.

---

## Grading Items

The grading screen displays all 12 evaluation sections with their items. 

### Evaluation Sections (63 items total)

| # | Section | Items |
|---|---------|-------|
| 1 | Preflight | Crew Briefing, Flight Planning, Weather/NOTAMs/TFR, Exterior Inspection, Cockpit Preflight, W&B/Performance, Fuel Loading & Procedures, Aircraft Appearance, Customer Care |
| 2 | Before Takeoff | Takeoff Briefing, NAV/FMS Setup, Flight Director Setup, Engine Start, Taxi |
| 3 | Takeoff / Climb | Runway Alignment, Thrust Setting, Speed Control, Crosswind Control, Rotation, Use of Automation |
| 4 | Cruise | Use of Automation, Flight Management, Fuel Awareness, Customer Care |
| 5 | Descent | Descent Planning, Descent Management, Use of Automation, Approach Briefing, Approach Setup, Customer Care |
| 6 | Approach / Landing | Approach Profile, Stabilized Approach, Use of Automation, Speed Control, Flap/Gear Management, Crosswind Control, Touchdown Point, Brakes/Reverse Thrust, Directional Control, Taxi/Parking |
| 7 | Shutdown / Deplane | Engine Shutdown, Passenger Deplane, Customer Care |
| 8 | Post Flight | Company Communication, Aircraft Appearance, Exterior Inspection |
| 9 | Securing | Aircraft Chocked, Gust/Control Lock, Battery Disconnected, Damage Avoidance |
| 10 | General | Judgement, CRM, Uniform/Appearance, Timeliness, Required Documents |
| 11 | Procedures | High Altitude Airports, Mountainous Airports, Cold Weather Ops, International Procedures, Thunderstorms/Wx Radar |
| 12 | Company | Crew Rules & Standards, Ops Specs, SOP's, Safety Reporting, Communications |

### Grading Scale

- **1** - Not Proficient (red)
- **2** - Gaining Proficiency (orange)
- **3** - Proficient (green)
- **NA** - Not Applicable (gray)
- **NE** - Not Evaluated (gray)

### How to Grade

1. Sections are expanded by default. Tap any section header to collapse or expand it.
2. Use the **collapse/expand** button (top left) to toggle all sections at once.
3. For each item, tap the grade button (1, 2, 3, NA, or NE) to assign a grade.
4. Tap the same grade again to remove it.
5. Items graded **1 or 2** (unsatisfactory) will automatically show a comment field. Comments are required for unsatisfactory items.
6. Tap **Save** to save and return, or simply navigate back (changes are auto-saved).

### Multi-Session Evaluations

Evaluations can span multiple days and sessions:

1. Grade items over the course of your evaluation period
2. After all items are graded, if any items are unsatisfactory (graded 1 or 2), the **Review Unsatisfactory Items** button appears
3. Tapping it starts a new session and presents only the unsatisfactory items for re-evaluation
4. This process can repeat across multiple sessions until all items are satisfactory
5. The session number is tracked and displayed in the evaluation detail

---

## Flight Log

The flight log allows you to record flights associated with the evaluation.

### Adding Flights

1. From the evaluation detail screen, tap **Flight Log**
2. Tap **Add Flight** to add a new entry
3. For each flight, enter:
   - **Date** - Select the flight date
   - **Departure** - Enter the departure airport (ICAO code)
   - **Arrival** - Enter the arrival airport (ICAO code)
   - **Block Time** - Enter the block time in decimal hours (e.g., 2.5)
4. The **Total Block Time** is displayed at the bottom, summing all entries
5. Flights are automatically sorted from newest to oldest
6. Swipe left on any flight entry to delete it
7. Tap **Save** to save and return

---

## Completing an Evaluation

Once all items have been graded:

1. Review any unsatisfactory items if needed (see Multi-Session Evaluations above)
2. Tap **Complete Evaluation**
3. Enter the **certifying pilot's name** when prompted
4. Tap **Complete** to finalize

Once completed, the evaluation moves to the **Completed** section on the main screen and can no longer be edited. You can still generate PDF reports and export the evaluation.

---

## PDF Report

The PDF report is a 3-page document that mirrors the original VAS Pilot Evaluation Worksheet.

### Page 1 - Evaluation Grid
- Ventura Air Services logo and company name
- Pilot information (name, position, evaluation type, aircraft, N numbers, evaluator)
- Grading legend
- 3-column grid showing all 12 sections with item grades (color-coded)

### Page 2 - Comments
- Element codes, grades, and comments for all items with comments
- Signature area for pilot and certifying pilot

### Page 3 - Flight Log
- Pilot name, aircraft type, and total block time
- Table of all logged flights (date, departure, arrival, block time)

### Generating and Sharing

1. Tap **Generate PDF Report** from the evaluation detail screen
2. Preview the PDF in the app
3. Tap the **share icon** (top right) to share via AirDrop, email, print, save to Files, etc.

---

## Export and Import

Evaluations can be transferred between devices using JSON export/import.

### Exporting

1. Open the evaluation detail screen
2. Tap **Export Evaluation**
3. Choose a sharing method (AirDrop, Messages, email, save to Files, etc.)

### Importing

1. From the main screen, tap the **+** icon and select **Import Evaluation**
2. Browse for and select a previously exported JSON file
3. You will be asked **"Add Evaluator?"**:
   - **Yes** - Enter the evaluator's name. If the evaluation already has an evaluator, the new name will be appended (e.g., "John Smith, Jane Doe")
   - **No** - The evaluation is imported as-is
4. A confirmation message appears when the import is successful

If the imported evaluation has the same ID as an existing evaluation, a new ID is automatically assigned to avoid conflicts.

---

## Settings

Tap the **gear icon** on the main screen to access Settings. The settings page displays:

- **App Version** - The current version of the application
- **Build Number** - The current build number

---

## Tips

- **Multi-day evaluations**: You can close the app and return at any time. Your progress is automatically saved.
- **Cross-device workflow**: Export an evaluation from one device and import it on another to continue grading with a different evaluator.
- **Quick section navigation**: Use the collapse/expand all button in the grading screen to quickly find the section you need.
- **Grade changes**: Tap a grade to assign it, tap the same grade again to remove it. The full grade history is tracked across sessions.
- **Unsatisfactory items**: Always add comments for items graded 1 or 2 - these comments appear on the PDF report.
