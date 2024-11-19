import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:greenroof_app/screens/cadastro_produto_fornecedor_screen.dart';
import 'package:greenroof_app/screens/cadastro_producao_screen.dart';
import 'package:greenroof_app/screens/clientes_screen.dart';
import 'package:greenroof_app/screens/controle_producao_screen.dart';
import 'package:greenroof_app/screens/fornecedores_screen.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/carrinho_provider.dart';
import 'providers/produto_provider.dart';
import 'screens/carrinho_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pagamento_screen.dart';
import 'screens/produtos_screen.dart';
import 'screens/trocar_senha_screen.dart';
import 'screens/cadastro_cliente_screen.dart';
import 'screens/cadastro_fornecedor_screen.dart';
import 'screens/cadastro_produto_screen.dart';
import 'screens/controle_vendas_screen.dart';
import 'screens/sugestoes_cultivo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProdutoProvider()),
        ChangeNotifierProvider(create: (_) => CarrinhoProvider()),
      ],
      child: FutureBuilder<String?>(
        future: AuthService.getRole(),
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Greenroof',
            theme: ThemeData(
              colorScheme: const ColorScheme(
                brightness: Brightness.light,
                primary: Color(0xFF4CAF50),
                onPrimary: Colors.white,
                secondary: Color(0xFF4CAF49),
                onSecondary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
                error: Color(0xFFB00020),
                onError: Colors.white,
              ),
              textTheme: ThemeData.light().textTheme.copyWith(
                    headlineMedium: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => LoginScreen(),
              '/produtos': (context) => const ProdutosScreen(),
              '/trocar-senha': (context) => TrocarSenhaScreen(),
              '/carrinho': (context) => const CarrinhoScreen(),
              '/cadastro-cliente': (context) => const CadastroClienteScreen(),
              '/cadastro-fornecedor': (context) =>
                  const CadastroFornecedorScreen(),
              '/cadastro-produto': (context) => const CadastroProdutoScreen(),
              '/controle-vendas': (context) => const ControleVendasScreen(),
              '/sugestoes-cultivo': (context) => const SugestoesCultivoScreen(),
              '/fornecedores': (context) => const FornecedoresScreen(),
              '/clientes': (context) => const ClientesScreen(),
              '/cadastro-produtos-fornecedor': (context) =>
                  const CadastroProdutoFornecedorScreen(),
              '/cadastro-producao': (context) => const CadastroProducaoScreen(),
              '/controle-producao': (context) => const ControleProducaoScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/pagamento') {
                final pedidoId = settings.arguments as int?;
                if (pedidoId != null) {
                  return MaterialPageRoute(
                    builder: (context) => PagamentoScreen(pedidoId: pedidoId),
                    settings: settings,
                  );
                }
              }
              return null;
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const ProdutosScreen(),
              );
            },
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('pt', 'BR'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
