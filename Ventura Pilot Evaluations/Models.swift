import SwiftUI

enum Grade: String, Codable, CaseIterable {
    case notProficient = "1"
    case gainingProficiency = "2"
    case proficient = "3"
    case notApplicable = "NA"
    case notEvaluated = "NE"

    var displayName: String {
        switch self {
        case .notProficient: return "1 - Not Proficient"
        case .gainingProficiency: return "2 - Gaining Proficiency"
        case .proficient: return "3 - Proficient"
        case .notApplicable: return "NA - Not Applicable"
        case .notEvaluated: return "NE - Not Evaluated"
        }
    }

    var shortName: String { rawValue }

    var isUnsatisfactory: Bool {
        self == .notProficient || self == .gainingProficiency
    }

    var color: Color {
        switch self {
        case .notProficient: return .red
        case .gainingProficiency: return .orange
        case .proficient: return .green
        case .notApplicable, .notEvaluated: return .gray
        }
    }
}

enum AircraftType: String, Codable, CaseIterable {
    case citation = "Citation"
    case challenger = "Challenger"
}

enum EvaluationType: String, Codable, CaseIterable {
    case ioe = "IOE"
    case picUpgrade = "PIC Upgrade"
    case random = "Random"
}

enum Position: String, Codable, CaseIterable {
    case pic = "PIC"
    case sic = "SIC"
}

struct PilotInfo: Codable {
    var lastName: String = ""
    var firstName: String = ""
    var middleInitial: String = ""
    var position: Position = .pic
    var aircraftType: AircraftType = .citation
    var nNumbers: String = ""

    var fullName: String {
        let mi = middleInitial.isEmpty ? "" : " \(middleInitial)."
        return "\(firstName)\(mi) \(lastName)"
    }
}

struct GradeEntry: Codable, Identifiable {
    var id = UUID()
    var grade: Grade
    var date: Date
    var session: Int
}

struct EvaluationItem: Codable, Identifiable {
    var id: String
    var name: String
    var gradeHistory: [GradeEntry] = []
    var comment: String = ""

    var currentGrade: Grade? {
        gradeHistory.last?.grade
    }

    var isUnsatisfactory: Bool {
        guard let grade = currentGrade else { return false }
        return grade.isUnsatisfactory
    }

    var isGraded: Bool {
        currentGrade != nil
    }
}

struct EvaluationSection: Codable, Identifiable {
    var id: Int
    var title: String
    var items: [EvaluationItem]
}

struct FlightLogEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date = Date()
    var departure: String = ""
    var arrival: String = ""
    var blockTime: String = ""
    var tailNumber: String = ""
    var pf: String = ""
    var pm: String = ""
    var avionics: String = ""
    var dayLandings: Int = 0
    var nightLandings: Int = 0

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        departure = try container.decodeIfPresent(String.self, forKey: .departure) ?? ""
        arrival = try container.decodeIfPresent(String.self, forKey: .arrival) ?? ""
        blockTime = try container.decodeIfPresent(String.self, forKey: .blockTime) ?? ""
        tailNumber = try container.decodeIfPresent(String.self, forKey: .tailNumber) ?? ""
        pf = try container.decodeIfPresent(String.self, forKey: .pf) ?? ""
        pm = try container.decodeIfPresent(String.self, forKey: .pm) ?? ""
        avionics = try container.decodeIfPresent(String.self, forKey: .avionics) ?? ""
        dayLandings = try container.decodeIfPresent(Int.self, forKey: .dayLandings) ?? 0
        nightLandings = try container.decodeIfPresent(Int.self, forKey: .nightLandings) ?? 0
    }
}

struct Evaluation: Codable, Identifiable {
    var id = UUID()
    var pilotInfo: PilotInfo = PilotInfo()
    var evaluationType: EvaluationType = .ioe
    var evaluatorName: String = ""
    var certifyingPilotName: String = ""
    var createdDate: Date = Date()
    var sections: [EvaluationSection] = []
    var flightLogs: [FlightLogEntry] = []
    var generalComments: String = ""
    var pilotSignature: Data?
    var pilotSignatureDate: Date?
    var evaluatorSignature: Data?
    var evaluatorSignatureDate: Date?
    var currentSession: Int = 1
    var isComplete: Bool = false

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pilotInfo = try container.decode(PilotInfo.self, forKey: .pilotInfo)
        evaluationType = try container.decode(EvaluationType.self, forKey: .evaluationType)
        evaluatorName = try container.decode(String.self, forKey: .evaluatorName)
        certifyingPilotName = try container.decodeIfPresent(String.self, forKey: .certifyingPilotName) ?? ""
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        sections = try container.decode([EvaluationSection].self, forKey: .sections)
        flightLogs = try container.decodeIfPresent([FlightLogEntry].self, forKey: .flightLogs) ?? []
        generalComments = try container.decodeIfPresent(String.self, forKey: .generalComments) ?? ""
        pilotSignature = try container.decodeIfPresent(Data.self, forKey: .pilotSignature)
        pilotSignatureDate = try container.decodeIfPresent(Date.self, forKey: .pilotSignatureDate)
        evaluatorSignature = try container.decodeIfPresent(Data.self, forKey: .evaluatorSignature)
        evaluatorSignatureDate = try container.decodeIfPresent(Date.self, forKey: .evaluatorSignatureDate)
        currentSession = try container.decodeIfPresent(Int.self, forKey: .currentSession) ?? 1
        isComplete = try container.decodeIfPresent(Bool.self, forKey: .isComplete) ?? false
    }

    var hasUnsatisfactoryItems: Bool {
        sections.flatMap(\.items).contains { $0.isUnsatisfactory }
    }

    var allItemsGraded: Bool {
        sections.flatMap(\.items).allSatisfy { $0.isGraded }
    }

    var unsatisfactorySections: [EvaluationSection] {
        sections.compactMap { section in
            let items = section.items.filter { $0.isUnsatisfactory }
            guard !items.isEmpty else { return nil }
            return EvaluationSection(id: section.id, title: section.title, items: items)
        }
    }

    var totalItems: Int {
        sections.flatMap(\.items).count
    }

    var gradedItems: Int {
        sections.flatMap(\.items).filter(\.isGraded).count
    }

    var unsatisfactoryCount: Int {
        sections.flatMap(\.items).filter(\.isUnsatisfactory).count
    }

    var hasComments: Bool {
        sections.flatMap(\.items).contains { !$0.comment.isEmpty }
    }
}
