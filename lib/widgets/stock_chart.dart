import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stockwise/models/historical_data.dart';
import 'package:stockwise/utils/stock_utils.dart';
import 'package:stockwise/constants/theme_constants.dart';
import 'package:intl/intl.dart';

class StockChart extends StatelessWidget {
  final List<HistoricalData> data;
  final String timeRange;
  final Function(String) onTimeRangeChanged;

  const StockChart({
    Key? key,
    required this.data,
    required this.timeRange,
    required this.onTimeRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final minMax = StockUtils.getChartMinMax(data);
    final isPositive = data.first.close <= data.last.close;
    final chartColor = isPositive 
        ? ThemeConstants.positiveColor 
        : ThemeConstants.negativeColor;

    return Column(
      children: [
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (minMax['max']! - minMax['min']!) / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: data.length > 30 ? data.length / 5 : 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final date = data[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (minMax['max']! - minMax['min']!) / 4,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: minMax['min'],
              maxY: minMax['max'],
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(data.length, (index) {
                    return FlSpot(
                      index.toDouble(),
                      data[index].close,
                    );
                  }),
                  isCurved: true,
                  color: chartColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: chartColor.withOpacity(0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Theme.of(context).cardColor,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final index = touchedSpot.x.toInt();
                      if (index >= 0 && index < data.length) {
                        final item = data[index];
                        return LineTooltipItem(
                          '${DateFormat('MM/dd/yyyy').format(item.date)}\n',
                          const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Open: ${item.open.toStringAsFixed(2)}\n',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: 'Close: ${item.close.toStringAsFixed(2)}\n',
                              style: TextStyle(
                                color: chartColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'High: ${item.high.toStringAsFixed(2)}\n',
                              style: const TextStyle(
                                color: ThemeConstants.positiveColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: 'Low: ${item.low.toStringAsFixed(2)}\n',
                              style: const TextStyle(
                                color: ThemeConstants.negativeColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: 'Vol: ${StockUtils.formatLargeNumber(item.volume)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        _buildTimeRangeSelector(),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _timeRangeButton('1D'),
          _timeRangeButton('1W'),
          _timeRangeButton('1M'),
          _timeRangeButton('3M'),
          _timeRangeButton('6M'),
          _timeRangeButton('1Y'),
          _timeRangeButton('5Y'),
        ],
      ),
    );
  }

  Widget _timeRangeButton(String range) {
    final isSelected = timeRange == range;
    
    return InkWell(
      onTap: () => onTimeRangeChanged(range),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? ThemeConstants.primaryColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
