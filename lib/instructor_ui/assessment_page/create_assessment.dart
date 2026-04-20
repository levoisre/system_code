import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';

class CreateAssessmentPage extends StatefulWidget {
  final String subjectCode; 
  
  const CreateAssessmentPage({super.key, required this.subjectCode});

  @override
  State<CreateAssessmentPage> createState() => _CreateAssessmentPageState();
}

class _CreateAssessmentPageState extends State<CreateAssessmentPage> {
  static const Color stiNavy = Color(0xFF0D125A);
  static const Color bgColor = Color(0xFFF1F5F9);

  final _titleController = TextEditingController();
  final _durationController = TextEditingController();

  final List<Map<String, dynamic>> _questions = [];
  final List<TextEditingController> _questionTextControllers = [];
  final List<TextEditingController> _answerTextControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];

  final List<String> _quizTypes = [
    "Identification",
    "True or False",
    "Multiple Choice",
    "Crossword",
  ];

  final Map<String, String> _typeMapper = {
    "Identification": "IDENTIFICATION",
    "True or False": "TF",
    "Multiple Choice": "MULTIPLE_CHOICE",
    "Crossword": "CROSSWORD",
  };

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    for (var c in _questionTextControllers) { c.dispose(); }
    for (var c in _answerTextControllers) { c.dispose(); }
    for (var list in _optionControllers) {
      for (var c in list) { c.dispose(); }
    }
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add({"type": "Identification"});
      _questionTextControllers.add(TextEditingController());
      _answerTextControllers.add(TextEditingController());
      _optionControllers.add(List.generate(4, (_) => TextEditingController()));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _questionTextControllers[index].dispose();
      _answerTextControllers[index].dispose();
      for (var c in _optionControllers[index]) { c.dispose(); }
      
      _questionTextControllers.removeAt(index);
      _answerTextControllers.removeAt(index);
      _optionControllers.removeAt(index);
    });
  }

  void _submitAssessment() async {
    if (_titleController.text.isEmpty || _durationController.text.isEmpty) {
      _showError("Please fill in the Title and Duration");
      return;
    }
    if (_questions.isEmpty) {
      _showError("Please add at least one question");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: stiNavy)),
    );

    // Format questions to match the Backend 'quiz_questions' table
    List<Map<String, dynamic>> formattedQuestions = List.generate(_questions.length, (i) {
      String uiType = _questions[i]['type'];
      return {
        "type": _typeMapper[uiType] ?? "IDENTIFICATION",
        "question_text": _questionTextControllers[i].text,
        "correct_answer": _answerTextControllers[i].text,
        "hint": "Assessment Item", 
        "metadata": uiType == "Multiple Choice"
            ? _optionControllers[i].map((c) => c.text).toList()
            : uiType == "Crossword"
                ? {"row": 0, "col": 0, "direction": "across"}
                : null,
      };
    });

    bool success = await QuizService.createAssessment(
      subjectCode: widget.subjectCode,
      title: _titleController.text.toUpperCase(),
      // Standardizing description for simpler duration parsing on student side
      description: "${_durationController.text}m", 
      questions: formattedQuestions,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✨ Assessment Created Successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); 
    } else {
      _showError("Failed to save to server. Check your backend connection.");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
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
        title: const Text("CREATE ASSESSMENT",
            style: TextStyle(color: stiNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 800 ? (constraints.maxWidth - 700) / 2 : 20;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel("ASSESSMENT DETAILS"),
                const SizedBox(height: 15),
                _buildFormCard(constraints.maxWidth > 600),
                const SizedBox(height: 30),
                _buildSectionLabel("QUESTION BUILDER (${_questions.length})"),
                const SizedBox(height: 15),
                _questions.isEmpty ? _buildEmptyPlaceholder() : _buildQuestionList(),
                const SizedBox(height: 40),
                _buildActionButtons(constraints.maxWidth > 600),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 11));

  Widget _buildFormCard(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: isWide ? Row(children: [
        Expanded(child: _inputField("Assessment Title", "e.g., Finals Quiz", _titleController, Icons.title)),
        const SizedBox(width: 20),
        SizedBox(width: 150, child: _inputField("Duration (Mins)", "30", _durationController, Icons.timer, isNumeric: true)),
      ]) : Column(children: [
        _inputField("Assessment Title", "e.g., Finals Quiz", _titleController, Icons.title),
        const SizedBox(height: 20),
        _inputField("Duration (Mins)", "30", _durationController, Icons.timer, isNumeric: true),
      ]),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: stiNavy, size: 20),
          hintText: hint,
          filled: true,
          fillColor: bgColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    ]);
  }

  Widget _buildQuestionList() {
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _questions.length,
        itemBuilder: (context, index) => _buildQuestionCard(index),
      ),
      const SizedBox(height: 15),
      TextButton.icon(
        onPressed: _addNewQuestion, 
        icon: const Icon(Icons.add_circle_outline), 
        label: const Text("ADD ANOTHER QUESTION"), 
        style: TextButton.styleFrom(foregroundColor: stiNavy, textStyle: const TextStyle(fontWeight: FontWeight.bold))
      ),
    ]);
  }

  Widget _buildQuestionCard(int index) {
    String selectedType = _questions[index]['type'];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          DropdownButton<String>(
            value: selectedType,
            underline: const SizedBox(),
            style: const TextStyle(color: stiNavy, fontWeight: FontWeight.bold),
            items: _quizTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) => setState(() => _questions[index]['type'] = val!),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _removeQuestion(index)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _questionTextControllers[index], 
          maxLines: null,
          decoration: const InputDecoration(hintText: "Enter your question here...", border: UnderlineInputBorder())
        ),
        const SizedBox(height: 20),
        if (selectedType == "Multiple Choice") ...[
          _buildOptionsGrid(index),
          const SizedBox(height: 20),
        ],
        if (selectedType == "True or False") 
          _buildTFChips(index)
        else 
          TextField(
            controller: _answerTextControllers[index], 
            decoration: InputDecoration(
              hintText: selectedType == "Crossword" ? "Word Answer" : "Correct Answer", 
              prefixIcon: const Icon(Icons.check_circle, color: Colors.green, size: 18),
              filled: true,
              fillColor: Colors.green.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)
            )
          ),
      ]),
    );
  }

  Widget _buildOptionsGrid(int qIndex) {
    return GridView.builder(
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
        controller: _optionControllers[qIndex][i],
        decoration: InputDecoration(
          hintText: "Option ${String.fromCharCode(65 + i)}", 
          filled: true, 
          fillColor: bgColor, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildTFChips(int index) {
    return Row(children: ["True", "False"].map((label) => Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: _answerTextControllers[index].text == label ? Colors.white : stiNavy)),
        selected: _answerTextControllers[index].text == label,
        selectedColor: stiNavy,
        onSelected: (val) => setState(() => _answerTextControllers[index].text = label),
      ),
    )).toList());
  }

  Widget _buildEmptyPlaceholder() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.post_add_rounded, size: 60, color: Colors.black12),
          const SizedBox(height: 15),
          const Text("No questions added yet.", style: TextStyle(color: Colors.black38)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _addNewQuestion, 
            style: ElevatedButton.styleFrom(backgroundColor: stiNavy, foregroundColor: Colors.white),
            child: const Text("ADD FIRST QUESTION"),
          ),
        ],
      ),
    )
  );

  Widget _buildActionButtons(bool isWide) {
    return Row(children: [
      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("DISCARD"))),
      const SizedBox(width: 15),
      Expanded(
        flex: 2, 
        child: ElevatedButton(
          onPressed: _submitAssessment, 
          style: ElevatedButton.styleFrom(backgroundColor: stiNavy, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)), 
          child: const Text("CREATE ASSESSMENT", style: TextStyle(fontWeight: FontWeight.bold))
        )
      ),
    ]);
  }
}