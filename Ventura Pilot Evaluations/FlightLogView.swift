import SwiftUI

struct FlightLogView: View {
    @Environment(EvaluationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let evaluationId: UUID

    @State private var entries: [FlightLogEntry] = []
    @State private var hasChanges = false

    var body: some View {
        List {
            ForEach($entries) { $entry in
                FlightLogEntryRow(entry: $entry) {
                    hasChanges = true
                }
            }
            .onDelete { offsets in
                entries.remove(atOffsets: offsets)
                hasChanges = true
            }

            Button {
                entries.append(FlightLogEntry())
                hasChanges = true
            } label: {
                Label("Add Flight", systemImage: "plus.circle.fill")
            }

            if !entries.isEmpty {
                Section {
                    HStack {
                        Text("Total Block Time")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f", totalBlockTime))
                            .font(.headline.monospacedDigit())
                    }
                }
            }
        }
        .navigationTitle("Flight Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveAndDismiss() }
                    .bold()
                    .disabled(!hasChanges)
            }
        }
        .onAppear {
            if let evaluation = store.evaluation(for: evaluationId) {
                entries = evaluation.flightLogs.sorted { $0.date > $1.date }
            }
        }
        .onDisappear {
            if hasChanges { saveChanges() }
        }
    }

    private var totalBlockTime: Double {
        entries.reduce(0) { $0 + (Double($1.blockTime) ?? 0) }
    }

    private func sortEntries() {
        entries.sort { $0.date > $1.date }
    }

    private func saveChanges() {
        sortEntries()
        guard var evaluation = store.evaluation(for: evaluationId) else { return }
        evaluation.flightLogs = entries
        store.updateEvaluation(evaluation)
    }

    private func saveAndDismiss() {
        saveChanges()
        hasChanges = false
        dismiss()
    }
}

struct FlightLogEntryRow: View {
    @Binding var entry: FlightLogEntry
    let onChange: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            DatePicker("Date", selection: $entry.date, displayedComponents: .date)
                .font(.subheadline)
                .onChange(of: entry.date) { _, _ in onChange() }

            HStack {
                VStack(alignment: .leading) {
                    Text("Departure")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("ICAO", text: $entry.departure)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .font(.subheadline)
                        .onChange(of: entry.departure) { _, _ in onChange() }
                }

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                    .padding(.top, 14)

                VStack(alignment: .leading) {
                    Text("Arrival")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("ICAO", text: $entry.arrival)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .font(.subheadline)
                        .onChange(of: entry.arrival) { _, _ in onChange() }
                }

                VStack(alignment: .leading) {
                    Text("Block Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0.0", text: $entry.blockTime)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .font(.subheadline)
                        .frame(width: 60)
                        .onChange(of: entry.blockTime) { _, _ in onChange() }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
