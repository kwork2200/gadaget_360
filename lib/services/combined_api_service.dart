import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// //
// // // ─── Models (unchanged) ───────────────────────────────────────────────────────
// //
// // class CombinedProduct {
// //   final String name;
// //   final String brand;
// //   final List<String> images;
// //   final List<PriceInfo> price;
// //   final Map<String, dynamic> specs;
// //   final List<Variant> variants;
// //   final List<String> sourceLinks;
// //
// //   const CombinedProduct({
// //     required this.name,
// //     required this.brand,
// //     required this.images,
// //     required this.price,
// //     required this.specs,
// //     required this.variants,
// //     required this.sourceLinks,
// //   });
// // }
// //
// // class PriceInfo {
// //   final String title;
// //   final String price;
// //   final String link;
// //   const PriceInfo({required this.title, required this.price, required this.link});
// // }
// //
// // class Variant {
// //   final String name;
// //   final String? price;
// //   final String? storage;
// //   final String? color;
// //   const Variant({required this.name, this.price, this.storage, this.color});
// // }
// //
// // // ─── Service ──────────────────────────────────────────────────────────────────
// //
// // class CombinedApiService {
// //   static const String _apiKey = 'AIzaSyDyBKkBIMhihhmIeHIxjVDUQNNHHQDjgJo'; // ← paste here
// //   static const String _baseUrl =
// //       'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';
// //
// //   // ─── Core API caller ──────────────────────────────────────────────────────
// //
// //   static Future<Map<String, dynamic>> _callGemini(String prompt, {int retry = 0}) async {
// //     final uri = Uri.parse('$_baseUrl?key=$_apiKey');
// //
// //     final body = {
// //       'contents': [
// //         {
// //           'parts': [
// //             {
// //               'text':
// //               'You are a gadget database for the Indian market. '
// //                   'You have deep knowledge of all smartphones and electronics sold in India. '
// //                   'ALWAYS respond with ONLY a valid JSON object. '
// //                   'No markdown fences, no explanation text, just pure JSON.\n\n$prompt'
// //             }
// //           ]
// //         }
// //       ],
// //       'generationConfig': {
// //         'temperature': 0.1,
// //         'maxOutputTokens': 2000,
// //       },
// //     };
// //
// //     debugPrint('→ Gemini API call…');
// //
// //     final response = await http
// //         .post(
// //       Uri.parse('$_baseUrl?key=$_apiKey'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(body),
// //     )
// //         .timeout(const Duration(seconds: 25));
// //
// //     debugPrint('← HTTP ${response.statusCode}');
// //
// //     if (response.statusCode == 429) {
// //       if (retry < 2) {
// //         debugPrint('Rate limited, waiting 5s before retry ${retry + 1}...');
// //         await Future.delayed(const Duration(seconds: 5));
// //         return _callGemini(prompt, retry: retry + 1);
// //       }
// //       throw Exception('Rate limit exceeded. Please wait a moment and try again.');
// //     }
// //
// //     if (response.statusCode != 200) {
// //       debugPrint('API error: ${response.body}');
// //       throw Exception('API error ${response.statusCode}: ${response.body}');
// //     }
// //
// //     final data = jsonDecode(response.body) as Map<String, dynamic>;
// //
// //     // Extract text from Gemini response format
// //     final candidates = data['candidates'] as List? ?? [];
// //     if (candidates.isEmpty) throw Exception('No candidates in response');
// //
// //     final content = candidates[0]['content'] as Map<String, dynamic>? ?? {};
// //     final parts = content['parts'] as List? ?? [];
// //     if (parts.isEmpty) throw Exception('No parts in response');
// //
// //     final rawText = parts[0]['text'] as String? ?? '';
// //     if (rawText.trim().isEmpty) throw Exception('Empty response from Gemini');
// //
// //     debugPrint('Raw response: $rawText');
// //     return _parseJson(rawText);
// //   }
// //
// //   static Map<String, dynamic> _parseJson(String raw) {
// //     final cleaned = raw
// //         .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
// //         .replaceAll(RegExp(r'```\s*', multiLine: true), '')
// //         .trim();
// //
// //     final start = cleaned.indexOf('{');
// //     final end = cleaned.lastIndexOf('}');
// //     if (start == -1 || end == -1 || end <= start) {
// //       throw FormatException('No JSON object found. Raw: $cleaned');
// //     }
// //
// //     return jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
// //   }
// //
// //   // ─── Search Products ──────────────────────────────────────────────────────
// //
// //   static Future<List<CombinedProduct>> searchProducts(String query) async {
// //     final isBrand = _isBrandQuery(query);
// //     final cleanQuery = query.trim();
// //     final prompt = isBrand
// //         ? _brandSearchPrompt(cleanQuery)
// //         : _modelSearchPrompt(cleanQuery);
// //
// //     final result = await _callGemini(prompt);
// //     final products = result['products'] as List? ?? [];
// //
// //     if (products.isEmpty) throw Exception('No products returned for "$query"');
// //
// //     return products
// //         .where((item) => (item['name'] as String?)?.isNotEmpty == true)
// //         .map((item) {
// //       final name  = item['name']  as String? ?? cleanQuery;
// //       final brand = item['brand'] as String? ?? _brandFromName(cleanQuery);
// //       final price = item['price'] as String? ?? '';
// //
// //       return CombinedProduct(
// //         name: name,
// //         brand: brand,
// //         images: _placeholderImages(),
// //         price: price.isNotEmpty
// //             ? [PriceInfo(title: name, price: price, link: '')]
// //             : [],
// //         specs: {
// //           'segment':     item['segment']?.toString()     ?? '',
// //           'launch_year': item['launch_year']?.toString() ?? '',
// //         },
// //         variants: [],
// //         sourceLinks: [],
// //       );
// //     }).toList();
// //   }
// //
// //   static String _brandSearchPrompt(String brand) => '''
// // List 8 real smartphones from the brand "$brand" sold in India.
// // Include budget, mid-range and flagship models across different years.
// // Return ONLY this JSON:
// // {
// //   "products": [
// //     {
// //       "name": "full model name e.g. Samsung Galaxy S24",
// //       "brand": "$brand",
// //       "price": "starting price e.g. ₹22,990",
// //       "segment": "Budget or Mid-range or Flagship",
// //       "launch_year": "e.g. 2024"
// //     }
// //   ]
// // }''';
// //
// //   static String _modelSearchPrompt(String query) => '''
// // Find 6 real smartphones or gadgets available in India matching: "$query".
// // Include the exact model if it exists, plus close variants and alternatives.
// // Return ONLY this JSON:
// // {
// //   "products": [
// //     {
// //       "name": "full model name",
// //       "brand": "manufacturer",
// //       "price": "Indian price e.g. ₹15,999",
// //       "segment": "Budget or Mid-range or Flagship",
// //       "launch_year": "e.g. 2024"
// //     }
// //   ]
// // }''';
// //
// //   // ─── Fetch Product Detail ─────────────────────────────────────────────────
// //
// //   static Future<CombinedProduct> fetchProductData(String query) async {
// //     final prompt = '''
// // Provide accurate specifications for the smartphone/gadget: "$query"
// // Return ONLY this JSON object:
// // {
// //   "name": "full official product name",
// //   "brand": "manufacturer",
// //   "display": "e.g. 6.41-inch Super AMOLED FHD+",
// //   "processor": "chipset name",
// //   "ram": "e.g. 8GB",
// //   "storage": "e.g. 128GB",
// //   "battery": "e.g. 5000mAh 33W fast charging",
// //   "rear_camera": "e.g. 50MP + 8MP + 2MP",
// //   "front_camera": "e.g. 16MP",
// //   "os": "e.g. Android 14",
// //   "network": "e.g. 5G, Wi-Fi 6, BT 5.3",
// //   "dimensions": "e.g. 163.3 x 74.5 x 8.1mm, 189g",
// //   "colors": "e.g. Black, White, Green",
// //   "description": "2-3 sentence product description",
// //   "prices": [
// //     {"store": "Flipkart", "price": "₹XX,XXX", "link": "https://flipkart.com"},
// //     {"store": "Amazon",   "price": "₹XX,XXX", "link": "https://amazon.in"},
// //     {"store": "Croma",    "price": "₹XX,XXX", "link": "https://croma.com"}
// //   ]
// // }''';
// //
// //     final result = await _callGemini(prompt);
// //     final brand = result['brand'] as String? ?? _brandFromName(query);
// //
// //     final rawPrices = result['prices'] as List? ?? [];
// //     final prices = rawPrices
// //         .where((p) => (p['price'] as String?)?.isNotEmpty == true)
// //         .map((p) => PriceInfo(
// //       title: '${result['name'] ?? query} on ${p['store']}',
// //       price: p['price'] as String? ?? '',
// //       link: p['link'] as String? ?? '',
// //     ))
// //         .toList();
// //
// //     return CombinedProduct(
// //       name: result['name'] as String? ?? query,
// //       brand: brand,
// //       images: _placeholderImages(),
// //       price: prices,
// //       specs: {
// //         'display':      result['display']      ?? '',
// //         'processor':    result['processor']    ?? '',
// //         'ram':          result['ram']          ?? '',
// //         'storage':      result['storage']      ?? '',
// //         'battery':      result['battery']      ?? '',
// //         'rear_camera':  result['rear_camera']  ?? '',
// //         'front_camera': result['front_camera'] ?? '',
// //         'os':           result['os']           ?? '',
// //         'network':      result['network']      ?? '',
// //         'dimensions':   result['dimensions']   ?? '',
// //         'colors':       result['colors']       ?? '',
// //         'description':  result['description']  ?? '',
// //       },
// //       variants: [],
// //       sourceLinks: [],
// //     );
// //   }
// //
// //   // ─── Helpers ──────────────────────────────────────────────────────────────
// //
// //   static bool _isBrandQuery(String query) {
// //     final q = query.toLowerCase().trim();
// //     return _knownBrands.any(
// //           (b) => q == b.toLowerCase() || q == '${b.toLowerCase()} phones',
// //     );
// //   }
// //
// //   static String _brandFromName(String name) {
// //     for (final brand in _knownBrands) {
// //       if (name.toLowerCase().contains(brand.toLowerCase())) return brand;
// //     }
// //     return '';
// //   }
// //
// //   static const List<String> _knownBrands = [
// //     'Samsung', 'Apple', 'Xiaomi', 'Redmi', 'POCO', 'OnePlus', 'Oppo',
// //     'Vivo', 'iQOO', 'Realme', 'Motorola', 'Nokia', 'Sony', 'LG',
// //     'Huawei', 'Asus', 'ROG', 'Nothing', 'Infinix', 'Tecno', 'Honor',
// //     'Google', 'HMD', 'Lava', 'Micromax',
// //   ];
// //
// //   static List<String> _placeholderImages() => [
// //     'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
// //     'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
// //     'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
// //   ];
// // }
// import 'package:flutter/foundation.dart';
//
// // ─── Models ───────────────────────────────────────────────────────────────────
//
// class CombinedProduct {
//   final String name;
//   final String brand;
//   final List<String> images;
//   final List<PriceInfo> price;
//   final Map<String, dynamic> specs;
//   final List<Variant> variants;
//   final List<String> sourceLinks;
//
//   const CombinedProduct({
//     required this.name,
//     required this.brand,
//     required this.images,
//     required this.price,
//     required this.specs,
//     required this.variants,
//     required this.sourceLinks,
//   });
// }
//
// class PriceInfo {
//   final String title;
//   final String price;
//   final String link;
//
//   const PriceInfo({
//     required this.title,
//     required this.price,
//     required this.link,
//   });
// }
//
// class Variant {
//   final String name;
//   final String? price;
//   final String? storage;
//   final String? color;
//
//   const Variant({
//     required this.name,
//     this.price,
//     this.storage,
//     this.color,
//   });
// }
//
// // ─── Service ──────────────────────────────────────────────────────────────────
//
// class CombinedApiService {
//   // ─── Search Products ──────────────────────────────────────────────────────
//
//   static Future<List<CombinedProduct>> searchProducts(String query) async {
//     // Simulate slight delay for UX feel
//     await Future.delayed(const Duration(milliseconds: 300));
//
//     final q = query.toLowerCase().trim();
//
//     final results = _allProducts.where((p) {
//       final nameLower = p.name.toLowerCase();
//       final brandLower = p.brand.toLowerCase();
//       return nameLower.contains(q) || brandLower.contains(q);
//     }).toList();
//
//     debugPrint('Search "$query" → ${results.length} results');
//     return results;
//   }
//
//   // ─── Fetch Product Detail ─────────────────────────────────────────────────
//
//   static Future<CombinedProduct> fetchProductData(String productName) async {
//     await Future.delayed(const Duration(milliseconds: 200));
//
//     final nameLower = productName.toLowerCase();
//
//     // Try exact match first
//     CombinedProduct? found;
//     for (final p in _allProducts) {
//       if (p.name.toLowerCase() == nameLower) {
//         found = p;
//         break;
//       }
//     }
//
//     // Fallback: partial match
//     found ??= _allProducts.firstWhere(
//           (p) => p.name.toLowerCase().contains(nameLower) ||
//           nameLower.contains(p.name.toLowerCase()),
//       orElse: () => _allProducts.first,
//     );
//
//     return found;
//   }
//
//   // ─── Local Product Database ───────────────────────────────────────────────
//
//   static final List<CombinedProduct> _allProducts = [
//     // ── Samsung ──────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Samsung Galaxy S24 Ultra',
//       brand: 'Samsung',
//       images: [
//         'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&q=80',
//         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Samsung Galaxy S24 Ultra on Flipkart', price: '₹1,29,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Samsung Galaxy S24 Ultra on Amazon', price: '₹1,31,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.8" QHD+ Dynamic AMOLED 2X, 120Hz',
//         'processor': 'Snapdragon 8 Gen 3',
//         'ram': '12GB',
//         'storage': '256GB / 512GB / 1TB',
//         'battery': '5000mAh, 45W Fast Charging',
//         'rear_camera': '200MP + 12MP + 10MP + 10MP',
//         'front_camera': '12MP',
//         'os': 'Android 14, One UI 6.1',
//         'network': '5G, Wi-Fi 7, BT 5.3',
//         'dimensions': '162.3 x 79 x 8.6mm, 232g',
//         'colors': 'Titanium Black, Gray, Violet, Yellow',
//         'description':
//         'The Samsung Galaxy S24 Ultra is the ultimate flagship with a built-in S Pen, 200MP camera, and Snapdragon 8 Gen 3 chipset. It offers unmatched productivity and photography with 100x Space Zoom and AI-powered features via Galaxy AI.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Samsung Galaxy S24+',
//       brand: 'Samsung',
//       images: [
//         'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Samsung Galaxy S24+ on Flipkart', price: '₹99,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Samsung Galaxy S24+ on Amazon', price: '₹1,01,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" QHD+ Dynamic AMOLED 2X, 120Hz',
//         'processor': 'Snapdragon 8 Gen 3',
//         'ram': '12GB',
//         'storage': '256GB / 512GB',
//         'battery': '4900mAh, 45W Fast Charging',
//         'rear_camera': '50MP + 12MP + 10MP',
//         'front_camera': '12MP',
//         'os': 'Android 14, One UI 6.1',
//         'network': '5G, Wi-Fi 7, BT 5.3',
//         'dimensions': '158.5 x 75.9 x 7.7mm, 196g',
//         'colors': 'Cobalt Violet, Onyx Black, Marble Gray',
//         'description':
//         'The Samsung Galaxy S24+ delivers flagship performance with a large 6.7-inch display, Snapdragon 8 Gen 3 processor, and Galaxy AI features. It includes a 50MP triple camera system and supports 45W fast charging.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Samsung Galaxy S24',
//       brand: 'Samsung',
//       images: [
//         'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Samsung Galaxy S24 on Flipkart', price: '₹79,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Samsung Galaxy S24 on Amazon', price: '₹81,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.2" FHD+ Dynamic AMOLED 2X, 120Hz',
//         'processor': 'Snapdragon 8 Gen 3',
//         'ram': '8GB',
//         'storage': '128GB / 256GB',
//         'battery': '4000mAh, 25W Fast Charging',
//         'rear_camera': '50MP + 12MP + 10MP',
//         'front_camera': '12MP',
//         'os': 'Android 14, One UI 6.1',
//         'network': '5G, Wi-Fi 7, BT 5.3',
//         'dimensions': '147 x 70.6 x 7.6mm, 167g',
//         'colors': 'Cobalt Violet, Onyx Black, Marble Gray, Amber Yellow',
//         'description':
//         'The Samsung Galaxy S24 is a compact flagship with the powerful Snapdragon 8 Gen 3, Galaxy AI features, and a bright FHD+ AMOLED display. Its slim and light design makes it ideal for one-handed use.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Samsung Galaxy A55',
//       brand: 'Samsung',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Samsung Galaxy A55 on Flipkart', price: '₹38,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Samsung Galaxy A55 on Amazon', price: '₹39,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.6" FHD+ Super AMOLED, 120Hz',
//         'processor': 'Exynos 1480',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '5000mAh, 25W Fast Charging',
//         'rear_camera': '50MP + 12MP + 5MP',
//         'front_camera': '32MP',
//         'os': 'Android 14, One UI 6.1',
//         'network': '5G, Wi-Fi 6, BT 5.3',
//         'dimensions': '161.1 x 77.4 x 8.2mm, 213g',
//         'colors': 'Awesome Iceblue, Lilac, Navy',
//         'description':
//         'The Samsung Galaxy A55 brings flagship-inspired design to the mid-range with an Exynos 1480 chip, 50MP OIS camera, and IP67 water resistance. It features a premium metal frame and 4 years of OS updates.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Samsung Galaxy M35',
//       brand: 'Samsung',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Samsung Galaxy M35 on Flipkart', price: '₹19,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Samsung Galaxy M35 on Amazon', price: '₹20,499', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" FHD+ Super AMOLED, 120Hz',
//         'processor': 'Exynos 1380',
//         'ram': '6GB / 8GB',
//         'storage': '128GB',
//         'battery': '6000mAh, 25W Fast Charging',
//         'rear_camera': '50MP + 8MP + 2MP',
//         'front_camera': '13MP',
//         'os': 'Android 14, One UI 6.1',
//         'network': '5G, Wi-Fi 6, BT 5.3',
//         'dimensions': '162.3 x 78.6 x 9.4mm, 214g',
//         'colors': 'Thunder Grey, Sky Blue, Dusty Orange',
//         'description':
//         'The Samsung Galaxy M35 is a battery powerhouse with a 6000mAh cell and 120Hz Super AMOLED display. It features the Exynos 1380 processor and a 50MP main camera, making it a great value mid-ranger.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Apple ─────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Apple iPhone 16 Pro Max',
//       brand: 'Apple',
//       images: [
//         'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'iPhone 16 Pro Max on Flipkart', price: '₹1,59,900', link: 'https://flipkart.com'),
//         PriceInfo(title: 'iPhone 16 Pro Max on Amazon', price: '₹1,61,900', link: 'https://amazon.in'),
//         PriceInfo(title: 'iPhone 16 Pro Max on Croma', price: '₹1,59,900', link: 'https://croma.com'),
//       ],
//       specs: {
//         'display': '6.9" Super Retina XDR OLED, 120Hz ProMotion',
//         'processor': 'Apple A18 Pro',
//         'ram': '8GB',
//         'storage': '256GB / 512GB / 1TB',
//         'battery': '4685mAh, 27W Wired, 25W MagSafe',
//         'rear_camera': '48MP Fusion + 48MP Ultra Wide + 12MP 5x Tetraprism',
//         'front_camera': '12MP TrueDepth',
//         'os': 'iOS 18',
//         'network': '5G, Wi-Fi 7, BT 5.3',
//         'dimensions': '163 x 77.6 x 8.25mm, 227g',
//         'colors': 'Black Titanium, White Titanium, Natural Titanium, Desert Titanium',
//         'description':
//         'The iPhone 16 Pro Max is Apple\'s most advanced smartphone featuring the A18 Pro chip, Camera Control button, and 4K 120fps video recording. It introduces Apple Intelligence AI features and supports the new USB-C with USB 3 speeds.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Apple iPhone 16',
//       brand: 'Apple',
//       images: [
//         'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'iPhone 16 on Flipkart', price: '₹79,900', link: 'https://flipkart.com'),
//         PriceInfo(title: 'iPhone 16 on Amazon', price: '₹81,900', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.1" Super Retina XDR OLED, 60Hz',
//         'processor': 'Apple A18',
//         'ram': '8GB',
//         'storage': '128GB / 256GB / 512GB',
//         'battery': '3561mAh, 25W Wired, 25W MagSafe',
//         'rear_camera': '48MP Fusion + 12MP Ultra Wide',
//         'front_camera': '12MP TrueDepth',
//         'os': 'iOS 18',
//         'network': '5G, Wi-Fi 7, BT 5.3',
//         'dimensions': '147.6 x 71.6 x 7.8mm, 170g',
//         'colors': 'Black, White, Pink, Teal, Ultramarine',
//         'description':
//         'The iPhone 16 brings Apple Intelligence to the standard lineup with the A18 chip and new Camera Control button. It features a vertical dual-camera system for spatial video and supports Action button customization.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Apple iPhone 15',
//       brand: 'Apple',
//       images: [
//         'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'iPhone 15 on Flipkart', price: '₹69,900', link: 'https://flipkart.com'),
//         PriceInfo(title: 'iPhone 15 on Amazon', price: '₹71,900', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.1" Super Retina XDR OLED, 60Hz',
//         'processor': 'Apple A16 Bionic',
//         'ram': '6GB',
//         'storage': '128GB / 256GB / 512GB',
//         'battery': '3349mAh, 27W Wired, 15W MagSafe',
//         'rear_camera': '48MP + 12MP Ultra Wide',
//         'front_camera': '12MP TrueDepth',
//         'os': 'iOS 17 (upgradable to iOS 18)',
//         'network': '5G, Wi-Fi 6, BT 5.3',
//         'dimensions': '147.6 x 71.6 x 7.8mm, 171g',
//         'colors': 'Black, Blue, Green, Yellow, Pink',
//         'description':
//         'The iPhone 15 features a Dynamic Island, USB-C port and a 48MP main camera. Powered by the A16 Bionic chip it delivers excellent performance and computational photography in a familiar compact form.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── OnePlus ───────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'OnePlus 12',
//       brand: 'OnePlus',
//       images: [
//         'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'OnePlus 12 on Flipkart', price: '₹64,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'OnePlus 12 on Amazon', price: '₹65,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.82" QHD+ LTPO AMOLED, 1-120Hz',
//         'processor': 'Snapdragon 8 Gen 3',
//         'ram': '12GB / 16GB',
//         'storage': '256GB / 512GB',
//         'battery': '5400mAh, 100W SuperVOOC + 50W Wireless',
//         'rear_camera': '50MP (Hasselblad) + 48MP Ultra Wide + 64MP 3x Periscope',
//         'front_camera': '32MP',
//         'os': 'Android 14, OxygenOS 14',
//         'network': '5G, Wi-Fi 7, BT 5.4',
//         'dimensions': '164.3 x 75.8 x 9.15mm, 220g',
//         'colors': 'Silky Black, Flowy Emerald',
//         'description':
//         'The OnePlus 12 is a flagship killer with Snapdragon 8 Gen 3, Hasselblad-tuned triple cameras, and 100W SuperVOOC charging. The massive 5400mAh battery and QHD+ LTPO display make it one of the best value flagships in India.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'OnePlus Nord CE 4',
//       brand: 'OnePlus',
//       images: [
//         'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'OnePlus Nord CE 4 on Flipkart', price: '₹24,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'OnePlus Nord CE 4 on Amazon', price: '₹25,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" FHD+ AMOLED, 120Hz',
//         'processor': 'Snapdragon 7 Gen 3',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '5500mAh, 100W SuperVOOC',
//         'rear_camera': '50MP Sony LYT-600 + 8MP Ultra Wide',
//         'front_camera': '16MP',
//         'os': 'Android 14, OxygenOS 14',
//         'network': '5G, Wi-Fi 6, BT 5.4',
//         'dimensions': '162.6 x 75.7 x 7.98mm, 186g',
//         'colors': 'Dark Chrome, Celadon Marble',
//         'description':
//         'The OnePlus Nord CE 4 brings 100W charging to the mid-range with Snapdragon 7 Gen 3 performance and a 50MP Sony camera. Its slim design and ultra-fast charging make it a top pick in the ₹25K segment.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Xiaomi / Redmi ────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Xiaomi 14',
//       brand: 'Xiaomi',
//       images: [
//         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Xiaomi 14 on Flipkart', price: '₹69,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Xiaomi 14 on Amazon', price: '₹71,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.36" FHD+ AMOLED, 120Hz',
//         'processor': 'Snapdragon 8 Gen 3',
//         'ram': '12GB',
//         'storage': '256GB / 512GB',
//         'battery': '4610mAh, 90W HyperCharge + 50W Wireless',
//         'rear_camera': '50MP Leica Summilux + 50MP Ultra Wide + 50MP 3.2x Tele',
//         'front_camera': '32MP',
//         'os': 'Android 14, HyperOS',
//         'network': '5G, Wi-Fi 7, BT 5.4',
//         'dimensions': '152.8 x 71.5 x 8.2mm, 193g',
//         'colors': 'Black, White, Jade Green',
//         'description':
//         'The Xiaomi 14 is a compact flagship with Leica-branded triple cameras, Snapdragon 8 Gen 3, and IP68 water resistance. Its 90W fast charging and 6.36-inch display make it ideal for users wanting a premium compact phone.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Redmi Note 13 Pro+',
//       brand: 'Redmi',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Redmi Note 13 Pro+ on Flipkart', price: '₹29,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Redmi Note 13 Pro+ on Amazon', price: '₹30,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.67" FHD+ AMOLED, 120Hz, 2712 nits',
//         'processor': 'MediaTek Dimensity 7200 Ultra',
//         'ram': '8GB / 12GB',
//         'storage': '256GB',
//         'battery': '5000mAh, 120W HyperCharge',
//         'rear_camera': '200MP + 8MP Ultra Wide + 2MP Macro',
//         'front_camera': '16MP',
//         'os': 'Android 13, MIUI 14',
//         'network': '5G, Wi-Fi 6, BT 5.3',
//         'dimensions': '161.4 x 74.2 x 8.9mm, 204g',
//         'colors': 'Midnight Black, Aurora Purple, Fusion White',
//         'description':
//         'The Redmi Note 13 Pro+ packs a 200MP camera and 120W fast charging in the mid-range. With IP68 rating and a bright 2712-nit display, it offers flagship features at a fraction of the cost.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Redmi Note 13',
//       brand: 'Redmi',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Redmi Note 13 on Flipkart', price: '₹14,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Redmi Note 13 on Amazon', price: '₹15,499', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.67" FHD+ AMOLED, 120Hz',
//         'processor': 'Snapdragon 685',
//         'ram': '6GB / 8GB',
//         'storage': '128GB / 256GB',
//         'battery': '5000mAh, 33W Fast Charging',
//         'rear_camera': '108MP + 8MP Ultra Wide + 2MP Macro',
//         'front_camera': '16MP',
//         'os': 'Android 13, MIUI 14',
//         'network': '4G LTE, Wi-Fi 5, BT 5.0',
//         'dimensions': '161.1 x 75 x 7.6mm, 174g',
//         'colors': 'Arctic White, Midnight Black, Stardust Purple',
//         'description':
//         'The Redmi Note 13 offers a 108MP camera and bright AMOLED display at an affordable price. Its slim 7.6mm profile and Snapdragon 685 processor make it an excellent budget-friendly daily driver.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── POCO ──────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'POCO X6 Pro',
//       brand: 'POCO',
//       images: [
//         'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'POCO X6 Pro on Flipkart', price: '₹26,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'POCO X6 Pro on Amazon', price: '₹27,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.67" FHD+ AMOLED, 144Hz',
//         'processor': 'MediaTek Dimensity 8300 Ultra',
//         'ram': '8GB / 12GB',
//         'storage': '256GB',
//         'battery': '5000mAh, 67W Turbo Charging',
//         'rear_camera': '64MP OIS + 8MP Ultra Wide + 2MP Macro',
//         'front_camera': '16MP',
//         'os': 'Android 14, HyperOS',
//         'network': '5G, Wi-Fi 6, BT 5.4',
//         'dimensions': '160.5 x 74.3 x 8.2mm, 186g',
//         'colors': 'Grey, Yellow, Black',
//         'description':
//         'The POCO X6 Pro is a performance beast with Dimensity 8300 Ultra and a 144Hz AMOLED display. It offers gaming-grade performance with excellent thermal management and 67W fast charging at a competitive price.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'POCO M6 Pro',
//       brand: 'POCO',
//       images: [
//         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'POCO M6 Pro on Flipkart', price: '₹13,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'POCO M6 Pro on Amazon', price: '₹14,499', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.67" FHD+ AMOLED, 120Hz',
//         'processor': 'Helio G99 Ultra',
//         'ram': '6GB / 8GB',
//         'storage': '128GB / 256GB',
//         'battery': '5000mAh, 67W Turbo Charging',
//         'rear_camera': '64MP OIS + 8MP + 2MP',
//         'front_camera': '16MP',
//         'os': 'Android 14, HyperOS',
//         'network': '4G LTE, Wi-Fi 5, BT 5.3',
//         'dimensions': '161.2 x 75 x 8mm, 179g',
//         'colors': 'Black, Blue, Purple',
//         'description':
//         'The POCO M6 Pro brings 67W fast charging and a 64MP OIS camera to the budget segment. With Helio G99 Ultra and an AMOLED display, it delivers premium features at an entry-level price.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Realme ────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Realme GT 6',
//       brand: 'Realme',
//       images: [
//         'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Realme GT 6 on Flipkart', price: '₹34,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Realme GT 6 on Amazon', price: '₹35,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.78" FHD+ AMOLED, 144Hz, 6000 nits',
//         'processor': 'Snapdragon 8s Gen 3',
//         'ram': '8GB / 12GB / 16GB',
//         'storage': '256GB',
//         'battery': '5500mAh, 120W SuperVOOC',
//         'rear_camera': '50MP Sony LYT-808 OIS + 8MP Ultra Wide',
//         'front_camera': '32MP',
//         'os': 'Android 14, Realme UI 5.0',
//         'network': '5G, Wi-Fi 7, BT 5.4',
//         'dimensions': '161.7 x 74.7 x 8.1mm, 199g',
//         'colors': 'Fluid Silver, Razor Green',
//         'description':
//         'The Realme GT 6 features the world\'s brightest 6000-nit display and Snapdragon 8s Gen 3 performance. With 120W charging and Sony LYT-808 camera sensor, it punches well above its price bracket.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Realme Narzo 70 Pro',
//       brand: 'Realme',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Realme Narzo 70 Pro on Flipkart', price: '₹19,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Realme Narzo 70 Pro on Amazon', price: '₹20,499', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" FHD+ AMOLED, 120Hz',
//         'processor': 'MediaTek Dimensity 7050',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '5000mAh, 45W SuperVOOC',
//         'rear_camera': '50MP + 8MP Ultra Wide + 2MP',
//         'front_camera': '16MP',
//         'os': 'Android 14, Realme UI 5.0',
//         'network': '5G, Wi-Fi 6, BT 5.3',
//         'dimensions': '162 x 74.9 x 7.9mm, 190g',
//         'colors': 'Dark Green, Cosmic Black',
//         'description':
//         'The Realme Narzo 70 Pro offers 5G connectivity with Dimensity 7050 and a bright 120Hz AMOLED screen. Its 45W fast charging and slim build make it a solid mid-range performer for everyday use.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Vivo ──────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Vivo V30 Pro',
//       brand: 'Vivo',
//       images: [
//         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Vivo V30 Pro on Flipkart', price: '₹39,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Vivo V30 Pro on Amazon', price: '₹40,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.78" FHD+ AMOLED, 120Hz',
//         'processor': 'Snapdragon 7 Gen 3',
//         'ram': '8GB / 12GB',
//         'storage': '256GB',
//         'battery': '5000mAh, 80W FlashCharge',
//         'rear_camera': '50MP Zeiss OIS + 50MP Tele + 8MP Ultra Wide',
//         'front_camera': '50MP Zeiss',
//         'os': 'Android 14, Funtouch OS 14',
//         'network': '5G, Wi-Fi 6E, BT 5.4',
//         'dimensions': '164.4 x 75 x 7.5mm, 186g',
//         'colors': 'Peacock Green, Red',
//         'description':
//         'The Vivo V30 Pro stands out with its Zeiss-branded triple camera system and 50MP front camera. Its ultra-slim 7.5mm profile and 80W fast charging make it a top choice for photography enthusiasts.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── iQOO ──────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'iQOO Neo 9 Pro',
//       brand: 'iQOO',
//       images: [
//         'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'iQOO Neo 9 Pro on Flipkart', price: '₹36,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'iQOO Neo 9 Pro on Amazon', price: '₹37,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.78" FHD+ AMOLED, 144Hz',
//         'processor': 'Snapdragon 8 Gen 2',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '5160mAh, 66W FlashCharge',
//         'rear_camera': '50MP Sony IMX920 OIS + 8MP Ultra Wide',
//         'front_camera': '16MP',
//         'os': 'Android 14, Funtouch OS 14',
//         'network': '5G, Wi-Fi 6E, BT 5.3',
//         'dimensions': '163.7 x 76.2 x 8.89mm, 199g',
//         'colors': 'Fiery Red, Dark Storm',
//         'description':
//         'The iQOO Neo 9 Pro delivers flagship Snapdragon 8 Gen 2 performance at a mid-range price. Its 144Hz display, Sony IMX920 camera, and Monster Touch gaming triggers make it ideal for mobile gamers.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Motorola ──────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Motorola Edge 50 Pro',
//       brand: 'Motorola',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Motorola Edge 50 Pro on Flipkart', price: '₹31,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Motorola Edge 50 Pro on Amazon', price: '₹32,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" pOLED, 144Hz, Curved',
//         'processor': 'Snapdragon 7 Gen 3',
//         'ram': '12GB',
//         'storage': '256GB',
//         'battery': '4500mAh, 125W TurboPower + 50W Wireless',
//         'rear_camera': '50MP OIS + 13MP Ultra Wide + 10MP 3x Tele',
//         'front_camera': '50MP',
//         'os': 'Android 14, Hello UI',
//         'network': '5G, Wi-Fi 6E, BT 5.3',
//         'dimensions': '161.2 x 73.1 x 8.19mm, 186g',
//         'colors': 'Black Beauty, Luxe Lavender, Moonlight Pearl',
//         'description':
//         'The Motorola Edge 50 Pro features a beautiful curved pOLED display and industry-leading 125W wired charging. With a clean near-stock Android experience and IP68 rating, it offers a premium feel without the flagship price.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Motorola G85',
//       brand: 'Motorola',
//       images: [
//         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Motorola G85 on Flipkart', price: '₹17,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Motorola G85 on Amazon', price: '₹18,499', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.67" FHD+ pOLED, 120Hz',
//         'processor': 'Snapdragon 6s Gen 3',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '5000mAh, 33W TurboPower',
//         'rear_camera': '50MP OIS + 8MP Ultra Wide',
//         'front_camera': '32MP',
//         'os': 'Android 14',
//         'network': '5G, Wi-Fi 5, BT 5.1',
//         'dimensions': '161.9 x 73.1 x 7.59mm, 170g',
//         'colors': 'Cobalt Blue, Urban Grey, Olive Green',
//         'description':
//         'The Motorola G85 brings a pOLED display and 50MP OIS camera to the budget 5G segment. Its slim 7.59mm design, clean Android software, and Snapdragon 6s Gen 3 chip make it a reliable everyday smartphone.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Nothing ───────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Nothing Phone 2a',
//       brand: 'Nothing',
//       images: [
//         'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Nothing Phone 2a on Flipkart', price: '₹23,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Nothing Phone 2a on Amazon', price: '₹24,499', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" FHD+ AMOLED, 120Hz',
//         'processor': 'MediaTek Dimensity 7200 Pro',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '5000mAh, 45W Fast Charging',
//         'rear_camera': '50MP OIS + 50MP Ultra Wide',
//         'front_camera': '32MP',
//         'os': 'Android 14, Nothing OS 2.5',
//         'network': '5G, Wi-Fi 6, BT 5.3',
//         'dimensions': '161.7 x 76.3 x 8.6mm, 190g',
//         'colors': 'Black, White, Blue (Special Edition)',
//         'description':
//         'The Nothing Phone 2a features the iconic Glyph Interface LED system and a unique transparent back design. Powered by Dimensity 7200 Pro with a clean Nothing OS, it offers a refreshingly different Android experience.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Google ────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Google Pixel 8a',
//       brand: 'Google',
//       images: [
//         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Google Pixel 8a on Flipkart', price: '₹52,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Google Pixel 8a on Amazon', price: '₹53,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.1" FHD+ OLED, 120Hz',
//         'processor': 'Google Tensor G3',
//         'ram': '8GB',
//         'storage': '128GB / 256GB',
//         'battery': '4492mAh, 18W Wired, 18W Wireless',
//         'rear_camera': '64MP OIS + 13MP Ultra Wide',
//         'front_camera': '13MP',
//         'os': 'Android 14 (7 years updates)',
//         'network': '5G, Wi-Fi 6E, BT 5.3',
//         'dimensions': '152.1 x 72.7 x 8.9mm, 188g',
//         'colors': 'Obsidian, Porcelain, Bay, Aloe',
//         'description':
//         'The Google Pixel 8a offers the best computational photography in its class with Google Tensor G3 and 7 years of OS updates. Magic Eraser, Photo Unblur, and Gemini AI integration make it the smartest camera phone at its price.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Oppo ──────────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Oppo Reno 12 Pro',
//       brand: 'Oppo',
//       images: [
//         'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Oppo Reno 12 Pro on Flipkart', price: '₹36,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Oppo Reno 12 Pro on Amazon', price: '₹37,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '6.7" FHD+ AMOLED, 120Hz',
//         'processor': 'MediaTek Dimensity 7300 Energy',
//         'ram': '12GB',
//         'storage': '256GB',
//         'battery': '5000mAh, 80W SuperVOOC',
//         'rear_camera': '50MP Sony LYT-600 OIS + 8MP Tele + 8MP Ultra Wide',
//         'front_camera': '50MP',
//         'os': 'Android 14, ColorOS 14.1',
//         'network': '5G, Wi-Fi 6, BT 5.4',
//         'dimensions': '162 x 75 x 7.6mm, 185g',
//         'colors': 'Nebula Silver, Sunset Gold',
//         'description':
//         'The Oppo Reno 12 Pro is a style-focused mid-ranger with a 50MP front camera and AI portrait features. Its 80W charging and ultra-slim profile make it a fashionable yet capable daily smartphone.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//
//     // ── Laptops ───────────────────────────────────────────────────────────────
//     CombinedProduct(
//       name: 'Apple MacBook Air M3',
//       brand: 'Apple',
//       images: [
//         'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'MacBook Air M3 on Flipkart', price: '₹1,14,900', link: 'https://flipkart.com'),
//         PriceInfo(title: 'MacBook Air M3 on Amazon', price: '₹1,14,900', link: 'https://amazon.in'),
//         PriceInfo(title: 'MacBook Air M3 on Croma', price: '₹1,14,900', link: 'https://croma.com'),
//       ],
//       specs: {
//         'display': '13.6" Liquid Retina, 2560x1664, 500 nits',
//         'processor': 'Apple M3 (8-core CPU, 10-core GPU)',
//         'ram': '8GB / 16GB / 24GB Unified Memory',
//         'storage': '256GB / 512GB / 1TB / 2TB SSD',
//         'battery': '52.6Wh, up to 18 hours',
//         'rear_camera': 'N/A',
//         'front_camera': '1080p FaceTime HD',
//         'os': 'macOS Sonoma',
//         'network': 'Wi-Fi 6E, BT 5.3, 2x Thunderbolt 3',
//         'dimensions': '304.1 x 215 x 11.3mm, 1.24kg',
//         'colors': 'Midnight, Starlight, Space Grey, Sky Blue',
//         'description':
//         'The MacBook Air M3 is the best laptop for most people with all-day battery life and fanless silent operation. The M3 chip delivers exceptional performance for creative work, and it supports dual external displays for the first time.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//     CombinedProduct(
//       name: 'Samsung Galaxy Tab S9',
//       brand: 'Samsung',
//       images: [
//         'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80',
//       ],
//       price: [
//         PriceInfo(title: 'Samsung Galaxy Tab S9 on Flipkart', price: '₹72,999', link: 'https://flipkart.com'),
//         PriceInfo(title: 'Samsung Galaxy Tab S9 on Amazon', price: '₹74,999', link: 'https://amazon.in'),
//       ],
//       specs: {
//         'display': '11" Dynamic AMOLED 2X, 120Hz, IP68',
//         'processor': 'Snapdragon 8 Gen 2',
//         'ram': '8GB / 12GB',
//         'storage': '128GB / 256GB',
//         'battery': '8400mAh, 45W Fast Charging',
//         'rear_camera': '13MP + 6MP Ultra Wide',
//         'front_camera': '12MP',
//         'os': 'Android 13, One UI 5.1.1',
//         'network': 'Wi-Fi 6E, BT 5.3, USB-C 3.2',
//         'dimensions': '254.3 x 165.8 x 5.9mm, 498g',
//         'colors': 'Beige, Graphite, Lavender',
//         'description':
//         'The Samsung Galaxy Tab S9 is a premium Android tablet with an IP68-rated AMOLED display, Snapdragon 8 Gen 2, and S Pen included. DeX mode enables desktop-like productivity on the go.',
//       },
//       variants: [],
//       sourceLinks: [],
//     ),
//   ];
// }
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─── Models ───────────────────────────────────────────────────────────────────

