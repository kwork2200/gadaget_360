import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─── Model ───────────────────────────────────────────────────────────────────

class Product {
  final int id;
  final String name;
  final String slug;
  final String image;
  final String price;
  final String rating;
  final double sourceMrp;
  final int popularityScore;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.price,
    required this.rating,
    required this.sourceMrp,
    required this.popularityScore,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        image: j['image'] ?? '',
        price: j['price'] ?? '',
        rating: j['rating']?.toString() ?? '',
        sourceMrp: double.tryParse(j['source_mrp']?.toString() ?? '0') ?? 0,
        popularityScore:
            int.tryParse(j['popularity_score']?.toString() ?? '0') ?? 0,
      );

  int get discountPercent {
    final p = double.tryParse(price.replaceAll(',', '')) ?? 0;
    if (sourceMrp > 0 && p > 0 && sourceMrp > p) {
      return ((1 - p / sourceMrp) * 100).round();
    }
    return 0;
  }

  String get formattedMrp {
    if (sourceMrp <= 0) return '';
    final n = sourceMrp.toInt();
    final s = n.toString();
    // Indian number format
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final formatted = rest.replaceAllMapped(
        RegExp(r'(\d{1,2})(?=(\d{2})+$)'), (m) => '${m[1]},');
    return '₹$formatted,$last3';
  }

  String get productUrl => 'https://www.gadgets360.com/$slug';
}


class ProductDetail {
  final String display;
  final String processor;
  final String ram;
  final String storage;
  final String battery;
  final String rearCamera;
  final String frontCamera;
  final String os;
  final String releaseDate;
  final String marketStatus;
  final String description;
  final List<String> pros;
  final List<String> cons;

  const ProductDetail({
    this.display = '',
    this.processor = '',
    this.ram = '',
    this.storage = '',
    this.battery = '',
    this.rearCamera = '',
    this.frontCamera = '',
    this.os = '',
    this.releaseDate = '',
    this.marketStatus = '',
    this.description = '',
    this.pros = const [],
    this.cons = const [],
  });
}


