class LocalAnalysisEngine {
  String getAnswer(String question, List<List<dynamic>> data) {
    final questionInLowerCase = question.toLowerCase();

    if (questionInLowerCase.contains('eldest child')) {
      return _countEldestChildren(data);
    } else if (questionInLowerCase.contains('only son')) {
      return _countOnlySons(data);
    } else if (questionInLowerCase.contains('district') || questionInLowerCase.contains('native place')) {
      return _getDistrictDistribution(data);
    } else if (questionInLowerCase.contains('siblings') || questionInLowerCase.contains('brothers and sisters')) {
      return _getSiblingInfo(data);
    } else if (questionInLowerCase.contains('parents') && (questionInLowerCase.contains('alive') || questionInLowerCase.contains('deceased') || questionInLowerCase.contains('separated'))) {
      return _getParentStatus(data);
    } else if (questionInLowerCase.contains('occupation') && (questionInLowerCase.contains('father') || questionInLowerCase.contains('mother'))) {
      return _getParentOccupation(data);
    } else {
      return "I'm sorry, I can only answer predefined questions. Please select a question from the list or try rephrasing.";
    }
  }

  List<List<dynamic>> getFilteredData(String query, List<List<dynamic>> data) {
    final queryInLowerCase = query.toLowerCase();

    // --- Start of specific question handlers ---
    if (queryInLowerCase.contains('eldest child')) {
      return _getEldestChildren(data);
    }
    // --- End of specific question handlers ---

    // If no specific question matches, perform a generic search across all fields.
    if (data.length < 2 || query.trim().isEmpty) {
      // Not enough data to search or query is empty, return nothing.
      return [];
    }

    // Initialize with header rows
    final List<List<dynamic>> filteredData = [data[0], data[1]];

    // Iterate over data rows
    for (int i = 2; i < data.length; i++) {
      final row = data[i];
      bool rowContainsQuery = false;
      for (final cell in row) {
        if (cell != null && cell.toString().toLowerCase().contains(queryInLowerCase)) {
          rowContainsQuery = true;
          break; // Found match in this row, no need to check other cells
        }
      }
      if (rowContainsQuery) {
        filteredData.add(row);
      }
    }

    return filteredData;
  }

  String _countEldestChildren(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final elderIndex = headers.indexWhere((h) => h.toLowerCase().contains('eldest'));

    if (elderIndex == -1) {
      return "Could not find the 'Eldest' column in the data.";
    }

    int eldestCount = 0;
    for (int i = 2; i < data.length; i++) {
      if (data[i][elderIndex].toString().toLowerCase() == 'yes') {
        eldestCount++;
      }
    }
    return "There are $eldestCount students who are the eldest child in their family.";
  }

  List<List<dynamic>> _getEldestChildren(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final elderIndex = headers.indexWhere((h) => h.toLowerCase().contains('eldest'));

    if (elderIndex == -1) {
      return [];
    }

    final List<List<dynamic>> filteredData = [data[0], data[1]]; // Keep headers
    for (int i = 2; i < data.length; i++) {
      if (data[i][elderIndex].toString().toLowerCase() == 'yes') {
        filteredData.add(data[i]);
      }
    }
    return filteredData;
  }

  String _countOnlySons(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final genderIndex = headers.indexWhere((h) => h.toLowerCase().contains('gender'));
    final brothersIndex = headers.indexWhere((h) => h.toLowerCase().contains('no. of brothers'));

    if (genderIndex == -1 || brothersIndex == -1) {
      return "Could not find 'Gender' or 'No. of brothers' columns.";
    }

    int onlySonCount = 0;
    for (int i = 2; i < data.length; i++) {
      if (data[i][genderIndex].toString().toLowerCase() == 'male' && (data[i][brothersIndex] == 0 || data[i][brothersIndex] == null)) {
        onlySonCount++;
      }
    }
    return "There are $onlySonCount students who are the only son in their family.";
  }

