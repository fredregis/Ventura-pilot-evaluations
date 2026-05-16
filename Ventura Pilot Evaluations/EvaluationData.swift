import Foundation

enum EvaluationData {
    static func createSections() -> [EvaluationSection] {
        [
            EvaluationSection(id: 1, title: "Preflight", items: [
                EvaluationItem(id: "1a", name: "Crew Briefing"),
                EvaluationItem(id: "1b", name: "Flight Planning"),
                EvaluationItem(id: "1c", name: "Weather / NOTAMs / TFR"),
                EvaluationItem(id: "1d", name: "Exterior Inspection"),
                EvaluationItem(id: "1e", name: "Cockpit Preflight"),
                EvaluationItem(id: "1f", name: "W&B / Performance"),
                EvaluationItem(id: "1g", name: "Fuel Loading & Procedures"),
                EvaluationItem(id: "1h", name: "Aircraft Appearance"),
                EvaluationItem(id: "1i", name: "Customer Care"),
            ]),
            EvaluationSection(id: 2, title: "Before Takeoff", items: [
                EvaluationItem(id: "2a", name: "Takeoff Briefing"),
                EvaluationItem(id: "2b", name: "NAV / FMS Setup"),
                EvaluationItem(id: "2c", name: "Flight Director Setup"),
                EvaluationItem(id: "2d", name: "Engine Start"),
                EvaluationItem(id: "2e", name: "Taxi"),
            ]),
            EvaluationSection(id: 3, title: "Takeoff / Climb", items: [
                EvaluationItem(id: "3a", name: "Runway Alignment"),
                EvaluationItem(id: "3b", name: "Thrust Setting"),
                EvaluationItem(id: "3c", name: "Speed Control"),
                EvaluationItem(id: "3d", name: "Crosswind Control"),
                EvaluationItem(id: "3e", name: "Rotation"),
                EvaluationItem(id: "3f", name: "Use of Automation"),
            ]),
            EvaluationSection(id: 4, title: "Cruise", items: [
                EvaluationItem(id: "4a", name: "Use of Automation"),
                EvaluationItem(id: "4b", name: "Flight Management"),
                EvaluationItem(id: "4c", name: "Fuel Awareness"),
                EvaluationItem(id: "4d", name: "Customer Care"),
            ]),
            EvaluationSection(id: 5, title: "Descent", items: [
                EvaluationItem(id: "5a", name: "Descent Planning"),
                EvaluationItem(id: "5b", name: "Descent Management"),
                EvaluationItem(id: "5c", name: "Use of Automation"),
                EvaluationItem(id: "5d", name: "Approach Briefing"),
                EvaluationItem(id: "5e", name: "Approach Setup"),
                EvaluationItem(id: "5f", name: "Customer Care"),
            ]),
            EvaluationSection(id: 6, title: "Approach / Landing", items: [
                EvaluationItem(id: "6a", name: "Approach Profile"),
                EvaluationItem(id: "6b", name: "Stabilized Approach"),
                EvaluationItem(id: "6c", name: "Use of Automation"),
                EvaluationItem(id: "6d", name: "Speed Control"),
                EvaluationItem(id: "6e", name: "Flap / Gear Management"),
                EvaluationItem(id: "6f", name: "Crosswind Control"),
                EvaluationItem(id: "6g", name: "Touchdown Point"),
                EvaluationItem(id: "6h", name: "Brakes / Reverse Thrust"),
                EvaluationItem(id: "6i", name: "Directional Control"),
                EvaluationItem(id: "6j", name: "Taxi / Parking"),
            ]),
            EvaluationSection(id: 7, title: "Shutdown / Deplane", items: [
                EvaluationItem(id: "7a", name: "Engine Shutdown"),
                EvaluationItem(id: "7b", name: "Passenger Deplane"),
                EvaluationItem(id: "7c", name: "Customer Care"),
            ]),
            EvaluationSection(id: 8, title: "Post Flight", items: [
                EvaluationItem(id: "8a", name: "Company Communication"),
                EvaluationItem(id: "8b", name: "Aircraft Appearance"),
                EvaluationItem(id: "8c", name: "Exterior Inspection"),
            ]),
            EvaluationSection(id: 9, title: "Securing", items: [
                EvaluationItem(id: "9a", name: "Aircraft Chocked"),
                EvaluationItem(id: "9b", name: "Gust / Control Lock"),
                EvaluationItem(id: "9c", name: "Battery Disconnected"),
                EvaluationItem(id: "9d", name: "Damage Avoidance"),
            ]),
            EvaluationSection(id: 10, title: "General", items: [
                EvaluationItem(id: "10a", name: "Judgement"),
                EvaluationItem(id: "10b", name: "CRM"),
                EvaluationItem(id: "10c", name: "Uniform / Appearance"),
                EvaluationItem(id: "10d", name: "Timeliness"),
                EvaluationItem(id: "10e", name: "Required Documents"),
            ]),
            EvaluationSection(id: 11, title: "Procedures", items: [
                EvaluationItem(id: "11a", name: "High Altitude Airports"),
                EvaluationItem(id: "11b", name: "Mountainous Airports"),
                EvaluationItem(id: "11c", name: "Cold Weather Ops"),
                EvaluationItem(id: "11d", name: "International Procedures"),
                EvaluationItem(id: "11e", name: "Thunderstorms / Wx Radar"),
            ]),
            EvaluationSection(id: 12, title: "Company", items: [
                EvaluationItem(id: "12a", name: "Crew Rules & Standards"),
                EvaluationItem(id: "12b", name: "Ops Specs"),
                EvaluationItem(id: "12c", name: "SOP's"),
                EvaluationItem(id: "12d", name: "Safety Reporting"),
                EvaluationItem(id: "12e", name: "Communications"),
            ]),
        ]
    }
}
