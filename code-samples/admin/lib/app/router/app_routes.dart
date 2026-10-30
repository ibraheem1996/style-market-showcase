abstract final class AppRoutes {
  static const root = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const orders = '/orders';
  static const orderDetail = '/orders/:orderId';
  static const products = '/products';
  static const productCreate = '/products/create';
  static const productDetail = '/products/:productId';
  static const productMedia = '/products/:productId/media';
  static const productEdit = '/products/:productId/edit';
  static const productVariantCreate = '/products/:productId/variants/create';
  static const productVariantEdit =
      '/products/:productId/variants/:variantId/edit';
  static const categories = '/categories';
  static const categoryCreate = '/categories/create';
  static const categoryEdit = '/categories/:categoryId/edit';
  static const audiences = '/audiences';
  static const banners = '/banners';
  static const bannerCreate = '/banners/create';
  static const bannerEdit = '/banners/:bannerId/edit';
  static const collections = '/collections';
  static const collectionCreate = '/collections/create';
  static const collectionEdit = '/collections/:collectionId/edit';
  static const colors = '/colors';
  static const sizes = '/sizes';
  static const notifications = '/notifications';
  static const audienceCreate = '/audiences/create';
  static const audienceEdit = '/audiences/:audienceId/edit';
  static const forbidden = '/forbidden';
  static const authChecking = '/auth/checking';

  static String orderDetailPath(int orderId) => '/orders/$orderId';
  static String productCreatePath() => productCreate;
  static String productDetailPath(int productId) => '/products/$productId';
  static String productMediaPath(int productId) => '/products/$productId/media';
  static String productEditPath(int productId) => '/products/$productId/edit';
  static String productVariantCreatePath(int productId) =>
      '/products/$productId/variants/create';
  static String productVariantEditPath(int productId, int variantId) =>
      '/products/$productId/variants/$variantId/edit';
  static String categoryEditPath(int categoryId) =>
      '/categories/$categoryId/edit';
  static String audienceEditPath(int audienceId) =>
      '/audiences/$audienceId/edit';
  static String bannerEditPath(int bannerId) => '/banners/$bannerId/edit';
  static String collectionEditPath(int collectionId) =>
      '/collections/$collectionId/edit';
}
