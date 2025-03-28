import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';

class MarketOverviewCard extends StatelessWidget {
  final List<Stock> gainers;
  final List<Stock> losers;

  const MarketOverviewCard({
    Key? key,
    required this.gainers,
    required this.losers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Market Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Market movers
            Row(
              children: [
                // Top Gainers
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Top Gainers',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...gainers
                          .take(3)
                          .map((stock) => _buildStockItem(context, stock, true))
                          .toList(),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Top Losers
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_down,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Top Losers',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...losers
                          .take(3)
                          .map((stock) => _buildStockItem(context, stock, false))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(BuildContext context, Stock stock, bool isGainer) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              stock.symbol,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '\$${stock.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${isGainer ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isGainer ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
