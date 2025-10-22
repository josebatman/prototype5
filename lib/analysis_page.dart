
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  final List<List<dynamic>>? excelData;

  const AnalysisPage({super.key, this.excelData});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String? _selectedCategory;
  final _searchController = TextEditingController();
  List<String> _suggestions = [];
  String _answer = 'The answer to your question will appear here.';

  final Map<String, List<String>> _questions = {
    'Family and Personal Details': [
      'How many students are the eldest child in their family?',
      'How many students are the only son in their family?',
      'What is the distribution of students by district or native place?',
      'How many students have siblings, and how many brothers and sisters do they have?',
      'How many students have parents who are alive, deceased, or separated?',
      'What is the most common occupation of fathers and mothers?',
      'How many students belong to each parish or diocese?',
      'How many students have received sacraments like Holy Communion and Confirmation?',
    ],
    'Academic Information': [
      'How many students are in each class, section, and academic year?',
      'How many students have been promoted or discontinued?',
      'What are the performance patterns (quarterly, half yearly, annual exam results)?',
      'How many students attend English medium schools vs. others?',
    ],
    'Contact and Location': [
      'How many students reside in different villages, towns, or districts?',
      'What is the distribution of students by postal code or area?',
    ],
    'Hobbies and Interests': [
      'What are the popular hobbies or extracurricular interests among the students?',
      'How many students participate in music, sports, arts, or other activities?',
    ],
    'Financial and Fees Information': [
      'How many students have paid tuition and boarding fees fully or partially?',
      'How many students have been recommended for concession or fee waiver?',
    ],
    'Other Miscellaneous Questions': [
      'How many students belong to various religious denominations or follow specific churches?',
      'What is the gender distribution if available or inferred by names/pronouns?',
      'How many students have disciplinary actions noted?',
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_selectedCategory != null && _searchController.text.isNotEmpty) {
        _suggestions = _questions[_selectedCategory]!
            .where((question) =>
                question.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      } else {
        _suggestions = [];
      }
    });
  }

  void _getAnswer() {
    // In the future, we will implement the logic to get the real answer here.
    setState(() {
      _answer = 'Fetching answer for: "${_searchController.text}"';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Analysis'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select a category'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  _onSearchChanged();
                });
              },
              items: _questions.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            if (_suggestions.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestions[index]),
                      onTap: () {
                        _searchController.text = _suggestions[index];
                        setState(() {
                          _suggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _getAnswer,
                  child: const Text('Ask'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Text(
                _answer,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Analysis Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: (widget.excelData != null)
                  ? _buildDataTable(widget.excelData!)
                  : const Center(child: Text('No data to display.')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<List<dynamic>> excelData) {
    if (excelData.length < 2) {
      return const Center(child: Text('Insufficient data to display.'));
    }

    final originalHeaders = excelData[1];
    final originalDataRows = excelData.sublist(2);

    final List<int> columnsToRemove = [];
    for (int i = 0; i < originalHeaders.length; i++) {
      final headerValue = originalHeaders[i];
      if (headerValue == null || headerValue.toString().trim().isEmpty) {
        columnsToRemove.add(i);
      }
    }

    final List<String> headers = [];
    for (int i = 0; i < originalHeaders.length; i++) {
      if (!columnsToRemove.contains(i)) {
        headers.add(originalHeaders[i].toString());
      }
    }

    final List<List<dynamic>> dataRows = originalDataRows.map((row) {
      final List<dynamic> newRow = [];
      final extendedRow = List.from(row);
      if (extendedRow.length < originalHeaders.length) {
        extendedRow.addAll(List.filled(originalHeaders.length - extendedRow.length, null));
      }

      for (int i = 0; i < extendedRow.length; i++) {
        if (!columnsToRemove.contains(i)) {
          newRow.add(extendedRow[i]);
        }
      }
      return newRow;
    }).toList();

    final academicDetailsStart = headers.indexOf('Academic Year');
    final financialDetailsStart = headers.indexOf('Tuition Fees');
    final generalRemarksStart = headers.indexOf('Remarks by Administrator') + 1;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20.0,
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
          columns: [
            for (var i = 0; i < headers.length; i++)
              DataColumn(
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: () {
                        if (i == 0) {
                          return const Text('Personal Profile',
                              style: TextStyle(fontWeight: FontWeight.bold));
                        }
                        if (i == academicDetailsStart && academicDetailsStart != -1) {
                          return const Text('Academic Details',
                              style: TextStyle(fontWeight: FontWeight.bold));
                        }
                        if (i == financialDetailsStart && financialDetailsStart != -1) {
                          return const Text('Financial Details',
                              style: TextStyle(fontWeight: FontWeight.bold));
                        }
                        if (i == generalRemarksStart && generalRemarksStart > 0) {
                          return const Text('General Remarks',
                              style: TextStyle(fontWeight: FontWeight.bold));
                        }
                        return const SizedBox.shrink();
                      }(),
                    ),
                    const SizedBox(height: 8.0),
                    Text(headers[i]),
                  ],
                ),
              ),
          ],
          rows: dataRows.map((row) {
            final cells = List<DataCell>.generate(headers.length, (index) {
              final cellValue = (index < row.length) ? row[index]?.toString() ?? '' : '';
              return DataCell(Text(cellValue));
            });
            return DataRow(cells: cells);
          }).toList(),
        ),
      ),
    );
  }
}
