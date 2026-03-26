import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // REQUIRED: Run 'flutter pub add intl' in terminal

class RequestFormPage extends StatefulWidget {
  const RequestFormPage({super.key});

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  static const Color darkNavy = Color(0xFF0C1446);
  bool showSuccess = false;

  // Controllers to manage the live typing and data retrieval
  final TextEditingController _studentNumController = TextEditingController(text: "02000654892");
  final TextEditingController _studentNameController = TextEditingController(text: "Kristina Dela Cruz");
  final TextEditingController _dateController = TextEditingController(text: "03/09/2026");
  final TextEditingController _clockInController = TextEditingController(text: "09:30 AM");
  final TextEditingController _clockOutController = TextEditingController(text: "02:00 PM");
  final TextEditingController _explanationController = TextEditingController(text: "On time in school but forgot to clock in on time.");

  String? selectedReason = "Wrong Clock In";
  final List<String> reasons = [
    "Wrong Clock In",
    "Wrong Clock Out",
    "Forgot to Clock In",
    "Forgot to Clock Out",
    "Technical Issue",
    "Emergency/Health",
    "Other"
  ];

  // INTERACTIVE DATE PICKER
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 3, 9),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  // INTERACTIVE TIME PICKER
  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('REQUEST FORM', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif')),
      ),
      body: Stack(
        children: [
          _buildFormContent(),
          if (showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('New Attendance Request 1', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy, fontFamily: 'serif')),
          const Divider(thickness: 1, color: Colors.black26, indent: 50, endIndent: 50),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: Colors.black12)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Student Number:'),
                _buildEditableField(_studentNumController, null),

                _buildFieldLabel('Student Name:'),
                _buildEditableField(_studentNameController, null),

                _buildFieldLabel('Date:'),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: _buildEditableField(_dateController, Icons.calendar_month, hasDropdown: true)
                  ),
                ),

                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildTimePickerField('Clock In:', _clockInController)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTimePickerField('Clock Out:', _clockOutController)),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),

                _buildFieldLabel('Reason:'),
                _buildReasonDropdown(),

                _buildFieldLabel('Explanation:'),
                _buildTextArea(_explanationController),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildButton('DISCARD', Colors.white, darkNavy, () => Navigator.pop(context))),
              const SizedBox(width: 15),
              Expanded(child: _buildButton('SUBMIT', darkNavy, Colors.white, () => setState(() => showSuccess = true))),
            ],
          )
        ],
      ),
    );
  }

  // --- INTERACTIVE WIDGETS ---

  Widget _buildReasonDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.black12)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          // FIXED: Use initialValue to avoid deprecation warnings
          initialValue: selectedReason,
          decoration: const InputDecoration(border: InputBorder.none),
          items: reasons.map((String value) {
            return DropdownMenuItem<String>(
              value: value, 
              child: Text(value, style: const TextStyle(fontSize: 14, fontFamily: 'serif'))
            );
          }).toList(),
          onChanged: (newValue) => setState(() => selectedReason = newValue),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'serif')),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectTime(controller),
          child: AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA), 
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: Colors.black12)
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.black54),
                  const SizedBox(width: 5),
                  Expanded(child: Text(controller.text, 
                    style: const TextStyle(fontSize: 11, fontFamily: 'serif'))),
                  const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildEditableField(TextEditingController controller, IconData? icon, {bool hasDropdown = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.black12)
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, fontFamily: 'serif'),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.black54) : null,
          suffixIcon: hasDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.black54) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.black12)
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(fontSize: 14, fontFamily: 'serif'),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 5), 
    child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87, fontFamily: 'serif'))
  );

  Widget _buildButton(String label, Color bg, Color text, VoidCallback action) => ElevatedButton(
    onPressed: action, 
    style: ElevatedButton.styleFrom(
      backgroundColor: bg, 
      foregroundColor: text, 
      shape: const StadiumBorder(), 
      side: BorderSide(color: darkNavy), 
      minimumSize: const Size(0, 50)
    ), 
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'serif'))
  );

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() => showSuccess = false);
            
            // PACKAGE DATA: Create the data object to send back to the history page
            final newRequest = {
              "date": _dateController.text,
              "reason": selectedReason ?? "Other",
              "status": "Pending",
            };

            // POP AND SEND RESULT
            Navigator.pop(context, newRequest); 
          },
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFDDE4F3).withValues(alpha: 0.95), 
              borderRadius: BorderRadius.circular(25), 
              border: Border.all(color: Colors.black, width: 2)
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('REQUEST\nSUBMITTED!', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, height: 1.1, fontFamily: 'serif', color: Colors.black)),
                SizedBox(height: 30),
                Text('Please wait for your Advisor\nto accept the request, thank\nyou!', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 18, color: Colors.black87, fontFamily: 'serif')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}