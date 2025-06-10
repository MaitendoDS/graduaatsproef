import 'package:flutter/material.dart';

import '../constants/food_constants.dart';
import '../models/food_data.dart';
import '../services/food_service.dart';
import '../widgets/forms/food_form.dart';

class FoodTab extends StatefulWidget {
  final DateTime selectedDay;

  const FoodTab({super.key, required this.selectedDay});

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  bool _isLoading = false;

  Future<void> _handleSave(FoodData foodData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FoodService.saveFoodEntry(foodData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(FoodConstants.successMessage),
            backgroundColor: FoodConstants.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = FoodConstants.noUserMessage;
        
        if (e.toString().contains('Geen gebruiker ingelogd')) {
          errorMessage = FoodConstants.noUserMessage;
        } else {
          errorMessage = '${FoodConstants.saveErrorPrefix}$e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: FoodConstants.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodConstants.backgroundGrey,
      appBar: AppBar(
        title: const Text(FoodConstants.appBarTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: FoodConstants.primaryFoodColor,
                  ),
                  SizedBox(height: 16),
                  Text('Bezig met opslaan...'),
                ],
              ),
            )
          :
           FoodForm(
              selectedDay: widget.selectedDay,
              onSave: _handleSave,
            ),
    );
  }
}