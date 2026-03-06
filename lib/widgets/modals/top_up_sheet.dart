import 'package:flutter/material.dart';

class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key});

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  final List<int> presets = [100, 200, 300, 400, 500, 1000];
  int? selectedAmount;
  final TextEditingController customController = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  void _selectPreset(int amount) {
    setState(() {
      selectedAmount = amount;
      customController.text = amount.toString();
      errorText = null;
    });
  }

  void _onCustomChanged(String value) {
    final int? val = int.tryParse(value);
    setState(() {
      selectedAmount = val;
      if (val == null) {
        errorText = 'Enter a valid number';
      } else if (val < 100) {
        errorText = 'Minimum is ₱100';
      } else if (val > 1000) {
        errorText = 'Maximum is ₱1000';
      } else {
        errorText = null;
      }
    });
  }

  void _confirm() {
    if (selectedAmount == null) {
      setState(() => errorText = 'Please select or enter an amount');
      return;
    }
    if (selectedAmount! < 100 || selectedAmount! > 1000) {
      setState(() => errorText = 'Amount must be between ₱100 and ₱1000');
      return;
    }
    Navigator.pop(context, selectedAmount!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          const Center(
            child: Text(
              'Top Up Load Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D8AA8),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Preset amount chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((amount) {
              final bool selected = selectedAmount == amount;
              return ChoiceChip(
                label: Text('₱$amount'),
                selected: selected,
                onSelected: (_) => _selectPreset(amount),
                selectedColor: const Color(0xFF5D8AA8),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF5D8AA8),
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Custom amount field
          TextFormField(
            controller: customController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Custom Amount',
              prefixText: '₱',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              errorText: errorText,
            ),
            onChanged: _onCustomChanged,
          ),

          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D8AA8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _confirm,
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
