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
                Section("Totals") {
                    HStack {
                        Text("Block Time")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.1f", totalBlockTime))
                            .font(.subheadline.monospacedDigit())
                    }
                    HStack {
                        Text("Day Landings")
                            .font(.subheadline)
                        Spacer()
                        Text("\(totalDayLandings)")
                            .font(.subheadline.monospacedDigit())
                    }
                    HStack {
                        Text("Night Landings")
                            .font(.subheadline)
                        Spacer()
                        Text("\(totalNightLandings)")
                            .font(.subheadline.monospacedDigit())
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

    private var totalDayLandings: Int {
        entries.reduce(0) { $0 + $1.dayLandings }
    }

    private var totalNightLandings: Int {
        entries.reduce(0) { $0 + $1.nightLandings }
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
        VStack(spacing: 10) {
            DatePicker("Date", selection: $entry.date, displayedComponents: .date)
                .font(.subheadline)
                .onChange(of: entry.date) { _, _ in onChange() }

            HStack {
                VStack(alignment: .leading) {
                    Text("Departure")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("ICAO", text: $entry.departure)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .font(.subheadline)
                        .onChange(of: entry.departure) { _, _ in onChange() }
                }
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary).padding(.top, 14)
                VStack(alignment: .leading) {
                    Text("Arrival")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("ICAO", text: $entry.arrival)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .font(.subheadline)
                        .onChange(of: entry.arrival) { _, _ in onChange() }
                }
                VStack(alignment: .leading) {
                    Text("Block Time")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("0.0", text: $entry.blockTime)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .font(.subheadline)
                        .frame(width: 60)
                        .onChange(of: entry.blockTime) { _, _ in onChange() }
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Tail Number")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("N12345", text: $entry.tailNumber)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.subheadline)
                        .onChange(of: entry.tailNumber) { _, _ in onChange() }
                }
                VStack(alignment: .leading) {
                    Text("Avionics")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("Suite", text: $entry.avionics)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)
                        .onChange(of: entry.avionics) { _, _ in onChange() }
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Pilot Flying (PF)")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("Name", text: $entry.pf)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .font(.subheadline)
                        .onChange(of: entry.pf) { _, _ in onChange() }
                }
                VStack(alignment: .leading) {
                    Text("Pilot Monitoring (PM)")
                        .font(.caption).foregroundStyle(.secondary)
                    TextField("Name", text: $entry.pm)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .font(.subheadline)
                        .onChange(of: entry.pm) { _, _ in onChange() }
                }
            }

            Stepper("Day Landings: \(entry.dayLandings)", value: $entry.dayLandings, in: 0...99)
                .font(.subheadline)
                .onChange(of: entry.dayLandings) { _, _ in onChange() }

            Stepper("Night Landings: \(entry.nightLandings)", value: $entry.nightLandings, in: 0...99)
                .font(.subheadline)
                .onChange(of: entry.nightLandings) { _, _ in onChange() }
        }
        .padding(.vertical, 4)
    }
}
