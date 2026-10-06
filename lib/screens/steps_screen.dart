import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/step_service.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final StepService _stepService = StepService();

  static const int dailyGoal = 10000;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _stepsStream;

  bool _isAdding = false;

  @override
  void initState() {
    super.initState();

    // Create the stream ONCE.
    // Do not recreate it every time build() runs.
    _stepsStream = _stepService.watchTodaySteps();
  }

  // ============================================================
  // ADD STEPS
  // ============================================================

  Future<void> _addSteps(int amount) async {
    if (_isAdding || amount <= 0) {
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      await _stepService.addSteps(amount);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add steps: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  // ============================================================
  // CUSTOM STEPS
  // ============================================================

Future<void> _showCustomStepDialog() async {
  final result = await showDialog<int>(
    context: context,
    builder: (dialogContext) {
      final controller = TextEditingController();

      return AlertDialog(
        title: const Text(
          'Add Steps',
        ),

        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,

          autofocus: true,

          decoration: const InputDecoration(
            labelText: 'Number of steps',
            hintText: 'Example: 853',
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },

            child: const Text(
              'Cancel',
            ),
          ),

          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(
                controller.text.trim(),
              );

              if (value != null && value > 0) {
                Navigator.of(dialogContext).pop(
                  value,
                );
              }
            },

            child: const Text(
              'Add',
            ),
          ),
        ],
      );
    },
  );

  if (!mounted) return;

  if (result != null) {
    // Give the dialog route a moment to finish
    // before triggering the Firestore update/rebuild.
    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    if (!mounted) return;

    await _addSteps(result);
  }
}

  // ============================================================
  // FORMAT NUMBER
  // ============================================================

  String _formatNumber(int number) {
    return number
        .toString()
        .replaceAllMapped(
          RegExp(
            r'(\d)(?=(\d{3})+(?!\d))',
          ),
          (match) =>
              '${match.group(1)},',
        );
  }

  // ============================================================
  // GET STEPS VALUE SAFELY
  // ============================================================

  int _getSteps(
    Map<String, dynamic> data,
  ) {
    final value = data['steps'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  // ============================================================
  // GET TIME
  // ============================================================

  String _getTime(
    Map<String, dynamic> data,
  ) {
    final value = data['createdAt'];

    if (value is! Timestamp) {
      return '--:--';
    }

    final date = value.toDate();

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          'Steps',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _stepsStream,

        builder: (
          context,
          snapshot,
        ) {
          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Failed to load steps.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // DOCUMENTS
          // ==================================================

          final docs =
              snapshot.data?.docs ?? [];

          // ==================================================
          // TOTAL STEPS
          // ==================================================

          int totalSteps = 0;

          for (final doc in docs) {
            totalSteps +=
                _getSteps(doc.data());
          }

          // ==================================================
          // PROGRESS
          // ==================================================

          double progress =
              totalSteps / dailyGoal;

          if (progress > 1) {
            progress = 1;
          }

          // ==================================================
          // UI
          // ==================================================

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // TODAY'S STEPS CARD
                // ==================================================

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    25,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.cyan,
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),

                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 32,

                        backgroundColor:
                            Colors.white,

                        child: Icon(
                          Icons
                              .directions_walk,
                          color:
                              Colors.cyan,
                          size: 35,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(
                        "Today's Steps",
                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        _formatNumber(
                          totalSteps,
                        ),

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 38,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text(
                        '/ ${_formatNumber(dailyGoal)} steps',

                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),

                        child:
                            LinearProgressIndicator(
                          value:
                              progress,

                          minHeight: 12,

                          backgroundColor:
                              Colors.white30,

                          valueColor:
                              const AlwaysStoppedAnimation<
                                  Color>(
                            Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% of daily goal',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================================
                // QUICK ADD
                // ==================================================

                const Text(
                  'Quick Add',

                  style:
                      TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _quickAddButton(
                        '+500',
                        500,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          _quickAddButton(
                        '+1,000',
                        1000,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          _quickAddButton(
                        '+2,000',
                        2000,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _isAdding
                            ? null
                            : _showCustomStepDialog,

                    icon:
                        const Icon(
                      Icons.edit,
                    ),

                    label:
                        const Text(
                      'Enter Custom Steps',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================================
                // TODAY'S ACTIVITY
                // ==================================================

                const Text(
                  "Today's Activity",

                  style:
                      TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ==================================================
                // EMPTY STATE
                // ==================================================

                if (docs.isEmpty)
                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.all(
                      25,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child:
                        const Column(
                      children: [
                        Icon(
                          Icons
                              .directions_walk,
                          size: 45,
                          color:
                              Colors.grey,
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        Text(
                          'No steps recorded today',

                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )

                // ==================================================
                // ACTIVITY LIST
                // ==================================================

                else
                  ...docs.map(
                    (doc) {
                      final data =
                          doc.data();

                      final steps =
                          _getSteps(data);

                      final time =
                          _getTime(data);

                      return Card(
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 10,
                        ),

                        elevation: 1,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),

                        child:
                            ListTile(
                          leading:
                              const CircleAvatar(
                            backgroundColor:
                                Color(
                              0xFFE0F7FA,
                            ),

                            child: Icon(
                              Icons
                                  .directions_walk,
                              color:
                                  Colors.cyan,
                            ),
                          ),

                          title:
                              Text(
                            '+${_formatNumber(steps)} steps',

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          subtitle:
                              Text(
                            time,
                          ),

                          trailing:
                              IconButton(
                            icon:
                                const Icon(
                              Icons
                                  .delete_outline,
                              color:
                                  Colors.red,
                            ),

                            onPressed:
                                _isAdding
                                    ? null
                                    : () async {
                                        try {
                                          await _stepService
                                              .deleteStepLog(
                                            doc.id,
                                          );
                                        } catch (
                                          e
                                        ) {
                                          if (!mounted) {
                                            return;
                                          }

                                          ScaffoldMessenger
                                              .of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text(
                                                'Failed to delete: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // QUICK ADD BUTTON
  // ============================================================

  Widget _quickAddButton(
    String label,
    int amount,
  ) {
    return SizedBox(
      height: 50,

      child: ElevatedButton(
        onPressed:
            _isAdding
                ? null
                : () => _addSteps(
                      amount,
                    ),

        child: _isAdding
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
      ),
    );
  }
}