class CombinedProduct {
  final String name;
  final String brand;
  final List<String> images;
  final List<PriceInfo> price;
  final Map<String, dynamic> specs;
  final List<Variant> variants;
  final List<String> sourceLinks;

  const CombinedProduct({
    required this.name,
    required this.brand,
    required this.images,
    required this.price,
    required this.specs,
    required this.variants,
    required this.sourceLinks,
  });
}

class PriceInfo {
  final String title;
  final String price;
  final String link;
  const PriceInfo({required this.title, required this.price, required this.link});
}

class Variant {
  final String name;
  final String? price;
  final String? storage;
  final String? color;
  const Variant({required this.name, this.price, this.storage, this.color});
}

// ─── Service ──────────────────────────────────────────────────────────────────

class CombinedApiService {
  // Use backend proxy for web development (CORS-free)
  static const String _base  = kIsWeb ? 'http://localhost:3000' : 'https://api.mobileapi.dev/devices';
  static const String _token = 'e69c7e072fc8d593751bbd54ec09d552815bed4a';

  static const Map<String, String> _headers = {
    // For web: no auth needed (proxy handles it)
    // For mobile: use direct API auth
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (!kIsWeb) 'Authorization': 'Token $_token',
  };


  static Future<List<CombinedProduct>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    
    debugPrint('🔍 Searching for: "$query"');

