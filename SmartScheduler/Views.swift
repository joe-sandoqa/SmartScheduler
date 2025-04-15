//
//  Views.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

// write the main view, along with the add reminders page here
import SwiftUI
import SwiftData
import MapKit
import CoreLocation

//Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}

//Location Completer
class LocationCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var completions: [MKLocalSearchCompletion] = []
    private var completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
    }
    
    func updateQuery(_ query: String) {
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.completions = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error in location completer: \(error.localizedDescription)")
    }
}

//MainView
struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ViewModel()
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.reminders.isEmpty {
                        Text("No reminders found.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.reminders, id: \.self) { reminder in
                                ReminderCardView(reminder: reminder)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: deleteReminder)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Smart Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReminder.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.setContext(context: modelContext)
            viewModel.getReminders()
        }
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            let reminder = viewModel.reminders[index]
            viewModel.deleteTask(reminder: reminder)
        }
    }
}

//ReminderCardView
struct ReminderCardView: View {
    var reminder: Reminder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reminder.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(reminder.desc)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text(reminder.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let location = reminder.location, !location.isEmpty {
                    Spacer()
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
                .shadow(radius: 4)
        )
        .padding(.vertical, 4)
    }
}

//AddReminderView with Location Autocomplete
struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var locationCompleter = LocationCompleter()
    
    @State private var title: String = ""
    @State private var desc: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header:
                    Text("Reminder Details")
                        .font(.headline)
                        .foregroundColor(.primary)
                ) {
                    TextField("Enter Title", text: $title)
                    TextField("Enter Description", text: $desc)
                    DatePicker("Select Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Enter Location (Optional)", text: $location)
                        .onChange(of: location) {
                            locationCompleter.updateQuery(location)
                        }
                    
                    if !locationCompleter.completions.isEmpty && !location.isEmpty {
                        List(locationCompleter.completions, id: \.self) { completion in
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                    .font(.body)
                                Text(completion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                location = completion.title
                                locationCompleter.completions = []
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addReminder(
                            title: title,
                            desc: desc,
                            date: date,
                            location: location.isEmpty ? nil : location
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || desc.isEmpty)
                }
            }
        }
    }
}

//Date Formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

//Previews
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView(viewModel: ViewModel())
    }
}

