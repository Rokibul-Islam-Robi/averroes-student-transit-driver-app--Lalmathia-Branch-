import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';

class LiveNowCard extends StatefulWidget {
  final double width;
  final double height;

  const LiveNowCard({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<LiveNowCard> createState() => _LiveNowCardState();
}

class _LiveNowCardState extends State<LiveNowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.all(widget.width / 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFF4B2B), Color(0xffFF416C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFF416C).withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: widget.width / 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((_pulseAnimation.value * 255).round().clamp(0, 255)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "LIVE NOW",
                          style: sansproBold.copyWith(
                            fontSize: 11,
                            color: WireframeColor.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  "Physics - Chapter 4",
                  overflow: TextOverflow.ellipsis,
                  style: sansproBold.copyWith(
                    fontSize: 16,
                    color: WireframeColor.white,
                  ),
                ),
                Text(
                  "Mr. Tanvir • Ongoing",
                  style: sansproRegular.copyWith(
                    fontSize: 12,
                    color: Colors.white.withAlpha(210),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xffFF416C),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Join",
              style: sansproBold.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}