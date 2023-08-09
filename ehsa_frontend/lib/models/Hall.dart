class Hall {
  final String hallName;
  final int capacity;
  String editedHallName; // Added variable to hold edited hallName
  int editedCapacity; // Added variable to hold edited capacity

  Hall(this.hallName, this.capacity)
      : editedHallName = hallName,
        editedCapacity =
            capacity; // Initialize editedHallName and editedCapacity

  Map<String, dynamic> toMap() {
    return {
      'name': editedHallName, // Use editedHallName in toMap method
      'capacity': editedCapacity, // Use editedCapacity in toMap method
    };
  }
}
