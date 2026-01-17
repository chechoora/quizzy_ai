import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/view/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/settings/in_app_features/cubit/in_app_features_cubit.dart';

class SettingsInAppFeaturesWidget extends HookWidget {
  const SettingsInAppFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => InAppFeaturesCubit(
        inAppPurchaseService: getIt<InAppPurchaseService>(),
      ),
    );

    useEffect(() {
      cubit.loadFeatures();
      return cubit.close;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Features'),
      ),
      body: BlocConsumer<InAppFeaturesCubit, InAppFeaturesState>(
        bloc: cubit,
        buildWhen: (prevState, nextState) {
          return nextState is BuilderState;
        },
        builder: (BuildContext context, state) {
          if (state is InAppFeaturesDataState) {
            return _InAppFeaturesContent(
              isUnlimitedDecksCardsPurchased:
                  state.isUnlimitedDecksCardsPurchased,
              onPurchaseUnlimitedDecksCards: cubit.purchaseUnlimitedDecksCards,
              onRestorePurchases: cubit.restorePurchases,
            );
          }
          if (state is InAppFeaturesLoadingState ||
              state is InAppFeaturesPurchasingState ||
              state is InAppFeaturesRestoringState) {
            return const SimpleLoadingWidget();
          }
          throw ArgumentError('Wrong state: $state');
        },
        listenWhen: (prevState, nextState) {
          return nextState is ListenerState;
        },
        listener: (BuildContext context, InAppFeaturesState state) {
          if (state is InAppFeaturesPurchaseSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase successful!'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is InAppFeaturesRestoreSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchases restored successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is InAppFeaturesErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}

class _InAppFeaturesContent extends StatelessWidget {
  const _InAppFeaturesContent({
    required this.isUnlimitedDecksCardsPurchased,
    required this.onPurchaseUnlimitedDecksCards,
    required this.onRestorePurchases,
  });

  final bool isUnlimitedDecksCardsPurchased;
  final VoidCallback onPurchaseUnlimitedDecksCards;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.all_inclusive, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unlimited Decks & Cards',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create unlimited decks and cards without restrictions.',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isUnlimitedDecksCardsPurchased)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Purchased',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPurchaseUnlimitedDecksCards,
                      child: const Text('Purchase'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: onRestorePurchases,
          icon: const Icon(Icons.restore),
          label: const Text('Restore Purchases'),
        ),
      ],
    );
  }
}
