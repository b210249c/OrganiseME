import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const ReminderSwitch({super.key,
    required this.initialValue,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  _ReminderSwitchState createState() => _ReminderSwitchState();
}

class _ReminderSwitchState extends State<ReminderSwitch> {
  late bool _isReminderOn;

  @override
  void initState() {
    super.initState();
    _isReminderOn = widget.initialValue;
  }

  void _toggleSwitch(bool value) {
    setState(() {
      _isReminderOn = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          'Reminders',
          textScaleFactor: 1.2.sp,
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.w700,
            fontSize: 8.sp,
          ),
        ),
        Switch(
          value: _isReminderOn,
          onChanged: _toggleSwitch,
          activeColor: widget.activeColor,
        ),
      ],
    );
  }
}
