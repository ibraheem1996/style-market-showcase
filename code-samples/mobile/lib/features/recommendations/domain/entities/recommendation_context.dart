enum RecommendationContext {
  home('home'),
  productDetails('product_details'),
  favorites('favorites'),
  cart('cart');

  // afterAddToCart('after_add_to_cart'),
  // searchEmpty('search_empty'),
  // listingEmpty('listing_empty'),

  final String apiValue;
  const RecommendationContext(this.apiValue);
}
