import 'package:flutter/material.dart';

class RequestFormPage extends StatefulWidget {
  const RequestFormPage({super.key});

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  // Official STI Colors (Synced with Home/History)
  static const Color stiNavy = Color(0xFF0C1446);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color background = Color(0xFFF1F4F9);

  bool showSuccess = false;

  // Form Controllers
  final TextEditingController _dateController = TextEditingController(text: "04/10/2026");
  final TextEditingController _clockInController = TextEditingController(text: "07:30 AM");
  final TextEditingController _clockOutController = TextEditingController(text: "09:30 AM");
  final TextEditingController _explanationController = TextEditingController();

  String? selectedReason = "Forgot to Clock In";
  String _fileName = "No file attached";
  bool _isUploading = false;

  final List<String> reasons = [
    "Wrong Clock In", 
    "Wrong Clock Out", 
    "Forgot to Clock In", 
    "Forgot to Clock Out", 
    "Technical Issue", 
    "Emergency/Health", 
    "Other"
  ];

  void _pickFile() {
    setState(() => _isUploading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _fileName = "attendance_proof_ref_992.pdf";
        });
      }
    });
  }

  void _handleFormSubmit() {
    setState(() => showSuccess = true);

    final newRequest = {
      "date": _dateController.text,
      "reason": selectedReason ?? "Other",
      "status": "Pending",
      "type": "Adjustment", 
      "time": "${_clockInController.text} - ${_clockOutController.text}",
    };

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context, newRequest);
    });
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: stiNavy)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => controller.text = picked.format(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      // --- HEADER MATCHING HISTORY UI ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040), 
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "File Appeal",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'serif',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white), 
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Checking for request updates..."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                _buildSectionHeader("AFFECTED SESSION", Icons.history_toggle_off),
                const SizedBox(height: 12),
                _buildInputCard([
                  _buildField(_dateController, label: "Scheduled Date", icon: Icons.calendar_month, isReadOnly: true),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTimePicker('Requested In', _clockInController)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildTimePicker('Requested Out', _clockOutController)),
                    ],
                  ),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader("JUSTIFICATION", Icons.rate_review_outlined),
                const SizedBox(height: 12),
                _buildInputCard([
                  _buildDropdown(),
                  const SizedBox(height: 15),
                  _buildTextArea(),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader("SUPPORTING EVIDENCE", Icons.attach_file_rounded),
                const SizedBox(height: 12),
                _buildUploadBox(),
                const SizedBox(height: 40),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black38),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black38, fontSize: 10, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: stiNavy.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField(TextEditingController controller, {required String label, required IconData icon, bool isReadOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: stiNavy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, size: 18, color: stiGold),
        filled: true,
        fillColor: background.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTimePicker(String label, TextEditingController controller) {
    return InkWell(
      onTap: () => _selectTime(controller),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(color: background.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_filled, size: 14, color: stiGold),
                const SizedBox(width: 8),
                Text(controller.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: stiNavy)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(color: background.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedReason,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: stiGold),
          style: const TextStyle(color: stiNavy, fontWeight: FontWeight.w900, fontSize: 14),
          items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => selectedReason = v),
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return TextField(
      controller: _explanationController,
      maxLines: 4,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: "State your reason for adjustment...",
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: background.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildUploadBox() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: stiNavy.withValues(alpha: 0.1), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            _isUploading 
              ? const CircularProgressIndicator(strokeWidth: 3, color: stiGold)
              : const Icon(Icons.cloud_upload_rounded, color: stiGold, size: 40),
            const SizedBox(height: 12),
            Text(_fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: stiNavy)),
            const Text("Accepted: PDF, PNG, JPG", style: TextStyle(fontSize: 9, color: Colors.black26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _button('CANCEL', Colors.white, Colors.black45, () => Navigator.pop(context)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _button('SUBMIT REQUEST', stiNavy, Colors.white, _handleFormSubmit),
        ),
      ],
    );
  }

  Widget _button(String label, Color bg, Color text, VoidCallback action) => ElevatedButton(
    onPressed: action,
    style: ElevatedButton.styleFrom(
      backgroundColor: bg, 
      foregroundColor: text, 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), 
      minimumSize: const Size(0, 60)
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
  );

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 25),
              const Text('REQUEST\nLOGGED', textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: stiNavy, height: 1.2, fontFamily: 'serif')),
              const SizedBox(height: 15),
              const Text('Your appeal has been successfully sent for faculty review.', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}