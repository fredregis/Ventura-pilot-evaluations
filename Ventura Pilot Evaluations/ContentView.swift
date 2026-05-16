import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(EvaluationStore.self) private var store
    @State private var showingNewEvaluation = false
    @State private var showingFileImporter = false
    @State private var importAlert: ImportAlert?
    @State private var pendingImport: Evaluation?
    @State private var showingAddEvaluatorPrompt = false
    @State private var showingEvaluatorNameInput = false
    @State private var newEvaluatorName = ""
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if store.evaluations.isEmpty {
                    ContentUnavailableView(
                        "No Evaluations",
                        systemImage: "airplane",
                        description: Text("Tap + to create a new pilot evaluation.")
                    )
                } else {
                    List {
                        if !inProgressEvaluations.isEmpty {
                            Section("In Progress") {
                                ForEach(inProgressEvaluations) { evaluation in
                                    NavigationLink(value: evaluation.id) {
                                        EvaluationRowView(evaluation: evaluation)
                                    }
                                }
                                .onDelete { offsets in
                                    deleteEvaluations(from: inProgressEvaluations, at: offsets)
                                }
                            }
                        }
                        if !completedEvaluations.isEmpty {
                            Section("Completed") {
                                ForEach(completedEvaluations) { evaluation in
                                    NavigationLink(value: evaluation.id) {
                                        EvaluationRowView(evaluation: evaluation)
                                    }
                                }
                                .onDelete { offsets in
                                    deleteEvaluations(from: completedEvaluations, at: offsets)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pilot Evaluations")
            .navigationDestination(for: UUID.self) { id in
                EvaluationDetailView(evaluationId: id)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingNewEvaluation = true
                        } label: {
                            Label("New Evaluation", systemImage: "plus")
                        }
                        Button {
                            showingFileImporter = true
                        } label: {
                            Label("Import Evaluation", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingNewEvaluation) {
                NewEvaluationView()
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first, let evaluation = store.parseEvaluation(from: url) {
                        pendingImport = evaluation
                        showingAddEvaluatorPrompt = true
                    } else {
                        importAlert = ImportAlert(title: "Import Failed", message: "Could not read the evaluation file.")
                    }
                case .failure:
                    importAlert = ImportAlert(title: "Import Failed", message: "Could not open the file.")
                }
            }
            .alert("Add Evaluator?", isPresented: $showingAddEvaluatorPrompt) {
                Button("Yes") {
                    newEvaluatorName = ""
                    showingEvaluatorNameInput = true
                }
                Button("No") {
                    if let evaluation = pendingImport {
                        store.addImportedEvaluation(evaluation)
                        pendingImport = nil
                        importAlert = ImportAlert(title: "Import Successful", message: "The evaluation has been imported.")
                    }
                }
            } message: {
                if let evaluation = pendingImport {
                    Text("Importing evaluation for \(evaluation.pilotInfo.fullName).\nCurrent evaluator: \(evaluation.evaluatorName.isEmpty ? "None" : evaluation.evaluatorName)\n\nWould you like to add an evaluator?")
                }
            }
            .alert("Evaluator Name", isPresented: $showingEvaluatorNameInput) {
                TextField("Name", text: $newEvaluatorName)
                Button("Add") {
                    if var evaluation = pendingImport, !newEvaluatorName.isEmpty {
                        if evaluation.evaluatorName.isEmpty {
                            evaluation.evaluatorName = newEvaluatorName
                        } else {
                            evaluation.evaluatorName += ", \(newEvaluatorName)"
                        }
                        store.addImportedEvaluation(evaluation)
                        pendingImport = nil
                        importAlert = ImportAlert(title: "Import Successful", message: "The evaluation has been imported with evaluator \(newEvaluatorName) added.")
                    }
                }
                Button("Cancel", role: .cancel) {
                    if let evaluation = pendingImport {
                        store.addImportedEvaluation(evaluation)
                        pendingImport = nil
                        importAlert = ImportAlert(title: "Import Successful", message: "The evaluation has been imported.")
                    }
                }
            } message: {
                Text("Enter the evaluator's name to add to this evaluation.")
            }
            .alert(item: $importAlert) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            }
        }
    }

    private var inProgressEvaluations: [Evaluation] {
        store.evaluations.filter { !$0.isComplete }
    }

    private var completedEvaluations: [Evaluation] {
        store.evaluations.filter { $0.isComplete }
    }

    private func deleteEvaluations(from list: [Evaluation], at offsets: IndexSet) {
        for index in offsets {
            store.deleteEvaluation(list[index])
        }
    }
}

struct ImportAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - Evaluation Row

struct EvaluationRowView: View {
    let evaluation: Evaluation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(evaluation.pilotInfo.fullName)
                    .font(.headline)
                Spacer()
                StatusBadge(evaluation: evaluation)
            }
            HStack {
                Text(evaluation.evaluationType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.purple.opacity(0.1))
                    .clipShape(Capsule())
                Text(evaluation.pilotInfo.position.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
                Text(evaluation.pilotInfo.aircraftType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(evaluation.createdDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(evaluation.gradedItems), total: Double(evaluation.totalItems))
                .tint(evaluation.hasUnsatisfactoryItems ? .orange : .green)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let evaluation: Evaluation

    var body: some View {
        Text(statusText)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var statusText: String {
        if evaluation.isComplete { return "Complete" }
        if evaluation.currentSession > 1 { return "Session \(evaluation.currentSession)" }
        if evaluation.gradedItems > 0 { return "In Progress" }
        return "New"
    }

    private var statusColor: Color {
        if evaluation.isComplete { return .green }
        if evaluation.hasUnsatisfactoryItems { return .orange }
        if evaluation.gradedItems > 0 { return .blue }
        return .gray
    }
}
