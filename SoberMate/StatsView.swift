import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var selectedTimeFrame: String = "Weekly"
    let timeFrames = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Select Time Frame", selection: $selectedTimeFrame) {
                        ForEach(timeFrames, id: \.self) { timeFrame in
                            Text(timeFrame).tag(timeFrame)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: selectedTimeFrame, perform: { _ in
                        viewModel.fetchStats(for: selectedTimeFrame)
                    })

                    // Total Drinks Consumed
                    Group {
                        Text("Total Drinks Consumed")
                            .font(.headline)
                        Chart(viewModel.drinkStats) { stat in
                            BarMark(
                                x: .value("Details", stat.details),
                                y: .value("Drinks", stat.drinks)
                            )
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }

                    // Average Feeling Score
                    Group {
                        Text("Average Feeling Score")
                            .font(.headline)
                        Chart(viewModel.feelingStats) { stat in
                            LineMark(
                                x: .value("Date", stat.date, unit: .day),
                                y: .value("Feeling", stat.feeling)
                            )
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }

                    // Refresh Button
                    Button(action: {
                        viewModel.fetchStats(for: selectedTimeFrame)
                    }) {
                        Text("Refresh")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Statistics", displayMode: .inline)
            .onAppear {
                viewModel.fetchStats(for: selectedTimeFrame)
            }
        }
    }
}
