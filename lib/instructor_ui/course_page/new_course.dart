import 'package:flutter/material.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  // 1. STATE VARIABLES FOR THE DROPDOWNS & INPUTS
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedClassList = "Select Class List";
  List<String> classListOptions = [
    "Select Class List",
    "BSIT - 301 (A)",
    "BSIT - 302 (A)",
    "BSCPE - 401"
  ];

  static const Color darkNavy = Color(0xFF0C1446);
  static const Color wireframeBg = Color(0xFFF0F0F0); // Light grey outer card

  void _handleCreateCourse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Course created! Use this for real thesis logic.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The screen has the light grey inner background shown in image
    return Scaffold(
      backgroundColor: wireframeBg,
      body: SafeArea(
        child: Center(
          // Inner card container matching the image structure
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // Limits width on web/large screens
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8), // Slightly different shade to differentiate from wireframeBg
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 2), // The outer black wireframe border
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. HEADER: BACK ARROW & TITLE (SERIF FONT) ---
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        'NEW COURSE',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'serif', // Match the serif font style from image
                        ),
                      ),
                      const Spacer(),
                      // Invisible block to center the title relative to the back arrow
                      const SizedBox(width: 48), 
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 2),
                  const SizedBox(height: 35),

                  // --- 3. FIRST ROW: Subject Name & Subject Code ---
                  Row(
                    children: [
                      _buildFormLabel("Subject Name:"),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInputBox(controller: _subjectNameController)),
                      const SizedBox(width: 25),
                      _buildFormLabel("Subject Code:"),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInputBox(controller: _subjectCodeController)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- 4. SECOND ROW: Class Schedule & Location ---
                  Row(
                    children: [
                      _buildFormLabel("Class Schedule:"),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Row(
                          children: [
                            // Fake drop-down representation for schedule
                            Expanded(child: _buildStaticInputBox("Time", isDropDown: true)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildStaticInputBox("Day", isDropDown: true)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 25),
                      _buildFormLabel("Location:"),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInputBox(controller: _locationController)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- 5. THIRD ROW: Upload Class List ---
                  Row(
                    children: [
                      _buildFormLabel("Upload Class List:"),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInteractiveDropDown()),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // --- 6. FOURTH ROW: Descriptions ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _buildFormLabel("Descriptions:"),
                      ),
                      const SizedBox(width: 15),
                      // Larger multi-line input box
                      Expanded(child: _buildInputBox(controller: _descriptionController, maxLines: 5)),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // --- 7. THE CREATE BUTTON ---
                  Center(
                    child: SizedBox(
                      width: 260, // Pill shaped but wide as in image
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleCreateCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkNavy,
                          // Rounded edges as shown in image
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 3,
                        ),
                        child: const Text(
                          'CREATE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInputBox({required TextEditingController controller, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // Static Box just to show the drop-down appearance from image
  Widget _buildStaticInputBox(String text, {bool isDropDown = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          if (isDropDown) const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
        ],
      ),
    );
  }

  Widget _buildInteractiveDropDown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClassList,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          onChanged: (String? newValue) {
            setState(() {
              selectedClassList = newValue!;
            });
          },
          items: classListOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: value == "Select Class List" ? Colors.black54 : Colors.black87)),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}