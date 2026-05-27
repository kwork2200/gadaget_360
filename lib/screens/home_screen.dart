import 'package:flutter/material.dart';
import '../widgets/search_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          _AppBar(),
          _NavBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopStoriesBanner(),
                  const SizedBox(height: 16),
                  _TrendingSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE02020),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Gadgets\n360',
                style: TextStyle(
                  color: Color(0xFFE02020),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _NavItem('HOME'),
                    _NavItem('AI'),
                    _NavItem('AUTO'),
                    _NavItem('NEWS'),
                    _NavItem('REVIEWS'),
                    _NavItem('MOBILES'),
                  ],
                ),
              ),
            ),

            GestureDetector(
              onTap: () => _openSearch(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => const SearchDialog(),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  const _NavItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = ['SAMSUNG ECOSYSTEM', 'MOBILES', 'TELECOM', 'HOW TO', 'GAMING', 'ENTERTAINMENT', 'CRYPTO', 'TV', 'PC/LAPTOPS'];
    return Container(
      color: Colors.white,
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: items.asMap().entries.map((e) {
            final isFirst = e.key == 0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isFirst ? const Color(0xFF1565C0) : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  color: isFirst ? Colors.white : const Color(0xFF333333),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class _TopStoriesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stories = [
      _Story(
        color: const Color(0xFFF5A623),
        title: 'Amazon Great Summer Sale Announced: Check Sale Date, Bank Offers and More',
        emoji: '🔥',
      ),
      _Story(
        color: const Color(0xFF1A1A2E),
        title: 'AI Actors and Scripts Officially Banned From Winning Gold at Oscars',
        emoji: '🏆',
      ),
      _Story(
        color: const Color(0xFF2D4A6E),
        title: 'Here Are the Top iPhone Discounts During Flipkart\'s Upcoming Summer Sale',
        emoji: '📱',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text(
            'TOP STORIES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _StoryCard(story: stories[i]),
          ),
        ),
      ],
    );
  }
}

class _Story {
  final Color color;
  final String title;
  final String emoji;
  const _Story({required this.color, required this.title, required this.emoji});
}

class _StoryCard extends StatelessWidget {
  final _Story story;
  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.7;
    return Container(
      width: w.clamp(240, 340),
      decoration: BoxDecoration(
        color: story.color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(story.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            story.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


class _TrendingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFE02020),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TRENDING',
                style: TextStyle(
                  color: Color(0xFFE02020),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._trendingItems.map((t) => _TrendingItem(text: t)),
          const SizedBox(height: 24),
          _SearchPromo(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static const _trendingItems = [
    'Amazon Great Summer Sale: Best Deals on Smartphones Teased',
    'As Component Prices Drop, PC Parts Getting Cheaper',
    'Moto G47 Launched in India at Rs. 11,999',
    'Samsung Galaxy Unpacked 2026 Event Confirmed',
  ];
}

class _TrendingItem extends StatelessWidget {
  final String text;
  const _TrendingItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Color(0xFFE02020), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 18),
        ],
      ),
    );
  }
}

class _SearchPromo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black45,
        builder: (_) => const SearchDialog(),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Finder',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  Text('Search Any gadget',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Search',
                  style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
