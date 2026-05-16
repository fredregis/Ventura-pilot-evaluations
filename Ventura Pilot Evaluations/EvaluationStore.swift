import Foundation
import Observation

@Observable
class EvaluationStore {
    var evaluations: [Evaluation] = []

    init() {
        load()
    }

    func createEvaluation(pilotInfo: PilotInfo, evaluationType: EvaluationType, evaluatorName: String) -> Evaluation {
        var evaluation = Evaluation()
        evaluation.pilotInfo = pilotInfo
        evaluation.evaluationType = evaluationType
        evaluation.evaluatorName = evaluatorName
        evaluation.sections = EvaluationData.createSections()
        evaluations.insert(evaluation, at: 0)
        save()
        return evaluation
    }

    func updateEvaluation(_ evaluation: Evaluation) {
        if let index = evaluations.firstIndex(where: { $0.id == evaluation.id }) {
            evaluations[index] = evaluation
            save()
        }
    }

    func deleteEvaluation(_ evaluation: Evaluation) {
        evaluations.removeAll { $0.id == evaluation.id }
        save()
    }

    func evaluation(for id: UUID) -> Evaluation? {
        evaluations.first { $0.id == id }
    }

    // MARK: - Export / Import

    func exportEvaluation(_ evaluation: Evaluation) -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(evaluation) else { return nil }
        let name = evaluation.pilotInfo.lastName.replacingOccurrences(of: " ", with: "_")
        let fileName = "Evaluation_\(name)_\(evaluation.id.uuidString.prefix(8)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: url)
        return url
    }

    func parseEvaluation(from url: URL) -> Evaluation? {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url),
              var evaluation = try? JSONDecoder().decode(Evaluation.self, from: data) else {
            return nil
        }
        if evaluations.contains(where: { $0.id == evaluation.id }) {
            evaluation.id = UUID()
        }
        return evaluation
    }

    func addImportedEvaluation(_ evaluation: Evaluation) {
        evaluations.insert(evaluation, at: 0)
        save()
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("evaluations.json")
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(evaluations)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        evaluations = (try? JSONDecoder().decode([Evaluation].self, from: data)) ?? []
    }
}
