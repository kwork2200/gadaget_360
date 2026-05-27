import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/combined_api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  ProductDetail? _detail;
  bool _loading = true;

  final _tabs = const ['Overview', 'Price', 'Specs', 'Reviews'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final combinedProduct = await CombinedApiService.fetchProductData(widget.product.name);
      if (mounted) {
        setState(() { 
          _detail = ProductDetail(
            display: combinedProduct.specs['display']?.toString() ?? '',
            processor: combinedProduct.specs['processor']?.toString() ?? '',
            ram: combinedProduct.specs['ram']?.toString() ?? '',
            storage: combinedProduct.specs['storage']?.toString() ?? '',
            battery: combinedProduct.specs['battery']?.toString() ?? '',
            rearCamera: combinedProduct.specs['rear_camera']?.toString() ?? '',
            frontCamera: combinedProduct.specs['front_camera']?.toString() ?? '',
            os: combinedProduct.specs['os']?.toString() ?? '',
            releaseDate: combinedProduct.specs['release_date']?.toString() ?? '',
            marketStatus: combinedProduct.specs['market_status']?.toString() ?? '',
            description: combinedProduct.specs['description']?.toString() ?? '',
          ); 
          _loading = false; 
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          _DetailAppBar(product: p),
          _TabBar(controller: _tab, tabs: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _OverviewTab(product: p, detail: _detail, loading: _loading),
                _PlaceholderTab('Price history aayegi...'),
                _SpecsTab(detail: _detail, loading: _loading),
                _PlaceholderTab('User reviews aayenge...'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBuyBar(product: p),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  final Product product;
  const _DetailAppBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8, right: 16, bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Text('Home › Mobiles › ${product.name}',
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.share_outlined, color: Color(0xFF555555)),
        ],
      ),
    );
  }
}


class _TabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  const _TabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: const Color(0xFFE02020),
        unselectedLabelColor: const Color(0xFF555555),
        indicatorColor: const Color(0xFFE02020),
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
      ),
    );
  }
}


class _OverviewTab extends StatelessWidget {
  final Product product;
  final ProductDetail? detail;
  final bool loading;
  const _OverviewTab({required this.product, this.detail, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductHero(product: product),
          _KeySpecsCard(detail: detail, loading: loading),
          if (detail?.description.isNotEmpty == true)
            _DescriptionCard(text: detail!.description),
          if (detail?.pros.isNotEmpty == true || detail?.cons.isNotEmpty == true)
            _ProsConsCard(pros: detail?.pros ?? [], cons: detail?.cons ?? []),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}


class _ProductHero extends StatelessWidget {
  final Product product;
  const _ProductHero({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      child: const Text('Motorola',
                          style: TextStyle(
                              color: Color(0xFFE02020),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 2),
                    Text('Last Updated: 4th May 2026',
                        style: const TextStyle(
                            color: Color(0xFF999999), fontSize: 11)),
                  ],
                ),
              ),
              if (product.rating.isNotEmpty) _RatingCircle(rating: product.rating),
            ],
          ),
          const SizedBox(height: 16),

