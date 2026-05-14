import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learning_module_model.dart';

class ModuleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Unified with CourseService to avoid split collection issues
  static const _col = 'modules';

  /// Stream all modules ordered by creation date (newest first)
  Stream<List<LearningModule>> getModulesStream() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LearningModule.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Create a new module document
  Future<void> createModule(LearningModule module) async {
    await _db.collection(_col).add(module.toMap());
  }

  /// Delete a module by its document ID
  Future<void> deleteModule(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  /// Update an existing module
  Future<void> updateModule(String id, Map<String, dynamic> data) async {
    await _db.collection(_col).doc(id).update(data);
  }
}
