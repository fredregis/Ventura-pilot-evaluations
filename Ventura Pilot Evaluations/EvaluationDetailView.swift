import SwiftUI

struct EvaluationDetailView: View {
    @Environment(EvaluationStore.self) private var store
    let evaluationId: UUID

    @State private var showingGrading = false
    @State private var showingUnsatisfactoryGrading = false
    @State private var showingFlightLog = false
    @State private var showingPDFPreview = false
    @State private var showingCompleteAlert = false
    @State private var showingPilotSignature = false
    @State private var showingEvaluatorSignature = false
    @State private var certifyingPilotName = ""

    private var evaluation: Evaluation? {
        store.evaluation(for: evaluationId)
    }

    var body: some View {
        Group {
            if let evaluation {
                evaluationContent(evaluation)
            } else {
                ContentUnavailableView("Evaluation Not Found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Evaluation")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func evaluationContent(_ evaluation: Evaluation) -> some View {
        List {
            if !evaluation.isComplete {
                continueGradingSection(evaluation)
            }

            pilotInfoSection(evaluation)
            progressSection(evaluation)

            generalCommentsSection(evaluation)

            if evaluation.hasComments {
                commentsSection(evaluation)
            }

            if evaluation.isComplete {
                signatureSection(evaluation)
            }

            if evaluation.isComplete || evaluation.allItemsGraded {
                pdfSection
            }

            exportSection(evaluation)
        }
        .navigationDestination(isPresented: $showingGrading) {
            GradingSessionView(evaluationId: evaluationId, showOnlyUnsatisfactory: false)
        }
        .navigationDestination(isPresented: $showingUnsatisfactoryGrading) {
            GradingSessionView(evaluationId: evaluationId, showOnlyUnsatisfactory: true)
        }
        .navigationDestination(isPresented: $showingFlightLog) {
            FlightLogView(evaluationId: evaluationId)
        }
        .sheet(isPresented: $showingPDFPreview) {
            if let eval = self.evaluation {
                PDFPreviewView(evaluation: eval)
            }
        }
        .sheet(isPresented: $showingPilotSignature) {
            SignatureView(title: "Pilot Signature") { data in
                guard var updated = self.evaluation else { return }
                updated.pilotSignature = data
                updated.pilotSignatureDate = Date()
                store.updateEvaluation(updated)
            }
        }
        .sheet(isPresented: $showingEvaluatorSignature) {
            SignatureView(title: "Evaluator Signature") { data in
                guard var updated = self.evaluation else { return }
                updated.evaluatorSignature = data
                updated.evaluatorSignatureDate = Date()
                store.updateEvaluation(updated)
            }
        }
    }

    private func pilotInfoSection(_ evaluation: Evaluation) -> some View {
        Section("Pilot Information") {
            LabeledContent("Evaluation Type", value: evaluation.evaluationType.rawValue)
            LabeledContent("Evaluator", value: evaluation.evaluatorName)
            LabeledContent("Name", value: evaluation.pilotInfo.fullName)
            LabeledContent("Position", value: evaluation.pilotInfo.position.rawValue)
            LabeledContent("Aircraft", value: evaluation.pilotInfo.aircraftType.rawValue)
            if !evaluation.pilotInfo.nNumbers.isEmpty {
                LabeledContent("N Number(s)", value: evaluation.pilotInfo.nNumbers)
            }
            LabeledContent("Date Created") {
                Text(evaluation.createdDate, style: .date)
            }
            LabeledContent("Session", value: "\(evaluation.currentSession)")
        }
    }

    private func progressSection(_ evaluation: Evaluation) -> some View {
        Section("Progress") {
            HStack {
                Label("\(evaluation.gradedItems)/\(evaluation.totalItems) Graded", systemImage: "checkmark.circle")
                Spacer()
                ProgressView(value: Double(evaluation.gradedItems), total: Double(evaluation.totalItems))
                    .frame(width: 100)
            }

            if evaluation.gradedItems > 0 {
                let allItems = evaluation.sections.flatMap(\.items)
                let proficient = allItems.filter { $0.currentGrade == .proficient }.count
                let unsat = evaluation.unsatisfactoryCount
                let na = allItems.filter { $0.currentGrade == .notApplicable }.count
                let ne = allItems.filter { $0.currentGrade == .notEvaluated }.count

                HStack {
                    GradeCountBadge(count: proficient, label: "Proficient", color: .green)
                    GradeCountBadge(count: unsat, label: "Unsat.", color: .orange)
                    GradeCountBadge(count: na, label: "N/A", color: .gray)
                    GradeCountBadge(count: ne, label: "Not Eval'd", color: .gray)
                }
            }
        }
    }

    @ViewBuilder
    private func continueGradingSection(_ evaluation: Evaluation) -> some View {
        Section {
            if !evaluation.allItemsGraded {
                Button {
                    showingGrading = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(evaluation.gradedItems == 0 ? "Start Grading" : "Continue Grading")
                                .font(.headline)
                            Text("\(evaluation.gradedItems)/\(evaluation.totalItems) items graded")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Button {
                showingFlightLog = true
            } label: {
                HStack {
                    Image(systemName: "airplane.departure")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text("Flight Log")
                            .font(.headline)
                        Text("\(evaluation.flightLogs.count) flight\(evaluation.flightLogs.count == 1 ? "" : "s") logged")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if evaluation.hasUnsatisfactoryItems && evaluation.allItemsGraded {
                Button {
                    var updated = evaluation
                    updated.currentSession += 1
                    store.updateEvaluation(updated)
                    showingUnsatisfactoryGrading = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text("Review Unsatisfactory Items")
                                .font(.headline)
                            Text("\(evaluation.unsatisfactoryCount) items to review")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .tint(.orange)
            }

            if evaluation.allItemsGraded {
                Button {
                    showingCompleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark.seal")
                            .font(.title2)
                            .foregroundStyle(.green)
                        Text("Complete Evaluation")
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
                .tint(.green)
                .alert("Complete Evaluation", isPresented: $showingCompleteAlert) {
                    TextField("Certifying Pilot Name", text: $certifyingPilotName)
                    Button("Complete") {
                        var updated = evaluation
                        updated.isComplete = true
                        updated.certifyingPilotName = certifyingPilotName
                        store.updateEvaluation(updated)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Enter the certifying pilot's name to finalize this evaluation.")
                }
            }
        }
    }

    private func generalCommentsSection(_ evaluation: Evaluation) -> some View {
        Section("General Comments") {
            TextField("Enter general comments...", text: Binding(
                get: { evaluation.generalComments },
                set: { newValue in
                    var updated = evaluation
                    updated.generalComments = newValue
                    store.updateEvaluation(updated)
                }
            ), axis: .vertical)
            .lineLimit(3...8)
        }
    }

    private func signatureSection(_ evaluation: Evaluation) -> some View {
        Section("Signatures") {
            if let sigData = evaluation.pilotSignature {
                SignatureDisplayView(label: "Pilot: \(evaluation.pilotInfo.fullName)", signatureData: sigData, signatureDate: evaluation.pilotSignatureDate)
            }
            Button {
                showingPilotSignature = true
            } label: {
                Label(evaluation.pilotSignature == nil ? "Add Pilot Signature" : "Update Pilot Signature", systemImage: "signature")
            }

            if let sigData = evaluation.evaluatorSignature {
                SignatureDisplayView(label: "Evaluator: \(evaluation.evaluatorName)", signatureData: sigData, signatureDate: evaluation.evaluatorSignatureDate)
            }
            Button {
                showingEvaluatorSignature = true
            } label: {
                Label(evaluation.evaluatorSignature == nil ? "Add Evaluator Signature" : "Update Evaluator Signature", systemImage: "signature")
            }
        }
    }

    private func commentsSection(_ evaluation: Evaluation) -> some View {
        Section("Comments") {
            ForEach(commentItems(for: evaluation)) { item in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(item.id.uppercased())
                            .font(.caption.bold().monospaced())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.currentGrade?.color.opacity(0.15) ?? .gray.opacity(0.15))
                            .clipShape(Capsule())
                        if let grade = item.currentGrade {
                            Text(grade.displayName)
                                .font(.caption)
                                .foregroundStyle(grade.color)
                        }
                        Spacer()
                        Text(item.name)
                            .font(.subheadline.bold())
                    }
                    Text(item.comment)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var pdfSection: some View {
        Section {
            Button {
                showingPDFPreview = true
            } label: {
                Label("Generate PDF Report", systemImage: "doc.richtext")
            }
        }
    }

    private func exportSection(_ evaluation: Evaluation) -> some View {
        Section {
            Button {
                exportEvaluation(evaluation)
            } label: {
                Label("Export Evaluation", systemImage: "square.and.arrow.up")
            }
        }
    }

    private func exportEvaluation(_ evaluation: Evaluation) {
        guard let url = store.exportEvaluation(evaluation) else { return }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else { return }
        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = presenter.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
        presenter.present(activityVC, animated: true)
    }

    private func commentItems(for evaluation: Evaluation) -> [EvaluationItem] {
        evaluation.sections.flatMap { $0.items.filter { !$0.comment.isEmpty } }
    }
}

struct GradeCountBadge: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
