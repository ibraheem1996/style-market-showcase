enum AdminProductSellMode { simple, variant }

enum AdminProductStockState { outOfStock, lowStock, inStock }

enum AdminProductStockSource { itemStock, variantStock }

enum AdminProductSort { newest, oldest, nameAsc, nameDesc, stockAsc, stockDesc }

enum AdminProductImageSource { item, color, size, variant, none }

enum AdminProductMediaScope { item, color, size, variant }

enum AdminProductMediaOperation { upload, delete, reorder, primary }

enum AdminProductImageStrategy {
  none,
  itemImages,
  colorImages,
  sizeImages,
  variantImages,
  mixed,
}

enum AdminProductVariantGrouping { none, flat, color, size, variant }

enum AdminProductVariantGroupType { color, size, all }

enum AdminProductVariantNoteCode {
  noImages,
  variantsUseItemImages,
  variantsUseColorImages,
  variantsUseSizeImages,
  variantsHaveOwnImages,
  variantsHaveMixedImages,
}
