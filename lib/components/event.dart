class Event {
  String eventName;
  String eventDescription;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  bool isReminderOn;

  Event({
    required this.eventName,
    required this.eventDescription,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.isReminderOn,
  });
}
