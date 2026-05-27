import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/combined_product_detail_screen.dart';
import '../services/combined_api_service.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _ctrl   = TextEditingController();
  final _focus  = FocusNode();

  List<CombinedProduct> _results = [];
  bool  _loading = false;
  bool  _hasError = false;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
    _ctrl.addListener(_onType);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onType() {
    final q = _ctrl.text.trim();
    if (q == _query) return;
    _query = q;

    if (q.length < 3) {
      setState(() { _results = []; _hasError = false; });
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1200), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (!mounted) return;
    setState(() { _loading = true; _hasError = false; });

    try {
      final products = await CombinedApiService.searchProducts(q);
      if (_query == q && mounted) {
        setState(() { _results = products; });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (_query == q && mounted) {
        setState(() { _results = []; _hasError = true; });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 540,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchBar(
              ctrl: _ctrl,
              focus: _focus,
              onClose: () => Navigator.pop(context),
            ),

            // Progress bar
            if (_loading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFFE02020),
                backgroundColor: Colors.transparent,
              ),

            // Results
            if (_results.isNotEmpty)
              _ResultsList(results: _results, query: _query),

            // Empty state (searched, no results)
            if (_query.length >= 2 && !_loading && _results.isEmpty && !_hasError)
              const _EmptyState(),

            // Error state
            if (_hasError)
              _ErrorState(onRetry: () => _search(_query)),

            // Hint (not yet typed enough)
            if (_query.length < 2 && !_loading)
              const _HintState(),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final VoidCallback onClose;

  const _SearchBar({
    required this.ctrl,
    required this.focus,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF666666), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              style: const TextStyle(fontSize: 16, color: Color(0xFF222222)),
              decoration: const InputDecoration(
                hintText: 'Search phones, laptops, tablets…',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child:
              const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Results List ─────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<CombinedProduct> results;
  final String query;

  const _ResultsList({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              itemBuilder: (ctx, i) => _ProductTile(product: results[i]),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Search "$query" in:',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _PillBtn('ARTICLES'),
                const SizedBox(width: 12),
                _PillBtn('PRODUCTS'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final CombinedProduct product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product.images.isNotEmpty ? product.images.first : '';
    final price =
    product.price.isNotEmpty ? product.price.first.price : '';

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CombinedProductDetailScreen(productName: product.name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: image.isNotEmpty && image.startsWith('http')
                  ? Image.network(
                      image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 56,
                          height: 56,
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCCCCCC)),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('❌ Image load error: $error');
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 14),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF222222)),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (product.brand.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE02020).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.brand,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE02020),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (price.isNotEmpty)
                        Text(
                          price,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF555555)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 56,
    height: 56,
    color: const Color(0xFFF5F5F5),
    child: const Icon(Icons.phone_android, color: Color(0xFFCCCCCC)),
  );
}

// ─── Pill Button ─────────────────────────────────────────────────────────────

class _PillBtn extends StatelessWidget {
  final String label;
  const _PillBtn(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF6B6B6B),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13),
        ),
      ),
    );
  }
}

// ─── State Widgets ────────────────────────────────────────────────────────────

class _HintState extends StatelessWidget {
  const _HintState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search, size: 36, color: Color(0xFFCCCCCC)),
          SizedBox(height: 10),
          Text(
            'Type at least 2 characters to search',
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 40, color: Color(0xFFCCCCCC)),
          SizedBox(height: 10),
          Text(
            'Empty Data',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 10),
          const Text(
            'Not Data loaded. Check your connection.',
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                  color: Color(0xFFE02020), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}