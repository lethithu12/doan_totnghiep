import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../models/review_model.dart';
import 'image_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService();
  final String _collection = 'reviews';

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Lấy danh sách đánh giá của một sản phẩm
  Stream<List<ReviewModel>> getReviews(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
   
    });
  }

  /// Lấy danh sách đánh giá của một sản phẩm (one-time)
  Future<List<ReviewModel>> getReviewsOnce(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw 'Lỗi khi lấy đánh giá: ${e.toString()}';
    }
  }

  /// Upload nhiều hình ảnh review
  Future<List<String>> uploadReviewImages(
    List<PlatformFile> imageFiles,
    String reviewId,
  ) async {
    try {
      final urls = <String>[];
      for (final imageFile in imageFiles) {
        final url = await _imageService.uploadImage(
          platformFile: imageFile,
          folder: 'reviews/$reviewId',
        );
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw 'Lỗi khi upload hình ảnh: ${e.toString()}';
    }
  }

  /// Tạo đánh giá mới
  Future<ReviewModel> createReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
    List<PlatformFile>? imageFiles,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập để đánh giá sản phẩm';
    }

    try {
      final now = DateTime.now();
      final tempReviewId = 'temp_${now.millisecondsSinceEpoch}';

      // Upload images if any
      List<String> imageUrls = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageUrls = await uploadReviewImages(imageFiles, tempReviewId);
      }

      // Create review
      final review = ReviewModel(
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore.collection(_collection).add(review.toMap());
      
      return review.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Lỗi khi tạo đánh giá: ${e.toString()}';
    }
  }

  /// Cập nhật phản hồi từ admin
  Future<void> updateAdminReply(String reviewId, String reply) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update({
        'adminReply': reply,
        'adminReplyAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật phản hồi: ${e.toString()}';
    }
  }

  /// Xóa phản hồi admin
  Future<void> deleteAdminReply(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update({
        'adminReply': null,
        'adminReplyAt': null,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi xóa phản hồi: ${e.toString()}';
    }
  }

  /// Xóa đánh giá (admin only)
  Future<void> deleteReview(String reviewId) async {
    try {
      // Delete images from storage
      final review = await getReviewById(reviewId);
      if (review != null && review.imageUrls.isNotEmpty) {
        for (final imageUrl in review.imageUrls) {
          try {
            await _imageService.deleteImage(imageUrl);
          } catch (e) {
            // Ignore errors when deleting images
          }
        }
      }

      // Delete review document
      await _firestore.collection(_collection).doc(reviewId).delete();
    } catch (e) {
      throw 'Lỗi khi xóa đánh giá: ${e.toString()}';
    }
  }

  /// Lấy một đánh giá theo ID
  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(reviewId).get();
      if (doc.exists) {
        return ReviewModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy đánh giá: ${e.toString()}';
    }
  }

  /// Lấy tất cả đánh giá (cho admin)
  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}

