import 'package:flutter/material.dart';

class EditAssessmentPage extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const EditAssessmentPage({
    super.key, 
    required this.quizData
  });

  @override
  State<EditAssessmentPage> createState() => _EditAssessmentPageState();
}

class _EditAssessmentPageState extends State<EditAssessmentPage> {
  // --- CONTROLLERS & STATE ---
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  
  // Local list to manage questions dynamically
  List<Map<String, dynamic>> _questions = [];

  static const Color stiNavy = Color(0xFF0D125A);
  static const Color bgColor = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quizData['title']);
    _durationController = TextEditingController(text: widget.quizData['duration']);
    
    // Initialize with mock questions (In a real app, fetch these from your DB)
    _questions = [
      {"text": "What is the time complexity of a Binary Search?", "answer": "O(log n)"},
      {"text": "Is a Linked List a linear data structure?", "answer": "True"},
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // --- FUNCTIONALITY: ADD QUESTION ---
  void _addNewQuestion() {
    setState(() {
      _questions.add({"text": "", "answer": ""});
    });
  }

  // --- FUNCTIONALITY: REMOVE QUESTION ---
  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
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
          "EDIT ASSESSMENT",
          style: TextStyle(color: stiNavy, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'serif'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // SAVE LOGIC: You would send _questions and controllers to your backend here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Assessment updated successfully!")),
              );
              Navigator.pop(context);
            },
            child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("GENERAL SETTINGS"),
            _buildSettingsCard(),

            const SizedBox(height: 30),

            _buildSectionHeader("QUESTION EDITOR (${_questions.length})"),
            const SizedBox(height: 15),
            
            // DYNAMIC QUESTION LIST
            ..._questions.asMap().entries.map((entry) {
              return _buildQuestionCard(entry.key, entry.value);
            }),

            const SizedBox(height: 20),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.1, fontSize: 12),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _editField("Assessment Title", _titleController, Icons.title),
          const SizedBox(height: 20),
          _editField("Duration (e.g., 15 minutes)", _durationController, Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: stiNavy, size: 20),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("QUESTION ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: stiNavy)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _removeQuestion(index),
              ),
            ],
          ),
          TextField(
            onChanged: (val) => _questions[index]['text'] = val,
            controller: TextEditingController(text: question['text']),
            maxLines: 2,
            decoration: const InputDecoration(hintText: "Enter question here...", border: InputBorder.none),
          ),
          const Divider(),
          TextField(
            onChanged: (val) => _questions[index]['answer'] = val,
            controller: TextEditingController(text: question['answer']),
            decoration: const InputDecoration(
              hintText: "Correct Answer",
              prefixIcon: Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addNewQuestion,
        icon: const Icon(Icons.add),
        label: const Text("ADD NEW QUESTION"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: const BorderSide(color: stiNavy, width: 1.5),
          foregroundColor: stiNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}