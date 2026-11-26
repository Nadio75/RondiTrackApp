import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/theme/rondi_theme.dart';
import 'package:ronditrack/features/home/presentation/stokvel_summary_card.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';

void main() {
  const stokvel = Stokvel(
    id: 'golden-test-stokvel',
    name: 'Community Savings',
    description: 'Synthetic savings club',
    monthlyContributionCents: Cents(50000),
  );

  Widget buildCard({
    required bool dark,
    required StokvelRole role,
    required ContributionStatus status,
  }) {
    final theme = dark ? RondiTheme.dark : RondiTheme.light;

    return Theme(
      data: theme,
      child: Material(
        color: theme.colorScheme.surface,
        child: SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: StokvelSummaryCard(
              stokvel: stokvel,
              role: role,
              contributionStatus: status,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    goldenTest(
      'Stokvel summary card $mode mode',
      fileName: 'stokvel_summary_card_$mode',
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          GoldenTestScenario(
            name: 'Treasurer - Up to date',
            child: buildCard(
              dark: dark,
              role: StokvelRole.treasurer,
              status: ContributionStatus.paid,
            ),
          ),
          GoldenTestScenario(
            name: 'Member - In arrears',
            child: buildCard(
              dark: dark,
              role: StokvelRole.member,
              status: ContributionStatus.overdue,
            ),
          ),
          GoldenTestScenario(
            name: 'Member - Unknown status',
            child: buildCard(
              dark: dark,
              role: StokvelRole.member,
              status: ContributionStatus.unknown,
            ),
          ),
        ],
      ),
    );
  }

  testWidgets('Standalone card preserves its tap action', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: RondiTheme.light,
        home: Scaffold(
          body: StokvelSummaryCard(
            stokvel: stokvel,
            role: StokvelRole.treasurer,
            contributionStatus: ContributionStatus.paid,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Community Savings'), findsOneWidget);
    expect(find.text('Role: Treasurer'), findsOneWidget);

    await tester.tap(find.byType(StokvelSummaryCard));
    await tester.pump();

    expect(taps, 1);
  });
}
