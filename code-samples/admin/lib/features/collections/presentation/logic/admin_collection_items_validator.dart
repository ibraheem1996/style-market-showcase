import '../../domain/entities/admin_collection_entities.dart';

class AdminCollectionItemsValidation {
  const AdminCollectionItemsValidation({
    required this.items,
    required this.errors,
  });

  final List<AdminCollectionItemWriteInput> items;
  final Map<int, Map<String, String>> errors;
}

AdminCollectionItemsValidation validateAdminCollectionItems({
  required List<AdminCollectionItemDraft> drafts,
}) {
  final errors = <int, Map<String, String>>{};
  final normalized = <AdminCollectionItemWriteInput>[];
  final seen = <int>{};

  for (var index = 0; index < drafts.length; index++) {
    final draft = drafts[index];
    final rowErrors = <String, String>{};
    final productId = int.tryParse(draft.productId.trim());
    final sortOrder = int.tryParse(draft.sortOrder.trim());

    if (productId == null || productId < 1) {
      rowErrors['productId'] = 'أدخل رقم منتج صحيحًا.';
    } else if (seen.contains(productId)) {
      rowErrors['productId'] = 'لا يمكن تكرار المنتج.';
    }

    if (sortOrder == null || sortOrder < 0) {
      rowErrors['sortOrder'] = 'الترتيب يجب أن يكون عددًا غير سالب.';
    }

    if (rowErrors.isEmpty) {
      seen.add(productId!);
      normalized.add(
        AdminCollectionItemWriteInput(
          productId: productId,
          sortOrder: sortOrder!,
        ),
      );
    } else {
      errors[index] = rowErrors;
    }
  }

  return AdminCollectionItemsValidation(items: normalized, errors: errors);
}

class AdminCollectionItemDraft {
  const AdminCollectionItemDraft({
    required this.productId,
    required this.sortOrder,
  });

  factory AdminCollectionItemDraft.fromItem(AdminCollectionItem item) {
    return AdminCollectionItemDraft(
      productId: '${item.productId}',
      sortOrder: '${item.sortOrder}',
    );
  }

  final String productId;
  final String sortOrder;

  AdminCollectionItemDraft copyWith({String? productId, String? sortOrder}) {
    return AdminCollectionItemDraft(
      productId: productId ?? this.productId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
