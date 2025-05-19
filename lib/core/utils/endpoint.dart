const String baseUrl = 'https://api.aurify.ae/user';
const String newBaseUrl = 'https://api.nova.aurify.ae/user';



// const String oldAdminId = '67586119baf55a80a8277f01';

const String adminId = '67f37dfe4831e0eb637d09f1';

const String loginUrl = '$newBaseUrl/login/$adminId';

// const String listProductUrl =
//     '$baseUrl/view-all/?page={index}/&adminId=$adminId';

const String getCartUrl = '$newBaseUrl/get-cart/{userId}';

// const String addToCartUrl = '$newBaseUrl/cart/$adminId/{userId}/{pId}';

const String deleteFromCartUrl = '$newBaseUrl/cart/$adminId/{userId}/{pId}';

const String incrementQuantityUrl =
    '$newBaseUrl/cart-increment/$adminId/{userId}/{pId}';

const String decrementQuantityUrl =
    '$newBaseUrl/cart-decrement/$adminId/{userId}/{pId}';

// const String getWishlistUrl = '$baseUrl/get-wishlist/{userId}';

// const String deleteFromWishlistUrl =
//     '$baseUrl/wishlist/$adminId/{userId}/{pId}';

// const String addToWishlistUrl =
//     '$baseUrl/wishlist/$adminId/{userId}/{pId}?action=add';

// const String changePasswordUrl = '$newBaseUrl/forgot-password/{userId}';

const String getServerUrl = '$baseUrl/get-server';

// const String getBannerUrl = '$baseUrl/get-banner/$adminId';

// const String commoditiesUrl = '$baseUrl/get-commodities/$adminId';

const String companyProfileUrl = '$newBaseUrl/get-profile/$adminId';

const String fixPriceUrl = '$newBaseUrl/products/fix-prices';

const String bookingUrl = '$newBaseUrl/booking/$adminId/{userId}';

const String changePassUrl = '$baseUrl/forgot-password/$adminId';

const String getVideoBannerUrl = 'https://api.aurify.ae/user/get-VideoBanner/67586119baf55a80a8277f01';

const String confirmQuantityUrl = '$newBaseUrl/order_quantity_confirmation';

const String getOrderHistoryUrl =
    '$newBaseUrl/fetch-order/$adminId/{userId}?page={index}&orderStatus={status}';

// const String getSpotRateUrl = 'https://api.aurify.ae/user/get-spotrates/67586119baf55a80a8277f01';

const String updateQuantityFromHomeUrl =
    '$baseUrl/cart/update-quantity/$adminId/{userId}/{pId}';
    
const String pricingUrl = '$baseUrl/pricing/latest/$adminId?methodType={type}';
