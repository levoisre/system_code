import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class NewCoursePage extends StatefulWidget {
  const NewCoursePage({super.key});

  @override
  State<NewCoursePage> createState() => _NewCoursePageState();
}

class _NewCoursePageState extends State<NewCoursePage> {
  static const Color darkBlue = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF4F7FA);
  static const Color borderSideColor = Color(0xFFEEEEEE);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _fileName;
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 30);
  final List<String> _daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final List<String> _selectedDays = [];

  Future<void> _pickStudentList() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CREATE NEW COURSE',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Centering the form on Desktop (Max width 700px)
          double horizontalPadding = constraints.maxWidth > 800 
              ? (constraints.maxWidth - 700) / 2 
              : 20;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernField("Course Name", _nameController, Icons.subtitles_outlined),
                  const SizedBox(height: 15),
                  _buildModernField("Course Code", _codeController, Icons.qr_code_2_outlined),
                  
                  const SizedBox(height: 30),
                  const Text("Class Days", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Flexible Wrap for Class Days to avoid overflow on narrow screens
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _daysOfWeek.map((day) {
                      final bool isSelected = _selectedDays.contains(day);
                      return InkWell(
                        onTap: () => setState(() => isSelected ? _selectedDays.remove(day) : _selectedDays.add(day)),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? darkBlue : const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? darkBlue : borderSideColor),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),
                  
                  // Adaptive Row/Column for TimePickers
                  constraints.maxWidth < 450 
                  ? Column(
                      children: [
                        _buildTimePicker("Start Time", _startTime, true),
                        const SizedBox(height: 15),
                        _buildTimePicker("End Time", _endTime, false),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildTimePicker("Start Time", _startTime, true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTimePicker("End Time", _endTime, false)),
                      ],
                    ),

                  const SizedBox(height: 20),
                  _buildModernField("Room / Laboratory", _locController, Icons.location_on_outlined),
                  
                  const SizedBox(height: 20),
                  _buildModernField("Description", _descController, Icons.description_outlined, isMultiline: true),

                  const SizedBox(height: 30),
                  
                  const Text("Student List", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickStudentList,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderSideColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.upload_file_rounded, color: darkBlue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fileName ?? "Upload Student List (CSV/Excel)",
                              style: TextStyle(
                                color: _fileName == null ? Colors.black38 : Colors.black87,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_fileName != null)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isEmpty || _selectedDays.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please provide a name and select at least one day.")),
                          );
                          return;
                        }
                        
                        final newCourse = {
                          "title": _nameController.text,
                          "sched": "${_selectedDays.join('')} ${_startTime.format(context)} - ${_endTime.format(context)}",
                          "code": _codeController.text,
                          "desc": _descController.text,
                          "studentList": _fileName,
                          "color": const Color(0xFFB3E5FC), 
                        };
                        
                        Navigator.pop(context, newCourse);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ACTIVATE COURSE',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif', letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context, isStart),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderSideColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const Icon(Icons.access_time_filled_rounded, color: darkBlue, size: 18),
              ],
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 3 : 1,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: darkBlue.withValues(alpha: 0.4), size: 20),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderSideColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: darkBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locController.dispose();
    _descController.dispose();
    super.dispose();
  }
}