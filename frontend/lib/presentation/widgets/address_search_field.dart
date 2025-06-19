import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/services/places_service.dart';

class AddressSearchField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final String? Function(String?)? validator;
  final Function(String address, LatLng coordinates)? onAddressSelected;
  final TextEditingController? controller;

  const AddressSearchField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.prefixIconColor,
    this.validator,
    this.onAddressSelected,
    this.controller,
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final PlacesService _placesService = PlacesService();
  final FocusNode _focusNode = FocusNode();
  
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showPredictions = false;
  String? _errorMessage;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final predictions = await _placesService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _predictions = predictions;
          _showPredictions = predictions.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao buscar endereços: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    setState(() {
      _isLoading = true;
      _showPredictions = false;
    });

    try {
      final coordinates = await _placesService.getPlaceCoordinates(prediction.placeId);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (coordinates != null) {
          widget.controller?.text = prediction.description;
          widget.onAddressSelected?.call(prediction.description, coordinates);
        } else {
          setState(() {
            _errorMessage = 'Não foi possível obter as coordenadas do endereço';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao selecionar endereço: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: widget.prefixIconColor)
                : null,
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          validator: widget.validator,
          onChanged: _searchPlaces,
          onTap: () {
            if (widget.controller?.text.isNotEmpty == true) {
              _searchPlaces(widget.controller!.text);
            }
          },
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
        if (_showPredictions && _predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _predictions.length > 5 ? 5 : _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    prediction.mainText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: prediction.secondaryText.isNotEmpty
                      ? Text(
                          prediction.secondaryText,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () => _selectPlace(prediction),
                );
              },
            ),
          ),
      ],
    );
  }
} 