    try {
      String baseUrl = _base;
      String endpoint = kIsWeb ? '/search' : '/search';
      
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: {'name': query.trim()},
      );

      debugPrint('🌐 Calling: $uri');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('← HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        // Handle different response structures
        List<dynamic> rawList = [];
        
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map) {
          rawList = (decoded['devices'] ??
              decoded['results'] ??
              decoded['data'] ??
              decoded['products'] ??
              decoded['items'] ??
              decoded['list'] ??
              []) as List<dynamic>;
        }

        if (rawList.isNotEmpty) {
          debugPrint('✅ Found ${rawList.length} products');
          return rawList.whereType<Map<String, dynamic>>().map(_mapProduct).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ Search failed: $e');
    }

    // Fallback to local data
    debugPrint('🔄 Using local data fallback');
    return _searchLocalData(query);
  }

  // ─── Local Data Search ─────────────────────────────────────────────────────

  static List<CombinedProduct> _searchLocalData(String query) {
    final q = query.toLowerCase().trim();
    
    debugPrint('→ Searching local data for: "$q"');
    
    final results = _allProducts.where((p) {
      final nameLower = p.name.toLowerCase();
      final brandLower = p.brand.toLowerCase();
      return nameLower.contains(q) || brandLower.contains(q);
    }).toList();

    debugPrint('   → ${results.length} products found from local data');
    return results;
  }

  // ─── Local Product Database ───────────────────────────────────────────────────

  static final List<CombinedProduct> _allProducts = [
    // ── Samsung ──────────────────────────────────────────────────────────────
    CombinedProduct(
      name: 'Samsung Galaxy S24 Ultra',
      brand: 'Samsung',
      images: [
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&q=80',
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'Samsung Galaxy S24 Ultra on Flipkart', price: '₹1,29,999', link: 'https://flipkart.com'),
        PriceInfo(title: 'Samsung Galaxy S24 Ultra on Amazon', price: '₹1,31,999', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.8" QHD+ Dynamic AMOLED 2X, 120Hz',
        'processor': 'Snapdragon 8 Gen 3',
        'ram': '12GB',
        'storage': '256GB / 512GB / 1TB',
        'battery': '5000mAh, 45W Fast Charging',
        'rear_camera': '200MP + 12MP + 10MP + 10MP',
        'front_camera': '12MP',
        'os': 'Android 14, One UI 6.1',
        'network': '5G, Wi-Fi 7, BT 5.3',
        'dimensions': '162.3 x 79 x 8.6mm, 232g',
        'colors': 'Titanium Black, Gray, Violet, Yellow',
        'description': 'The Samsung Galaxy S24 Ultra is the ultimate flagship with a built-in S Pen, 200MP camera, and Snapdragon 8 Gen 3 chipset.',
      },
      variants: [],
      sourceLinks: [],
    ),
    CombinedProduct(
      name: 'Samsung Galaxy A55',
      brand: 'Samsung',
      images: [
        'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'Samsung Galaxy A55 on Flipkart', price: '₹38,999', link: 'https://flipkart.com'),
        PriceInfo(title: 'Samsung Galaxy A55 on Amazon', price: '₹39,999', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.6" FHD+ Super AMOLED, 120Hz',
        'processor': 'Exynos 1480',
        'ram': '8GB / 12GB',
        'storage': '128GB / 256GB',
        'battery': '5000mAh, 25W Fast Charging',
        'rear_camera': '50MP + 12MP + 5MP',
        'front_camera': '32MP',
        'os': 'Android 14, One UI 6.1',
        'network': '5G, Wi-Fi 6, BT 5.3',
        'dimensions': '161.1 x 77.4 x 8.2mm, 213g',
        'colors': 'Awesome Iceblue, Lilac, Navy',
        'description': 'The Samsung Galaxy A55 brings flagship-inspired design to the mid-range with an Exynos 1480 chip.',
      },
      variants: [],
      sourceLinks: [],
    ),
    // ── Apple ─────────────────────────────────────────────────────────────────
    CombinedProduct(
      name: 'Apple iPhone 16 Pro Max',
      brand: 'Apple',
      images: [
        'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'iPhone 16 Pro Max on Flipkart', price: '₹1,59,900', link: 'https://flipkart.com'),
        PriceInfo(title: 'iPhone 16 Pro Max on Amazon', price: '₹1,61,900', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.9" Super Retina XDR OLED, 120Hz ProMotion',
        'processor': 'Apple A18 Pro',
        'ram': '8GB',
        'storage': '256GB / 512GB / 1TB',
        'battery': '4685mAh, 27W Wired, 25W MagSafe',
        'rear_camera': '48MP Fusion + 48MP Ultra Wide + 12MP 5x Tetraprism',
        'front_camera': '12MP TrueDepth',
        'os': 'iOS 18',
        'network': '5G, Wi-Fi 7, BT 5.3',
        'dimensions': '163 x 77.6 x 8.25mm, 227g',
        'colors': 'Black Titanium, White Titanium, Natural Titanium, Desert Titanium',
        'description': 'The iPhone 16 Pro Max is Apple\'s most advanced smartphone featuring the A18 Pro chip and Camera Control button.',
      },
      variants: [],
      sourceLinks: [],
    ),
    CombinedProduct(
      name: 'Apple iPhone 15',
      brand: 'Apple',
      images: [
        'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'iPhone 15 on Flipkart', price: '₹69,900', link: 'https://flipkart.com'),
        PriceInfo(title: 'iPhone 15 on Amazon', price: '₹71,900', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.1" Super Retina XDR OLED, 60Hz',
        'processor': 'Apple A16 Bionic',
        'ram': '6GB',
        'storage': '128GB / 256GB / 512GB',
        'battery': '3349mAh, 27W Wired, 15W MagSafe',
        'rear_camera': '48MP + 12MP Ultra Wide',
        'front_camera': '12MP TrueDepth',
        'os': 'iOS 17 (upgradable to iOS 18)',
        'network': '5G, Wi-Fi 6, BT 5.3',
        'dimensions': '147.6 x 71.6 x 7.8mm, 171g',
        'colors': 'Black, Blue, Green, Yellow, Pink',
        'description': 'The iPhone 15 features a Dynamic Island, USB-C port and a 48MP main camera.',
      },
      variants: [],
      sourceLinks: [],
    ),
    // ── OnePlus ───────────────────────────────────────────────────────────────
    CombinedProduct(
      name: 'OnePlus 12',
      brand: 'OnePlus',
      images: [
        'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'OnePlus 12 on Flipkart', price: '₹64,999', link: 'https://flipkart.com'),
        PriceInfo(title: 'OnePlus 12 on Amazon', price: '₹65,999', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.82" QHD+ LTPO AMOLED, 1-120Hz',
        'processor': 'Snapdragon 8 Gen 3',
        'ram': '12GB / 16GB',
        'storage': '256GB / 512GB',
        'battery': '5400mAh, 100W SuperVOOC + 50W Wireless',
        'rear_camera': '50MP (Hasselblad) + 48MP Ultra Wide + 64MP 3x Periscope',
        'front_camera': '32MP',
        'os': 'Android 14, OxygenOS 14',
        'network': '5G, Wi-Fi 7, BT 5.4',
        'dimensions': '164.3 x 75.8 x 9.15mm, 220g',
        'colors': 'Silky Black, Flowy Emerald',
        'description': 'The OnePlus 12 is a flagship killer with Snapdragon 8 Gen 3, Hasselblad-tuned triple cameras.',
      },
      variants: [],
      sourceLinks: [],
    ),
    // ── Vivo ──────────────────────────────────────────────────────────────────
    CombinedProduct(
      name: 'Vivo V30 Pro',
      brand: 'Vivo',
      images: [
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'Vivo V30 Pro on Flipkart', price: '₹39,999', link: 'https://flipkart.com'),
        PriceInfo(title: 'Vivo V30 Pro on Amazon', price: '₹40,999', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.78" FHD+ AMOLED, 120Hz',
        'processor': 'Snapdragon 7 Gen 3',
        'ram': '8GB / 12GB',
        'storage': '256GB',
        'battery': '5000mAh, 80W FlashCharge',
        'rear_camera': '50MP Zeiss OIS + 50MP Tele + 8MP Ultra Wide',
        'front_camera': '50MP Zeiss',
        'os': 'Android 14, Funtouch OS 14',
        'network': '5G, Wi-Fi 6E, BT 5.4',
        'dimensions': '164.4 x 75 x 7.5mm, 186g',
        'colors': 'Peacock Green, Red',
        'description': 'The Vivo V30 Pro stands out with its Zeiss-branded triple camera system and 50MP front camera.',
      },
      variants: [],
      sourceLinks: [],
    ),
    // ── Xiaomi ────────────────────────────────────────────────────────────────
    CombinedProduct(
      name: 'Xiaomi 14',
      brand: 'Xiaomi',
      images: [
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'Xiaomi 14 on Flipkart', price: '₹69,999', link: 'https://flipkart.com'),
        PriceInfo(title: 'Xiaomi 14 on Amazon', price: '₹71,999', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.36" FHD+ AMOLED, 120Hz',
        'processor': 'Snapdragon 8 Gen 3',
        'ram': '12GB',
        'storage': '256GB / 512GB',
        'battery': '4610mAh, 90W HyperCharge + 50W Wireless',
        'rear_camera': '50MP Leica Summilux + 50MP Ultra Wide + 50MP 3.2x Tele',
        'front_camera': '32MP',
        'os': 'Android 14, HyperOS',
        'network': '5G, Wi-Fi 7, BT 5.4',
        'dimensions': '152.8 x 71.5 x 8.2mm, 193g',
        'colors': 'Black, White, Jade Green',
        'description': 'The Xiaomi 14 is a compact flagship with Leica-branded triple cameras, Snapdragon 8 Gen 3.',
      },
      variants: [],
      sourceLinks: [],
    ),
    // ── Realme ────────────────────────────────────────────────────────────────
    CombinedProduct(
      name: 'Realme GT 6',
      brand: 'Realme',
      images: [
        'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
      ],
      price: [
        PriceInfo(title: 'Realme GT 6 on Flipkart', price: '₹34,999', link: 'https://flipkart.com'),
        PriceInfo(title: 'Realme GT 6 on Amazon', price: '₹35,999', link: 'https://amazon.in'),
      ],
      specs: {
        'display': '6.78" FHD+ AMOLED, 144Hz, 6000 nits',
        'processor': 'Snapdragon 8s Gen 3',
        'ram': '8GB / 12GB / 16GB',
        'storage': '256GB',
        'battery': '5500mAh, 120W SuperVOOC',
        'rear_camera': '50MP Sony LYT-808 OIS + 8MP Ultra Wide',
        'front_camera': '32MP',
        'os': 'Android 14, Realme UI 5.0',
        'network': '5G, Wi-Fi 7, BT 5.4',
        'dimensions': '161.7 x 74.7 x 8.1mm, 199g',
        'colors': 'Fluid Silver, Razor Green',
        'description': 'The Realme GT 6 features the world\'s brightest 6000-nit display and Snapdragon 8s Gen 3 performance.',
      },
      variants: [],
      sourceLinks: [],
    ),
  ];

  // ─── Fetch Product Detail ─────────────────────────────────────────────────

  static Future<CombinedProduct> fetchProductData(String productNameOrSlug) async {
    debugPrint('📱 Fetching product details for: "$productNameOrSlug"');

    if (productNameOrSlug.trim().isEmpty) {
      throw Exception('Product name cannot be empty');
    }

    try {
      // For web: use backend proxy endpoint
      if (kIsWeb) {
        final uri = Uri.parse('$_base/product/${Uri.encodeComponent(productNameOrSlug)}');
        debugPrint('🌐 Calling: $uri');

        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('✅ Found product via proxy: ${data['name']}');
          return _mapProduct(data);
        }
      }

      // For mobile or web fallback: use search
      var results = await searchProducts(productNameOrSlug);
      if (results.isNotEmpty) {
        debugPrint('✅ Found exact match: ${results.first.name}');
        return results.first;
      }

      // Try search variations
      final searchVariations = _generateSearchVariations(productNameOrSlug);
      for (final variation in searchVariations) {
        results = await searchProducts(variation);
        if (results.isNotEmpty) {
          debugPrint('✅ Found with variation "$variation": ${results.first.name}');
          return results.first;
        }
      }

      // Try individual terms
      final searchTerms = productNameOrSlug.split(' ')
          .where((term) => term.length > 2)
          .toList();
      
      for (final term in searchTerms) {
        results = await searchProducts(term);
        if (results.isNotEmpty) {
          debugPrint('✅ Found with term "$term": ${results.first.name}');
          return results.first;
        }
      }

    } catch (e) {
      debugPrint('❌ Product fetch failed: $e');
    }

    // Local data fallback
    debugPrint('🔄 Using local data with fuzzy matching');
    final localResults = _fuzzySearchLocalData(productNameOrSlug);
    if (localResults.isNotEmpty) {
      return localResults.first;
    }

    // Create dummy product
    debugPrint('⚠️ Creating dummy product for: $productNameOrSlug');
    return _createDummyProduct(productNameOrSlug);
  }

  // ─── Helper Methods ───────────────────────────────────────────────────────

  static List<String> _generateSearchVariations(String productName) {
    final variations = <String>[];
    final name = productName.toLowerCase().trim();
    
    // Add original name
    variations.add(productName);
    
    // Remove common suffixes
    final withoutSuffix = name
        .replaceAll(RegExp(r'\s+(phone|mobile|smartphone|pro|max|plus|lite|mini)$'), '')
        .trim();
    if (withoutSuffix != name && withoutSuffix.isNotEmpty) {
      variations.add(withoutSuffix);
    }
    
    // Try brand + model format
    final words = name.split(' ');
    if (words.length >= 2) {
      variations.add('${words[0]} ${words.sublist(1).join(' ')}');
    }
    
    return variations.toSet().toList();
  }

  static List<CombinedProduct> _fuzzySearchLocalData(String query) {
    final q = query.toLowerCase().trim();
    final results = <CombinedProduct>[];
    
    for (final product in _allProducts) {
      final nameLower = product.name.toLowerCase();
      final brandLower = product.brand.toLowerCase();
      
      // Exact matches
      if (nameLower == q || brandLower == q) {
        results.insert(0, product); // Priority to exact matches
        continue;
      }
      
      // Contains matches
      if (nameLower.contains(q) || brandLower.contains(q)) {
        results.add(product);
        continue;
      }
      
      // Partial matches (words)
      final queryWords = q.split(' ');
      int matchCount = 0;
      
      for (final word in queryWords) {
        if (word.length > 2 && (nameLower.contains(word) || brandLower.contains(word))) {
          matchCount++;
        }
      }
      
      // If at least 50% of words match
      if (matchCount > 0 && matchCount >= queryWords.length / 2) {
        results.add(product);
      }
    }
    
    return results;
  }

  static CombinedProduct _createDummyProduct(String productName) {
    final brand = _extractBrandFromName(productName);
    
    return CombinedProduct(
      name: productName,
      brand: brand,
      images: _placeholderImages(),
      price: [
        PriceInfo(
          title: '$productName Price',
          price: 'Price not available',
          link: '',
        ),
      ],
      specs: {
        'display': 'Information not available',
        'processor': 'Information not available',
        'ram': 'Information not available',
        'storage': 'Information not available',
        'battery': 'Information not available',
        'camera': 'Information not available',
        'os': 'Information not available',
        'network': 'Information not available',
        'description': 'Detailed specifications for $productName are not currently available. Please check back later.',
      },
      variants: [],
      sourceLinks: [],
    );
  }

  static String _extractBrandFromName(String productName) {
    final name = productName.toLowerCase();
    
    for (final brand in _knownBrands) {
      if (name.startsWith(brand.toLowerCase()) || name.contains(brand.toLowerCase())) {
        return brand;
      }
    }
    
    // Try to extract first word as brand
    final words = productName.split(' ');
    return words.isNotEmpty ? words[0] : 'Unknown';
  }

  // ─── Mappers ──────────────────────────────────────────────────────────────

  static CombinedProduct _mapProduct(Map<String, dynamic> item) {
    final name  = item['name']?.toString() ?? '';
    final brand = item['brand']?.toString()     ??
        item['manufacturer']?.toString()        ??
        item['manufacturer_name']?.toString()   ??
        _brandFromName(name);

    final images = _extractImages(item);
    
    // Debug image extraction
    if (images.isEmpty || images.every((img) => img.isEmpty)) {
      debugPrint('⚠️ No images found for product: $name');
    } else {
      debugPrint('✅ Product "$name" has ${images.length} images');
    }

    final formattedPrice = _formatPrice(
      item['price']?.toString()          ??
          item['selling_price']?.toString() ??
          item['offer_price']?.toString()   ??
          '',
    );
    final formattedMrp = _formatPrice(
      item['source_mrp']?.toString()      ??
          item['mrp']?.toString()           ??
          item['original_price']?.toString() ??
          '',
    );

    final priceList = <PriceInfo>[
      if (formattedPrice.isNotEmpty)
        PriceInfo(title: name, price: formattedPrice, link: ''),
    ];

    final specs = <String, dynamic>{};
    const specKeys = [
      'display', 'screen', 'processor', 'chipset', 'cpu',
      'ram', 'memory', 'storage', 'rom',
      'battery', 'rear_camera', 'camera', 'front_camera', 'selfie_camera',
      'os', 'operating_system', 'network', 'connectivity',
      'dimensions', 'weight', 'colors', 'colour',
      'description', 'about', 'segment', 'launch_year', 'release_date',
      'rating', 'popularity_score',
    ];
    for (final key in specKeys) {
      if (item.containsKey(key) && item[key] != null) {
        specs[key] = item[key];
      }
    }
    if (formattedMrp.isNotEmpty) specs['mrp'] = formattedMrp;

    return CombinedProduct(
      name:        name,
      brand:       brand,
      images:      images,
      price:       priceList,
      specs:       specs,
      variants:    [],
      sourceLinks: [
        if (item['slug'] != null) '$_base/mobiles/${item['slug']}/',
        if (item['url']  != null) item['url'].toString(),
      ],
    );
  }

  static CombinedProduct _mapDetailProduct(Map<String, dynamic> data) {
    final base = _mapProduct(data);
    final nested = data['specifications'] ?? data['specs'] ?? data['key_specs'];
    if (nested is Map<String, dynamic>) {
      base.specs.addAll(nested);
    } else if (nested is List) {
      for (final s in nested) {
        if (s is Map && s['key'] != null && s['value'] != null) {
          base.specs[s['key'].toString()] = s['value'];
        }
      }
    }
    return base;
  }



  static List<String> _extractImages(Map<String, dynamic> item) {
    final List<String> imgs = [];
    
    // Check all possible image field names from API
    final possibleFields = [
      'image', 'images', 'thumbnail', 'image_url', 'img', 'picture', 
      'pictures', 'photo', 'photos', 'media', 'icon', 'img_url'
    ];
    
    for (final field in possibleFields) {
      final imgField = item[field];
      if (imgField != null) {
        if (imgField is String && imgField.isNotEmpty && imgField.startsWith('http')) {
          imgs.add(imgField);
        } else if (imgField is List) {
          for (final img in imgField) {
            if (img is String && img.isNotEmpty && img.startsWith('http')) {
              imgs.add(img);
            }
          }
        }
      }
    }
    
    // Check for gallery
    final gallery = item['gallery'] ?? item['image_gallery'] ?? item['pictures'];
    if (gallery is List) {
      for (final img in gallery) {
        if (img is String && img.isNotEmpty && img.startsWith('http')) {
          imgs.add(img);
        }
      }
    }
    
    debugPrint('📸 Extracted ${imgs.length} images from product');
    
    return imgs.isNotEmpty ? imgs : _placeholderImages();
  }

  static String _formatPrice(String raw) {
    if (raw.isEmpty || raw == '0' || raw == '0.0') return '';
    if (raw.contains('₹')) return raw;
    final num = double.tryParse(raw.replaceAll(',', ''));
    if (num == null || num <= 0) return '';
    final intVal = num.toInt();
    final s      = intVal.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    final rest  = s.substring(0, s.length - 3);
    final fmt   = rest.replaceAllMapped(
      RegExp(r'(\d{1,2})(?=(\d{2})+$)'),
          (m) => '${m[1]},',
    );
    return '₹$fmt,$last3';
  }

  static String _brandFromName(String name) {
    for (final b in _knownBrands) {
      if (name.toLowerCase().startsWith(b.toLowerCase())) return b;
    }
    return '';
  }

  static const _knownBrands = [
    'Samsung', 'Apple', 'Xiaomi', 'Redmi', 'POCO', 'OnePlus', 'Oppo',
    'Vivo', 'iQOO', 'Realme', 'Motorola', 'Nokia', 'Sony', 'LG',
    'Huawei', 'Asus', 'ROG', 'Nothing', 'Infinix', 'Tecno', 'Honor',
    'Google', 'HMD', 'Lava', 'Micromax',
  ];

  static List<String> _placeholderImages() => [
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
    'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80',
    'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=400&q=80',
    'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&q=80',
    'https://images.unsplash.com/photo-1580910051076-3c0e27c02b8e?w=400&q=80',
  ];
}