class Tasks {
  String taskName;
  String taskDescription;
  String priority;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  bool isReminderOn;
  String listName;

  Tasks({
    required this.taskName,
    required this.taskDescription,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.isReminderOn,
    required this.listName,
  });
}

class TaskName {
  String taskName;
  String priority;

  TaskName({
    required this.taskName,
    required this.priority,
});
}