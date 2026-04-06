import 'package:flutter/material.dart';

class CreateAssessmentPage extends StatefulWidget {
  const CreateAssessmentPage({super.key});

  @override
  State<CreateAssessmentPage> createState() => _CreateAssessmentPageState();
}

class _CreateAssessmentPageState extends State<CreateAssessmentPage> {
  // --- SETTINGS & COLORS ---
  static const Color stiNavy = Color(0xFF0D125A);
  // REMOVED: stiYellow (was unused)
  static const Color bgColor = Color(0xFFF1F5F9);

  // --- FORM CONTROLLERS ---
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: stiNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CREATE NEW ASSESSMENT",
          style: TextStyle(
            color: stiNavy, 
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            fontFamily: 'serif'
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ASSESSMENT DETAILS",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.black45, 
                letterSpacing: 1.1, 
                fontSize: 12
              ),
            ),
            const SizedBox(height: 15),

            _buildFormCard(),

            const SizedBox(height: 30),

            const Text(
              "QUESTION BUILDER",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.black45, 
                letterSpacing: 1.1, 
                fontSize: 12
              ),
            ),
            const SizedBox(height: 15),

            _buildEmptyQuestionPlaceholder(),

            const SizedBox(height: 40),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        children: [
          _inputField("Assessment Title", "e.g. Midterm Quiz", _titleController, Icons.title),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _inputField("Duration (Mins)", "30", _durationController, Icons.timer_outlined),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _inputField("Total Points", "50", _pointsController, Icons.stars_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: stiNavy, size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black12, fontSize: 14),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyQuestionPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, size: 50, color: stiNavy.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          const Text(
            "No questions added yet.",
            style: TextStyle(color: Colors.black26, fontSize: 14),
          ),
          const SizedBox(height: 15),
          TextButton.icon(
            onPressed: () {
              // Action logic for adding questions
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("ADD FIRST QUESTION"),
            style: TextButton.styleFrom(foregroundColor: stiNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Assessment Created Successfully!")),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: stiNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("PUBLISH ASSESSMENT", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}