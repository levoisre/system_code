import 'package:flutter/material.dart';

class RequestFormPage extends StatefulWidget {
  const RequestFormPage({super.key});

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color bgColor = Color(0xFFF8F9FA);
  bool showSuccess = false;

  final TextEditingController _studentNumController = TextEditingController(text: "02000654892");
  final TextEditingController _studentNameController = TextEditingController(text: "Kristina Dela Cruz");
  final TextEditingController _dateController = TextEditingController(text: "03/09/2026");
  final TextEditingController _clockInController = TextEditingController(text: "09:30 AM");
  final TextEditingController _clockOutController = TextEditingController(text: "02:00 PM");
  final TextEditingController _explanationController = TextEditingController(text: "Forgot to clock in on time.");

  String? selectedReason = "Forgot to Clock In";
  String _fileName = "No file attached";
  bool _isUploading = false;

  final List<String> reasons = [
    "Wrong Clock In", "Wrong Clock Out", "Forgot to Clock In", 
    "Forgot to Clock Out", "Technical Issue", "Emergency/Health", "Other"
  ];

  void _pickFile() {
    setState(() => _isUploading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isUploading = false;
        _fileName = "medical_cert_01.jpg";
      });
    });
  }

  void _handleFormSubmit() {
    setState(() => showSuccess = true);

    final newRequest = {
      "date": _dateController.text,
      "reason": selectedReason ?? "Other",
      "status": "Pending",
      "time": "${_clockInController.text} - ${_clockOutController.text}",
    };

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context, newRequest); 
    });
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => controller.text = picked.format(context));
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
          const Text('New Attendance Request', 
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
                _buildFieldLabel('Student Information:'),
                _buildField(_studentNumController, icon: Icons.badge_outlined),
                _buildField(_studentNameController, icon: Icons.person_outline),
                _buildFieldLabel('Date of Request:'),
                _buildField(_dateController, icon: Icons.calendar_month),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildTimePicker('Clock In:', _clockInController)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTimePicker('Clock Out:', _clockOutController)),
                  ],
                ),
                _buildFieldLabel('Reason Category:'),
                _buildDropdown(),
                _buildFieldLabel('Detailed Explanation:'),
                _buildTextArea(),
                const SizedBox(height: 20),
                _buildFieldLabel('Attach Evidence:'),
                _buildUploadBox(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildButton('DISCARD', Colors.white, darkNavy, () => Navigator.pop(context))),
              const SizedBox(width: 15),
              Expanded(child: _buildButton('SUBMIT', darkNavy, Colors.white, _handleFormSubmit)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectTime(controller),
          child: AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
              child: Row(children: [
                const Icon(Icons.access_time, size: 14, color: Colors.black54),
                const SizedBox(width: 8),
                Text(controller.text, style: const TextStyle(fontSize: 11)),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          // FIXED: Changed withOpacity to withValues
          border: Border.all(color: Colors.blue.withValues(alpha: 0.2), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            _isUploading 
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 30),
            const SizedBox(height: 12),
            Text(_fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedReason,
          isExpanded: true,
          items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => selectedReason = v),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 18, color: darkNavy) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
      child: TextField(
        controller: _explanationController,
        maxLines: 3,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 5), 
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkNavy))
  );

  Widget _buildButton(String label, Color bg, Color text, VoidCallback action) => ElevatedButton(
    onPressed: action,
    style: ElevatedButton.styleFrom(
      backgroundColor: bg, foregroundColor: text, shape: const StadiumBorder(), 
      side: const BorderSide(color: darkNavy), minimumSize: const Size(0, 50)
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: const Color(0xFFDDE4F3), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.black, width: 2)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text('REQUEST\nSUBMITTED!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}