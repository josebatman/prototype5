import 'package:flutter/material.dart';

class FilteredDataPage extends StatelessWidget {
  final List<List<dynamic>> filteredData;

  const FilteredDataPage({super.key, required this.filteredData});

  @override
  Widget build(BuildContext context) {
    final headers = filteredData.length > 1 ? filteredData[1] : [];
    final rawStudentData = filteredData.length > 2 ? filteredData.sublist(2) : [];

    final studentData = rawStudentData.where((row) {
      return row.any((cell) => cell != null && cell.toString().trim().isNotEmpty);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Student Data'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: studentData.isEmpty
          ? const Center(
              child: Text(
                'No matching student data found.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: studentData.length,
              itemBuilder: (context, index) {
                final student = studentData[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(headers.length, (i) {
                        final headerValue = headers.length > i && headers[i] != null ? headers[i].toString() : '';
                        final cellValue = (student.length > i && student[i] != null && student[i].toString().trim().isNotEmpty)
                            ? student[i].toString()
                            : 'N/A';

                        if (headerValue.trim().isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  headerValue,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  cellValue,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
