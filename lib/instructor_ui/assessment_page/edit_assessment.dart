import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';

class EditAssessmentPage extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const EditAssessmentPage({super.key, required this.quizData});

  @override
  State<EditAssessmentPage> createState() => _EditAssessmentPageState();
}

class _EditAssessmentPageState extends State<EditAssessmentPage> {
  late TextEditingController _titleController;
  late TextEditingController _durationController;

  final List<Map<String, dynamic>> _questions = [];
  final List<TextEditingController> _questionControllers = [];
  final List<TextEditingController> _answerControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];

  static const Color stiNavy = Color(0xFF0D125A);
  static const Color bgColor = Color(0xFFF1F5F9);

  final List<String> _quizTypes = [
    "Identification",
    "True or False",
    "Multiple Choice",
    "Crossword",
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quizData['title']);
    String duration = widget.quizData['description']?.toString().replaceAll(RegExp(r'[^0-9]'), "") ?? "30";
    _durationController = TextEditingController(text: duration);
    _loadExistingQuestions();
  }

  Future<void> _loadExistingQuestions() async {
    final existingQuestions = await QuizService.getQuizDetails(widget.quizData['id']);
    if (mounted) {
      setState(() {
        _initializeQuestions(existingQuestions);
      });
    }
  }

  void _initializeQuestions(List<dynamic> initialData) {
    _questions.clear();
    _questionControllers.clear();
    _answerControllers.clear();
    _optionControllers.clear();

    for (var q in initialData) {
      String uiType = _reverseTypeMapper(q['type']?.toString() ?? "IDENTIFICATION");
      _questions.add({"type": uiType});
      _questionControllers.add(TextEditingController(text: q['question_text']));
      _answerControllers.add(TextEditingController(text: q['correct_answer']));
      
      List<dynamic> options = [];
      if (q['options'] != null) {
        options = q['options'] is String ? [] : q['options']; 
      }

      _optionControllers.add(List.generate(4, (i) {
        return TextEditingController(text: i < options.length ? options[i].toString() : "");
      }));
    }
  }

  String _reverseTypeMapper(String backendType) {
    switch (backendType.toUpperCase()) {
      case 'TF': return "True or False";
      case 'MULTIPLE_CHOICE': return "Multiple Choice";
      case 'CROSSWORD': return "Crossword";
      default: return "Identification";
    }
  }

  // --- NEW: COMPLETE ACTION ---
  void _markAsCompleted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Mark as Completed?"),
        content: const Text("This will lock the assessment and students will no longer be able to take it."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("MARK COMPLETED"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await QuizService.updateAssessmentStatus(widget.quizData['id'], 2); // Status 2 = Completed
      if (mounted && success) {
        Navigator.pop(context, true); // Refresh hub
      }
    }
  }

  // ... (dispose, _addNewQuestion, _removeQuestion remain the same)

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    for (var c in _questionControllers) { c.dispose(); }
    for (var c in _answerControllers) { c.dispose(); }
    for (var list in _optionControllers) {
      for (var c in list) { c.dispose(); }
    }
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add({"type": "Identification"});
      _questionControllers.add(TextEditingController());
      _answerControllers.add(TextEditingController());
      _optionControllers.add(List.generate(4, (_) => TextEditingController()));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _questionControllers.removeAt(index).dispose();
      _answerControllers.removeAt(index).dispose();
      for (var c in _optionControllers.removeAt(index)) { c.dispose(); }
    });
  }

  void _saveAllChanges() async {
    if (_titleController.text.isEmpty || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: stiNavy)),
    );

    final updatedData = {
      "subjectCode": widget.quizData['subject_code'] ?? "CPE 401",
      "title": _titleController.text.toUpperCase(),
      "description": "${_durationController.text}m",
      "questions": List.generate(_questions.length, (i) {
        String uiType = _questions[i]['type'];
        String backendType = "IDENTIFICATION";
        if (uiType == "True or False") backendType = "TF";
        if (uiType == "Multiple Choice") backendType = "MULTIPLE_CHOICE";
        if (uiType == "Crossword") backendType = "CROSSWORD";
        
        return {
          "type": backendType,
          "question_text": _questionControllers[i].text,
          "correct_answer": _answerControllers[i].text,
          "hint": uiType == "Crossword" ? "Crossword Clue" : "Assessment Item",
          "metadata": uiType == "Multiple Choice" 
              ? _optionControllers[i].map((c) => c.text).toList() 
              : null,
        };
      }),
    };

    bool success = await QuizService.updateAssessment(widget.quizData['id'], updatedData);

    if (!mounted) return;
    Navigator.pop(context); 

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assessment updated!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)
      );
      Navigator.pop(context, true); 
    }
  }

  void _confirmDelete() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Assessment?"),
        content: const Text("This will permanently remove this quiz and all student results."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "DELETE_SIGNAL"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == "DELETE_SIGNAL") {
      bool success = await QuizService.deleteAssessment(widget.quizData['id']);
      if (mounted && success) Navigator.pop(context, "DELETE_SIGNAL");
    }
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
        title: const Text("EDIT ASSESSMENT", 
          style: TextStyle(color: stiNavy, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.1)),
        actions: [
          // ADDED: Mark Completed Button
          TextButton.icon(
            onPressed: _markAsCompleted,
            icon: const Icon(Icons.task_alt, color: Colors.orange, size: 20),
            label: const Text("COMPLETE", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          IconButton(
            onPressed: _saveAllChanges, 
            icon: const Icon(Icons.save_rounded, color: Colors.green, size: 28)
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _editField("ASSESSMENT TITLE", _titleController, Icons.title),
          const SizedBox(height: 15),
          _editField("DURATION (MINUTES)", _durationController, Icons.timer, isNumeric: true),
          const Divider(height: 50),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) => _buildQuestionCard(index),
          ),
          
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _addNewQuestion, 
            icon: const Icon(Icons.add, size: 18), 
            label: const Text("ADD NEW QUESTION"),
            style: ElevatedButton.styleFrom(
              backgroundColor: stiNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 15)
            ),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: _confirmDelete, 
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent), 
            label: const Text("DELETE THIS ASSESSMENT", 
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: stiNavy),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: stiNavy, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    String selectedType = _questions[index]['type'];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: BorderSide(color: Colors.black.withAlpha(15))
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                  child: DropdownButton<String>(
                    value: selectedType,
                    underline: const SizedBox(),
                    style: const TextStyle(color: stiNavy, fontWeight: FontWeight.bold, fontSize: 12),
                    items: _quizTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _questions[index]['type'] = val!),
                  ),
                ),
                IconButton(onPressed: () => _removeQuestion(index), icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _questionControllers[index], 
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(hintText: "Enter question here...", border: InputBorder.none)
            ),
            if (selectedType == "Multiple Choice") ...[
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 45, crossAxisSpacing: 10, mainAxisSpacing: 10
                ),
                itemCount: 4,
                itemBuilder: (ctx, i) => TextField(
                  controller: _optionControllers[index][i], 
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: "Option ${String.fromCharCode(65 + i)}",
                    filled: true,
                    fillColor: bgColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)
                  )
                ),
              ),
            ],
            const SizedBox(height: 15),
            TextField(
              controller: _answerControllers[index], 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Correct Answer",
                prefixIcon: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                filled: true,
                fillColor: Colors.green.withAlpha(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
              )
            ),
          ],
        ),
      ),
    );
  }
}