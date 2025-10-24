class LocalAnalysisEngine {
  String getAnswer(String question, List<List<dynamic>> data) {
    final questionInLowerCase = question.toLowerCase();

    if (questionInLowerCase.contains('eldest child')) {
      return _getEldestChildrenNames(data);
    } else if (questionInLowerCase.contains('only son')) {
      return _getOnlySonsNames(data);
    } else if (questionInLowerCase.contains('district') || questionInLowerCase.contains('native place')) {
      return _getDistrictDistribution(data);
    } else if (questionInLowerCase.contains('siblings') || questionInLowerCase.contains('brothers and sisters')) {
      return _getStudentsWithSiblingsNames(data);
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

    if (data.length < 2 || query.trim().isEmpty) {
      return [];
    }

    final List<List<dynamic>> filteredData = [data[0], data[1]];

    for (int i = 2; i < data.length; i++) {
      final row = data[i];
      bool rowContainsQuery = false;
      for (final cell in row) {
        if (cell != null && cell.toString().toLowerCase().contains(queryInLowerCase)) {
          rowContainsQuery = true;
          break;
        }
      }
      if (rowContainsQuery) {
        filteredData.add(row);
      }
    }

    return filteredData;
  }

  String _getEldestChildrenNames(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString().toLowerCase().trim()).toList();
    final elderIndex = headers.indexWhere((h) => h == 'are you the eldest?');
    final nameIndex = headers.indexWhere((h) => h == 'name');

    if (elderIndex == -1 || nameIndex == -1) {
      return "Could not find the required columns ('Are you the Eldest?', 'Name'). Please check your file.";
    }

    List<String> eldestChildrenNames = [];
    for (int i = 2; i < data.length; i++) {
      if (data[i][elderIndex].toString().toLowerCase() == 'yes') {
        eldestChildrenNames.add(data[i][nameIndex].toString());
      }
    }
    if (eldestChildrenNames.isEmpty) {
        return "No students are the eldest child in their family.";
    }
    return "The following students are the eldest child: ${eldestChildrenNames.join(', ')}.";
  }

  String _getOnlySonsNames(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString().toLowerCase().trim()).toList();
    final onlySonIndex = headers.indexWhere((h) => h == 'are you the only son?');
    final nameIndex = headers.indexWhere((h) => h == 'name');

    if (onlySonIndex == -1 || nameIndex == -1) {
      return "Could not find 'Are you the only Son?' or 'Name' columns.";
    }

    List<String> onlySonsNames = [];
    for (int i = 2; i < data.length; i++) {
      if (data[i][onlySonIndex].toString().toLowerCase() == 'yes') {
        onlySonsNames.add(data[i][nameIndex].toString());
      }
    }

     if (onlySonsNames.isEmpty) {
        return "No students are the only son in their family.";
    }
    return "The following students are the only son in their family: ${onlySonsNames.join(', ')}.";
  }

  String _getDistrictDistribution(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final districtIndex = headers.indexWhere((h) => h.contains('district'));

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

  String _getStudentsWithSiblingsNames(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final brothersIndex = headers.indexWhere((h) => h.contains('no. of brothers'));
    final sistersIndex = headers.indexWhere((h) => h.contains('no. of sisters'));
    final nameIndex = headers.indexWhere((h) => h == 'name');

    if (brothersIndex == -1 || sistersIndex == -1 || nameIndex == -1) {
      return "Could not find 'No. of brothers', 'No. of sisters' or 'Name' columns.";
    }

    List<String> studentsWithSiblings = [];
    for (int i = 2; i < data.length; i++) {
      final brothers = data[i][brothersIndex] ?? 0;
      final sisters = data[i][sistersIndex] ?? 0;
      if (brothers > 0 || sisters > 0) {
        studentsWithSiblings.add(data[i][nameIndex].toString());
      }
    }
     if (studentsWithSiblings.isEmpty) {
        return "No students have siblings.";
    }
    return "The following students have siblings: ${studentsWithSiblings.join(', ')}.";
  }

  String _getParentStatus(List<List<dynamic>> data) {
    final headers = data[1].map((e) => e.toString()).toList();
    final fatherStatusIndex = headers.indexWhere((h) => h.contains('father status'));
    final motherStatusIndex = headers.indexWhere((h) => h.contains('mother status'));

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
    final fatherOccIndex = headers.indexWhere((h) => h.contains('father\'s occupation'));
    final motherOccIndex = headers.indexWhere((h) => h.contains('mother\'s occupation'));

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
