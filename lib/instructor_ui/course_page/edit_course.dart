import 'package:flutter/material.dart';

class EditCoursePage extends StatefulWidget {
  final Map<String, dynamic>? courseData;
  const EditCoursePage({super.key, this.courseData});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  static const Color darkBlue = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF4F7FA);
  static const Color borderSideColor = Color(0xFFEEEEEE);
  static const Color destructiveRed = Color(0xFFD32F2F);

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _locController;
  late TextEditingController _descController;

  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 30);

  final List<String> _students = [
    "Amigo, Raphael",
    "Brusco, Hannah",
    "Fabrino, Valerie",
    "Garcia, Maria",
    "Johnson, Alex",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.courseData?['title'] ?? "");
    _codeController = TextEditingController(text: widget.courseData?['code'] ?? "");
    _locController = TextEditingController(text: widget.courseData?['room'] ?? "");
    _descController = TextEditingController(text: widget.courseData?['desc'] ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text('EDIT COURSE', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildMainCard(
                    child: Column(
                      children: [
                        _buildModernField("Subject Name", _nameController, Icons.book_outlined),
                        const SizedBox(height: 15),
                        _buildModernField("Subject Code", _codeController, Icons.qr_code_2_outlined),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildTimeBox("Starts", _startTime, true)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTimeBox("Ends", _endTime, false)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildModernField("Location", _locController, Icons.location_on_outlined),
                        const SizedBox(height: 15),
                        _buildModernField("Description", _descController, Icons.description_outlined, isMultiline: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: _buildMainCard(
                    child: Column(
                      children: [
                        const Text("Class List", style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
                        const Divider(height: 30),
                        SizedBox(
                          height: 350,
                          child: ListView.builder(
                            itemCount: _students.length,
                            itemBuilder: (context, index) => ListTile(
                              leading: const Icon(Icons.account_circle, color: darkBlue),
                              title: Text(_students[index], style: const TextStyle(fontSize: 13)),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: destructiveRed),
                                onPressed: () => setState(() => _students.removeAt(index)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBtn("DELETE COURSE", destructiveRed, () => Navigator.pop(context, "DELETE"), true),
                Row(
                  children: [
                    _buildBtn("CANCEL", Colors.black54, () => Navigator.pop(context), true),
                    const SizedBox(width: 15),
                    _buildBtn("SAVE CHANGES", darkBlue, () {
                      final updated = {
                        "title": _nameController.text,
                        "code": _codeController.text,
                        "room": _locController.text,
                        "desc": _descController.text,
                        "sched": "${_startTime.format(context)} - ${_endTime.format(context)}",
                        "color": widget.courseData?['color'] ?? darkBlue,
                        "category": widget.courseData?['category'] ?? "Core",
                      };
                      Navigator.pop(context, updated);
                    }, false),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), 
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 15)]),
      child: child,
    );
  }

  Widget _buildTimeBox(String label, TimeOfDay time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), border: Border.all(color: borderSideColor), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // FIX: Removed unnecessary braces around label
              children: [Text("$label: ${time.format(context)}", style: const TextStyle(fontSize: 12)), const Icon(Icons.access_time, size: 18, color: darkBlue)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernField(String label, TextEditingController controller, IconData icon, {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 3 : 1,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0x4D000080)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderSideColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBlue)),
          ),
        ),
      ],
    );
  }

  Widget _buildBtn(String label, Color color, VoidCallback tap, bool outline) {
    return SizedBox(
      height: 48, width: 150,
      child: outline
          ? OutlinedButton(onPressed: tap, style: OutlinedButton.styleFrom(side: BorderSide(color: color), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)))
          : ElevatedButton(onPressed: tap, style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
    );
  }
}