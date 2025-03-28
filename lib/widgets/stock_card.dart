import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/utils/stock_utils.dart';
import 'package:stockwise/constants/theme_constants.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;
  final bool isInWatchlist;
  final Function(bool)? onWatchlistToggle;

  const StockCard({
    Key? key,
    required this.stock,
    required this.onTap,
    this.isInWatchlist = false,
    this.onWatchlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          stock.exchange,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      StockUtils.formatPrice(stock.price, stock.currency),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          StockUtils.getPriceChangeIcon(stock.change),
                          color: StockUtils.getPriceChangeColor(stock.change),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          StockUtils.formatPercentageChange(stock.percentChange),
                          style: TextStyle(
                            color: StockUtils.getPriceChangeColor(stock.change),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vol: ${StockUtils.formatLargeNumber(stock.volume)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onWatchlistToggle != null)
                IconButton(
                  icon: Icon(
                    isInWatchlist ? Icons.star : Icons.star_border,
                    color: isInWatchlist ? ThemeConstants.accentColor : null,
                  ),
                  onPressed: () => onWatchlistToggle!(!isInWatchlist),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
