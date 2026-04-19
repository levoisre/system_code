import 'package:flutter/material.dart';
import 'quiz_service.dart';

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
    
    String duration = widget.quizData['duration'].toString().replaceAll(RegExp(r'[^0-9]'), "");
    _durationController = TextEditingController(text: duration);

    final List<dynamic> existingQuestions = widget.quizData['fullQuestionData'] ?? [];
    _initializeQuestions(existingQuestions);
  }

  void _initializeQuestions(List<dynamic> initialData) {
    for (var q in initialData) {
      // FIXED: Added curly braces to loop blocks to resolve linting errors
      _questions.add({"type": q['type'] ?? "Identification"});
      _questionControllers.add(TextEditingController(text: q['text']));
      _answerControllers.add(TextEditingController(text: q['answer']));
      
      List<dynamic> options = q['options'] ?? ["", "", "", ""];
      _optionControllers.add(List.generate(4, (i) {
        return TextEditingController(text: i < options.length ? options[i].toString() : "");
      }));
    }
  }

  @override
  void dispose() {
    // FIXED: Added curly braces to dispose loops
    _titleController.dispose();
    _durationController.dispose();
    for (var c in _questionControllers) {
      c.dispose();
    }
    for (var c in _answerControllers) {
      c.dispose();
    }
    for (var list in _optionControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add({"type": "Identification"});
      _addQuestionControllers();
    });
  }

  void _addQuestionControllers() {
    _questionControllers.add(TextEditingController());
    _answerControllers.add(TextEditingController());
    _optionControllers.add(List.generate(4, (_) => TextEditingController()));
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _questionControllers[index].dispose();
      _answerControllers[index].dispose();
      for (var c in _optionControllers[index]) {
        c.dispose();
      }
      
      _questionControllers.removeAt(index);
      _answerControllers.removeAt(index);
      _optionControllers.removeAt(index);
    });
  }

  void _updateStatus(int newStatus) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (c) => const Center(child: CircularProgressIndicator(color: stiNavy))
    );
    
    bool success = await QuizService.updateAssessmentStatus(widget.quizData['id'], newStatus);
    
    // FIXED: BuildContext guard after async gap
    if (!mounted) return;
    Navigator.pop(context); 

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status updated successfully!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context, true); 
    }
  }

  void _saveAllChanges() async {
    if (_titleController.text.isEmpty || _durationController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Duration are required")));
      return;
    }

    final updatedData = {
      "title": _titleController.text.toUpperCase(),
      "description": "${_durationController.text} min duration",
      "questions": List.generate(_questions.length, (i) {
        return {
          "type": _questions[i]['type'].toString().toUpperCase().replaceAll(" ", "_"),
          "question_text": _questionControllers[i].text,
          "correct_answer": _answerControllers[i].text,
          "metadata": _questions[i]['type'] == "Multiple Choice" 
              ? _optionControllers[i].map((c) => c.text).toList() 
              : null,
        };
      }),
    };

    bool success = await QuizService.updateAssessment(widget.quizData['id'], updatedData);

    // FIXED: BuildContext guard after async gap
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    }
  }

  void _confirmDelete() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Permanently?"),
        content: const Text("This removes all records of this quiz from the database."),
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

    if (!mounted) return;
    if (result == "DELETE_SIGNAL") {
      bool success = await QuizService.deleteAssessment(widget.quizData['id']);
      // FIXED: BuildContext guard after async gap
      if (!mounted) return;
      if (success) Navigator.pop(context, "DELETE_SIGNAL");
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
        title: const Text("EDIT ASSESSMENT", style: TextStyle(color: stiNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(onPressed: _saveAllChanges, icon: const Icon(Icons.check_circle, color: Colors.green)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _editField("Title", _titleController, Icons.title),
          const SizedBox(height: 15),
          _editField("Duration (Mins)", _durationController, Icons.timer),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: _statusBtn("ARCHIVE", Colors.orange, Icons.archive_outlined, () => _updateStatus(0))),
              const SizedBox(width: 10),
              Expanded(child: _statusBtn("COMPLETE", Colors.blueGrey, Icons.assignment_turned_in_outlined, () => _updateStatus(2))),
            ],
          ),
          
          const Divider(height: 40),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) => _buildQuestionCard(index),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _addNewQuestion, 
            icon: const Icon(Icons.add), 
            label: const Text("ADD QUESTION"),
            style: OutlinedButton.styleFrom(foregroundColor: stiNavy),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: _confirmDelete, 
            icon: const Icon(Icons.delete_forever, color: Colors.red), 
            label: const Text("DELETE PERMANENTLY", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _statusBtn(String label, Color color, IconData icon, VoidCallback tap) {
    return ElevatedButton.icon(
      onPressed: tap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
    );
  }

  Widget _editField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: stiNavy),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    String selectedType = _questions[index]['type'];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05))
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedType,
                  items: _quizTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _questions[index]['type'] = val!),
                ),
                IconButton(onPressed: () => _removeQuestion(index), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
              ],
            ),
            TextField(controller: _questionControllers[index], decoration: const InputDecoration(hintText: "Enter Question")),
            if (selectedType == "Multiple Choice") ...[
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  mainAxisExtent: 50, 
                  crossAxisSpacing: 10, 
                  mainAxisSpacing: 10
                ),
                itemCount: 4,
                itemBuilder: (ctx, i) => TextField(
                  controller: _optionControllers[index][i], 
                  decoration: InputDecoration(hintText: "Choice ${String.fromCharCode(65 + i)}")
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(controller: _answerControllers[index], decoration: const InputDecoration(hintText: "Correct Answer")),
          ],
        ),
      ),
    );
  }
}