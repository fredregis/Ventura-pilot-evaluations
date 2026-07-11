import SwiftUI

struct GradingSessionView: View {
    @Environment(EvaluationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let evaluationId: UUID
    let showOnlyUnsatisfactory: Bool

    @State private var sections: [EvaluationSection] = []
    @State private var expandedSections: Set<Int> = []
    @State private var hasChanges = false

    var body: some View {
        List {
            gradingLegend

            ForEach($sections) { $section in
                Section {
                    if expandedSections.contains(section.id) {
                        ForEach($section.items) { $item in
                            ItemGradeRow(item: $item, session: currentSession) {
                                hasChanges = true
                            }
                        }
                    }
                } header: {
                    SectionHeaderButton(section: section, isExpanded: expandedSections.contains(section.id)) {
                        toggleSection(section.id)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(showOnlyUnsatisfactory ? "Review Unsatisfactory" : "Grade Items")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        if expandedSections.isEmpty {
                            expandedSections = Set(sections.map(\.id))
                        } else {
                            expandedSections.removeAll()
                        }
                    }
                } label: {
                    Image(systemName: expandedSections.isEmpty ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveAndDismiss() }
                    .bold()
                    .disabled(!hasChanges)
            }
        }
        .onAppear { loadSections() }
        .onDisappear { if hasChanges { saveChanges() } }
    }

    private var gradingLegend: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Grade.allCases, id: \.self) { grade in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(grade.color)
                            .frame(width: 8, height: 8)
                        Text(grade.displayName)
                            .font(.caption)
                    }
                }
                if showOnlyUnsatisfactory {
                    Text("Showing only items previously graded 1 or 2")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .padding(.top, 2)
                }
            }
        }
    }

    private var currentSession: Int {
        store.evaluation(for: evaluationId)?.currentSession ?? 1
    }

    private func toggleSection(_ id: Int) {
        withAnimation {
            if expandedSections.contains(id) {
                expandedSections.remove(id)
            } else {
                expandedSections.insert(id)
            }
        }
    }

    private func loadSections() {
        guard let evaluation = store.evaluation(for: evaluationId) else { return }
        if showOnlyUnsatisfactory {
            sections = evaluation.unsatisfactorySections
        } else {
            sections = evaluation.sections
        }
        expandedSections = Set(sections.map(\.id))
    }

    private func saveChanges() {
        guard var evaluation = store.evaluation(for: evaluationId) else { return }
        for section in sections {
            guard let sectionIndex = evaluation.sections.firstIndex(where: { $0.id == section.id }) else { continue }
            for item in section.items {
                if let itemIndex = evaluation.sections[sectionIndex].items.firstIndex(where: { $0.id == item.id }) {
                    evaluation.sections[sectionIndex].items[itemIndex] = item
                }
            }
        }
        store.updateEvaluation(evaluation)
    }

    private func saveAndDismiss() {
        saveChanges()
        hasChanges = false
        dismiss()
    }
}

// MARK: - Section Header

struct SectionHeaderButton: View {
    let section: EvaluationSection
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(section.id)")
                    .font(.caption.bold())
                    .frame(width: 24, height: 24)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                Text(section.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Spacer()
                progressIndicator
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var progressIndicator: some View {
        let graded = section.items.filter(\.isGraded).count
        let total = section.items.count
        let unsat = section.items.filter(\.isUnsatisfactory).count

        return HStack(spacing: 4) {
            if unsat > 0 {
                Text("\(unsat)")
                    .font(.caption2.bold())
                    .foregroundStyle(.orange)
            }
            Text("\(graded)/\(total)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Item Grade Row

struct ItemGradeRow: View {
    @Binding var item: EvaluationItem
    let session: Int
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.id)
                    .font(.caption.bold().monospaced())
                    .foregroundStyle(.secondary)
                    .frame(width: 32, alignment: .leading)
                Text(item.name)
                    .font(.subheadline)
                Spacer()
                gradePicker
            }

            if item.isGraded {
                ZStack(alignment: .topLeading) {
                    if item.comment.isEmpty {
                        Text(item.isUnsatisfactory ? "Comment required for \(item.id)..." : "Comment for \(item.id)...")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 5)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $item.comment)
                        .font(.caption)
                        .frame(minHeight: 54)
                        .scrollContentBackground(.hidden)
                        .onChange(of: item.comment) { _, _ in onChange() }
                }
                .padding(4)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 2)
    }

    private var gradePicker: some View {
        HStack(spacing: 3) {
            ForEach(Grade.allCases, id: \.self) { grade in
                Button {
                    setGrade(grade)
                } label: {
                    Text(grade.shortName)
                        .font(.caption2.bold())
                        .frame(width: 28, height: 28)
                        .background(item.currentGrade == grade ? grade.color : Color(.systemGray6))
                        .foregroundStyle(item.currentGrade == grade ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()

    private func setGrade(_ grade: Grade) {
        let wasUnsatisfactory = item.isUnsatisfactory
        if item.currentGrade == grade {
            if let lastIndex = item.gradeHistory.indices.last {
                item.gradeHistory.remove(at: lastIndex)
            }
        } else {
            item.gradeHistory.append(GradeEntry(grade: grade, date: Date(), session: session))
            if grade.isUnsatisfactory && item.comment.isEmpty {
                item.comment = "\(Self.dateFormatter.string(from: Date())) - "
            }
        }
        if wasUnsatisfactory && !item.isUnsatisfactory && item.comment.hasSuffix(" - ") {
            item.comment = ""
        }
        onChange()
    }
}
