import 'package:material_ui/material_ui.dart';
import '../../core/theme.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, this.size = 56});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.scoreColor(score);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        score.toStringAsFixed(0),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