          // Image
          Center(
            child: Image.network(
              product.image,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.phone_android, size: 100, color: Color(0xFFDDDDDD)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_library_outlined, size: 16),
              label: const Text('View Photo Gallery'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFE02020)),
            ),
          ),
          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.compare_arrows, size: 18),
                  label: const Text('Compare'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF333333),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined, size: 18),
                  label: const Text('Price Alert'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF333333),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _RatingCircle extends StatelessWidget {
  final String rating;
  const _RatingCircle({required this.rating});

  @override
  Widget build(BuildContext context) {
    final r = int.tryParse(rating) ?? 0;
    final color = r >= 8
        ? const Color(0xFF4CAF50)
        : r >= 6
            ? const Color(0xFFFFA000)
            : const Color(0xFFE02020);
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rating,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text('/ 10',
              style: const TextStyle(
                  fontSize: 9, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}


class _KeySpecsCard extends StatelessWidget {
  final ProductDetail? detail;
  final bool loading;
  const _KeySpecsCard({this.detail, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Specs',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 14),
          if (loading)
            const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFE02020), strokeWidth: 2))
          else
            _buildSpecsGrid(),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid() {
    final d = detail;
    final specs = <_SpecEntry>[
      if (d?.display.isNotEmpty == true)
        _SpecEntry(Icons.tv_outlined, 'Display', d!.display),
      if (d?.processor.isNotEmpty == true)
        _SpecEntry(Icons.memory_outlined, 'Processor', d!.processor),
      if (d?.frontCamera.isNotEmpty == true)
        _SpecEntry(Icons.camera_front_outlined, 'Front Camera', d!.frontCamera),
      if (d?.rearCamera.isNotEmpty == true)
        _SpecEntry(Icons.camera_rear_outlined, 'Rear Camera', d!.rearCamera),
      if (d?.ram.isNotEmpty == true)
        _SpecEntry(Icons.storage_outlined, 'RAM', d!.ram),
      if (d?.storage.isNotEmpty == true)
        _SpecEntry(Icons.sd_storage_outlined, 'Storage', d!.storage),
      if (d?.battery.isNotEmpty == true)
        _SpecEntry(Icons.battery_charging_full_outlined, 'Battery', d!.battery),
      if (d?.os.isNotEmpty == true)
        _SpecEntry(Icons.android_outlined, 'OS', d!.os),
    ];

    if (specs.isEmpty) {
      return const Text('Specs load nahi hui. Gadgets360 pe dekho.',
          style: TextStyle(color: Color(0xFF888888), fontSize: 13));
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: specs.map((s) => _SpecTile(entry: s)).toList(),
    );
  }
}

class _SpecEntry {
  final IconData icon;
  final String label;
  final String value;
  const _SpecEntry(this.icon, this.label, this.value);
}

class _SpecTile extends StatelessWidget {
  final _SpecEntry entry;
  const _SpecTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(entry.icon, size: 18, color: const Color(0xFF555555)),
          const SizedBox(height: 4),
          Text(entry.label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Expanded(
            child: Text(entry.value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}


class _DescriptionCard extends StatefulWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  State<_DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<_DescriptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 10),
          Text(
            _expanded ? widget.text : '${widget.text.substring(0, widget.text.length.clamp(0, 200))}...',
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF555555), height: 1.6),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Read less' : 'Read more',
              style: const TextStyle(color: Color(0xFFE02020), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}


class _ProsConsCard extends StatelessWidget {
  final List<String> pros;
  final List<String> cons;
  const _ProsConsCard({required this.pros, required this.cons});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _PCColumn(label: 'Pros', items: pros, isProf: true)),
          const SizedBox(width: 12),
          Expanded(child: _PCColumn(label: 'Cons', items: cons, isProf: false)),
        ],
      ),
    );
  }
}

class _PCColumn extends StatelessWidget {
  final String label;
  final List<String> items;
  final bool isProf;
  const _PCColumn({required this.label, required this.items, required this.isProf});

  @override
  Widget build(BuildContext context) {
    final color = isProf ? const Color(0xFF388E3C) : const Color(0xFFD32F2F);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isProf ? const Color(0xFFF1F8E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isProf ? '+' : '-',
                        style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF444444)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SpecsTab extends StatelessWidget {
  final ProductDetail? detail;
  final bool loading;
  const _SpecsTab({this.detail, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE02020)));
    }
    final d = detail;
    final rows = <MapEntry<String, String>>[
      if (d?.display.isNotEmpty == true) MapEntry('Display', d!.display),
      if (d?.processor.isNotEmpty == true) MapEntry('Processor', d!.processor),
      if (d?.ram.isNotEmpty == true) MapEntry('RAM', d!.ram),
      if (d?.storage.isNotEmpty == true) MapEntry('Storage', d!.storage),
      if (d?.battery.isNotEmpty == true) MapEntry('Battery Capacity', d!.battery),
      if (d?.rearCamera.isNotEmpty == true) MapEntry('Rear Camera', d!.rearCamera),
      if (d?.frontCamera.isNotEmpty == true) MapEntry('Front Camera', d!.frontCamera),
      if (d?.os.isNotEmpty == true) MapEntry('OS', d!.os),
      if (d?.releaseDate.isNotEmpty == true) MapEntry('Release Date', d!.releaseDate),
      if (d?.marketStatus.isNotEmpty == true) MapEntry('Market Status', d!.marketStatus),
    ];

    if (rows.isEmpty) {
      return const Center(
          child: Text('Full specs ke liye Gadgets360 pe jaao',
              style: TextStyle(color: Color(0xFF888888))));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: rows.asMap().entries.map((e) {
              final isLast = e.key == rows.length - 1;
              return Container(
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: Color(0xFFF0F0F0))),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(e.value.key,
                          style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(e.value.value,
                          style: const TextStyle(
                              color: Color(0xFF222222),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String msg;
  const _PlaceholderTab(this.msg);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(msg,
            style:
                const TextStyle(color: Color(0xFF888888), fontSize: 14)),
      );
}


class _BottomBuyBar extends StatelessWidget {
  final Product product;
  const _BottomBuyBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product.price;
    final mrp = product.formattedMrp;
    final disc = product.discountPercent;

    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (price.isNotEmpty)
                  Text('₹$price',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A))),
                if (mrp.isNotEmpty && disc > 0)
                  Row(
                    children: [
                      Text(mrp,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                              decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 6),
                      Text('$disc% off',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF388E3C),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE02020),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('BUY',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
