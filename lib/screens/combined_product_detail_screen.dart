import 'package:flutter/material.dart';
import '../services/combined_api_service.dart';

class CombinedProductDetailScreen extends StatefulWidget {
  final String productName;
  const CombinedProductDetailScreen({super.key, required this.productName});

  @override
  State<CombinedProductDetailScreen> createState() => _CombinedProductDetailScreenState();
}

class _CombinedProductDetailScreenState extends State<CombinedProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CombinedProduct? _product;
  bool _loading = true;
  String? _error;

  final _tabs = const ['Overview', 'Gallery', 'Prices', 'Specs'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadProductData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    try {
      setState(() { _loading = true; _error = null; });
      final product = await CombinedApiService.fetchProductData(widget.productName);
      if (mounted) {
        setState(() { 
          _product = product; 
          _loading = false; 
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { 
          _error = e.toString(); 
          _loading = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          _DetailAppBar(productName: widget.productName),
          _TabBar(controller: _tabController, tabs: _tabs),
          Expanded(
            child: _loading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE02020)))
                : _error != null
                    ? _ErrorWidget(error: _error!, onRetry: _loadProductData)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _OverviewTab(product: _product!),
                          _GalleryTab(product: _product!),
                          _PricesTab(product: _product!),
                          _SpecsTab(product: _product!),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _product != null ? _BottomBuyBar(product: _product!) : null,
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  final String productName;
  const _DetailAppBar({required this.productName});

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
                Text('Home › Mobiles › $productName',
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
  final CombinedProduct product;
  const _OverviewTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductHero(product: product),
          _KeySpecsCard(product: product),
          if (product.specs.containsKey('description'))
            _DescriptionCard(text: product.specs['description'].toString()),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  final CombinedProduct product;
  const _ProductHero({required this.product});

  @override
  Widget build(BuildContext context) {
    final mainImage = product.images.isNotEmpty ? product.images.first : '';
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + brand
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
                    if (product.brand.isNotEmpty)
                      GestureDetector(
                        child: Text(product.brand,
                            style: const TextStyle(
                                color: Color(0xFFE02020),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                    const SizedBox(height: 2),
                    Text('Last Updated: ${DateTime.now().day}${_getOrdinalSuffix(DateTime.now().day)} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                        style: const TextStyle(
                            color: Color(0xFF999999), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Image
          if (mainImage.isNotEmpty)
            Center(
              child: Image.network(
                mainImage,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.phone_android, size: 100, color: Color(0xFFDDDDDD)),
              ),
            ),
          const SizedBox(height: 4),
          if (product.images.length > 1)
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: Text('View ${product.images.length} Photos'),
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

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _KeySpecsCard extends StatelessWidget {
  final CombinedProduct product;
  const _KeySpecsCard({required this.product});

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
          _buildSpecsGrid(),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid() {
    final specs = product.specs;
    final specEntries = <_SpecEntry>[
      if (specs.containsKey('display') || specs.containsKey('Display'))
        _SpecEntry(Icons.tv_outlined, 'Display', specs['display']?.toString() ?? specs['Display']?.toString() ?? ''),
      if (specs.containsKey('processor') || specs.containsKey('Processor'))
        _SpecEntry(Icons.memory_outlined, 'Processor', specs['processor']?.toString() ?? specs['Processor']?.toString() ?? ''),
      if (specs.containsKey('front_camera') || specs.containsKey('Front Camera'))
        _SpecEntry(Icons.camera_front_outlined, 'Front Camera', specs['front_camera']?.toString() ?? specs['Front Camera']?.toString() ?? ''),
      if (specs.containsKey('rear_camera') || specs.containsKey('Rear Camera'))
        _SpecEntry(Icons.camera_rear_outlined, 'Rear Camera', specs['rear_camera']?.toString() ?? specs['Rear Camera']?.toString() ?? ''),
      if (specs.containsKey('ram') || specs.containsKey('RAM'))
        _SpecEntry(Icons.storage_outlined, 'RAM', specs['ram']?.toString() ?? specs['RAM']?.toString() ?? ''),
      if (specs.containsKey('storage') || specs.containsKey('Storage'))
        _SpecEntry(Icons.sd_storage_outlined, 'Storage', specs['storage']?.toString() ?? specs['Storage']?.toString() ?? ''),
      if (specs.containsKey('battery') || specs.containsKey('Battery'))
        _SpecEntry(Icons.battery_charging_full_outlined, 'Battery', specs['battery']?.toString() ?? specs['Battery']?.toString() ?? ''),
      if (specs.containsKey('os') || specs.containsKey('OS'))
        _SpecEntry(Icons.android_outlined, 'OS', specs['os']?.toString() ?? specs['OS']?.toString() ?? ''),
    ].where((entry) => entry.value.isNotEmpty).toList();

    if (specEntries.isEmpty) {
      return const Text('No specifications available.',
          style: TextStyle(color: Color(0xFF888888), fontSize: 13));
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: specEntries.map((s) => _SpecTile(entry: s)).toList(),
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

class _GalleryTab extends StatelessWidget {
  final CombinedProduct product;
  const _GalleryTab({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.images.isEmpty) {
      return const Center(
        child: Text('No images available',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: product.images.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.images[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.image_not_supported, color: Color(0xFFCCCCCC)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PricesTab extends StatelessWidget {
  final CombinedProduct product;
  const _PricesTab({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.price.isEmpty) {
      return const Center(
        child: Text('No price information available',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: product.price.length,
      itemBuilder: (context, index) {
        final priceInfo = product.price[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFE02020)),
            title: Text(
              priceInfo.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              priceInfo.link.contains('amazon') ? 'Amazon' : 
              priceInfo.link.contains('flipkart') ? 'Flipkart' : 'Other Store',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceInfo.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE02020),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('BUY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpecsTab extends StatelessWidget {
  final CombinedProduct product;
  const _SpecsTab({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.specs.isEmpty) {
      return const Center(
        child: Text('No specifications available',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
      );
    }

    final specEntries = product.specs.entries.toList();
    
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: specEntries.asMap().entries.map((e) {
              final isLast = e.key == specEntries.length - 1;
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
                      child: Text(
                          _formatSpecKey(e.value.key),
                          style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(e.value.value?.toString() ?? 'N/A',
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

  String _formatSpecKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFE02020)),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE02020),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBuyBar extends StatelessWidget {
  final CombinedProduct product;
  const _BottomBuyBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final bestPrice = product.price.isNotEmpty ? product.price.first.price : 'Price not available';
    
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
                if (bestPrice != 'Price not available')
                  Text(bestPrice,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A))),
                if (product.price.length > 1)
                  Text('${product.price.length} stores available',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999))),
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
            child: const Text('VIEW PRICES',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
