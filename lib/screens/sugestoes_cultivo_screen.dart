import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/role_menu.dart';

class SugestoesCultivoScreen extends StatefulWidget {
  const SugestoesCultivoScreen({super.key});

  @override
  _SugestoesCultivoScreenState createState() => _SugestoesCultivoScreenState();
}

class _SugestoesCultivoScreenState extends State<SugestoesCultivoScreen> {
  String epocaAno = 'Primavera';
  Map<String, dynamic>? sugestoes;

  bool _isLoading = false;

  Future<void> _obterSugestoes() async {
    setState(() => _isLoading = true);
    try {
      Position position = await _determinePosition();
      var data = await ApiService.obterSugestoesCultivo(
        position.latitude,
        position.longitude,
        epocaAno,
      );
      setState(() {
        sugestoes = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _exibirSugestoes(double width) {
    String climaTemp = sugestoes?['clima']?['main']?['temp']?.toString() ??
        'Dados de temperatura não disponíveis';
    String climaDescricao =
        (sugestoes?['clima']?['weather'] as List?)?.firstWhere(
              (item) => item['description'] != null,
              orElse: () => null,
            )?['description'] ??
            'Descrição do clima não disponível';
    String dadosAgricolasTemp =
        sugestoes?['dadosAgricolas']?['main']?['temp']?.toString() ??
            'Temperatura agrícola não disponível';
    String dadosAgricolasUmidade =
        sugestoes?['dadosAgricolas']?['main']?['humidity']?.toString() ??
            'Umidade agrícola não disponível';
    String sugestaoCultivo =
        sugestoes?['sugestaoCultivo'] ?? 'Sugestão de cultivo não disponível';

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: width > 600 ? 600 : double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clima',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Temperatura: $climaTemp°C',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Descrição: $climaDescricao',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Dados Agrícolas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Temperatura: $dadosAgricolasTemp°C',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Umidade: $dadosAgricolasUmidade%',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Sugestão de Cultivo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                sugestaoCultivo,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter:
            10
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text(
            'Sugestões de Cultivo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _obterSugestoes(),
              tooltip: 'Atualizar Sugestões',
            ),
          ),
        ],
      ),
      bottomNavigationBar: FutureBuilder<String?>(
        future: AuthService.getRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const RoleBasedMenu(role: 'Cliente');
          }
          return RoleBasedMenu(role: snapshot.data!);
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: width > 600 ? 600 : double.infinity,
                      child: DropdownButtonFormField<String>(
                        value: epocaAno,
                        onChanged: (value) {
                          setState(() => epocaAno = value!);
                        },
                        decoration: InputDecoration(
                          labelText: 'Selecione a Estação do Ano',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Primavera', child: Text('Primavera')),
                          DropdownMenuItem(value: 'Verão', child: Text('Verão')),
                          DropdownMenuItem(value: 'Outono', child: Text('Outono')),
                          DropdownMenuItem(
                              value: 'Inverno', child: Text('Inverno')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : sugestoes != null
                            ? _exibirSugestoes(width)
                            : const Text(
                                'Clique em "Obter Sugestões" para visualizar.'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _obterSugestoes,
        label: const Text('Obter Sugestões'),
        icon: const Icon(Icons.cloud_download),
      ),
    );
  }
}