  String _getDistrictDistribution(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final districtIndex = headers.indexWhere((h) => h.toLowerCase().contains('district'));

    if (districtIndex == -1) {
      return "Could not find the 'District' column in the data.";
    }

    final districtCounts = <String, int>{};
    for (int i = 2; i < data.length; i++) {
      final district = data[i][districtIndex].toString();
      if (district.isNotEmpty) {
        districtCounts[district] = (districtCounts[district] ?? 0) + 1;
      }
    }

    if (districtCounts.isEmpty) {
      return "No district information found.";
    }

    final distribution = districtCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return "The distribution of students by district is: $distribution";
  }

  String _getSiblingInfo(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final brothersIndex = headers.indexWhere((h) => h.toLowerCase().contains('no. of brothers'));
    final sistersIndex = headers.indexWhere((h) => h.toLowerCase().contains('no. of sisters'));

    if (brothersIndex == -1 || sistersIndex == -1) {
      return "Could not find 'No. of brothers' or 'No. of sisters' columns.";
    }

    int withSiblings = 0;
    int totalBrothers = 0;
    int totalSisters = 0;

    for (int i = 2; i < data.length; i++) {
      final brothers = data[i][brothersIndex] ?? 0;
      final sisters = data[i][sistersIndex] ?? 0;
      if (brothers > 0 || sisters > 0) {
        withSiblings++;
      }
      totalBrothers += (brothers is int) ? brothers : int.tryParse(brothers.toString()) ?? 0;
      totalSisters += (sisters is int) ? sisters : int.tryParse(sisters.toString()) ?? 0;
    }
    return "$withSiblings students have siblings. The total number of brothers is $totalBrothers and sisters is $totalSisters.";
  }

  String _getParentStatus(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final fatherStatusIndex = headers.indexWhere((h) => h.toLowerCase().contains('father status'));
    final motherStatusIndex = headers.indexWhere((h) => h.toLowerCase().contains('mother status'));

    if (fatherStatusIndex == -1 || motherStatusIndex == -1) {
      return "Could not find 'Father Status' or 'Mother Status' columns.";
    }

    final statusCounts = <String, int>{};
    for (int i = 2; i < data.length; i++) {
      final fatherStatus = data[i][fatherStatusIndex].toString().toLowerCase();
      final motherStatus = data[i][motherStatusIndex].toString().toLowerCase();
      if(fatherStatus.isNotEmpty) statusCounts[fatherStatus] = (statusCounts[fatherStatus] ?? 0) + 1;
      if(motherStatus.isNotEmpty) statusCounts[motherStatus] = (statusCounts[motherStatus] ?? 0) + 1;
    }

    final distribution = statusCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return "The status of parents is as follows: $distribution";
  }

  String _getParentOccupation(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final fatherOccIndex = headers.indexWhere((h) => h.toLowerCase().contains('father\'s occupation'));
    final motherOccIndex = headers.indexWhere((h) => h.toLowerCase().contains('mother\'s occupation'));

    if (fatherOccIndex == -1 || motherOccIndex == -1) {
      return "Could not find 'Father\'s Occupation' or 'Mother\'s Occupation' columns.";
    }

    final occupationCounts = <String, int>{};
    for (int i = 2; i < data.length; i++) {
      final fatherOcc = data[i][fatherOccIndex].toString();
      final motherOcc = data[i][motherOccIndex].toString();
      if(fatherOcc.isNotEmpty) occupationCounts[fatherOcc] = (occupationCounts[fatherOcc] ?? 0) + 1;
      if(motherOcc.isNotEmpty) occupationCounts[motherOcc] = (occupationCounts[motherOcc] ?? 0) + 1;
    }

    if (occupationCounts.isEmpty) {
      return "No occupation information found.";
    }

    final mostCommon = occupationCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return "The most common occupation for parents is ${mostCommon.key} with ${mostCommon.value} parents.";
  }
}
