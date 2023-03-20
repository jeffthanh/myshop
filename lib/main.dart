import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';


import 'ui/screens.dart';
void main() async{
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Create and provide AuthManager
        ChangeNotifierProvider(
          create: (ctx) => AuthManager(),
        ),
        ChangeNotifierProxyProvider<AuthManager, ProductsManager>(
          create: (ctx) => ProductsManager(),
          update: (ctx, authManager, productsManager){
            // khi authManager co bao hieu thay doi thi doc lai authToken cho productsManager
            productsManager!.authToken=authManager.authToken;
            return productsManager;
          },
        ),
        
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrdersManager(), 
        ),
      ],
      child: Consumer<AuthManager>(
        builder: (context,AuthManager , child) {
          return MaterialApp(
            title: 'MyShop',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Lato',
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.purple,
              ).copyWith(
                secondary: Colors.deepOrange,
              ),
            ),
            home: AuthManager.isAuth ? const ProductsOverviewScreen()
              :FutureBuilder(
                future: AuthManager.tryAutoLogin(),
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                    ? const SplashScreen()
                    : const AuthScreen();
                },
              ),
            routes: {
              CartScreen.routeName:
                (ctx) => const CartScreen(),
              OrdersScreen.routeName:
                (ctx) => const OrdersScreen(),
              UserProductsScreen.routeName:
                (ctx) => const UserProductsScreen(),
            },
            onGenerateRoute: (settings){
              if (settings.name == EditProductScreen.routeName) {
                final productId = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (ctx) {
                    return EditProductScreen(
                      productId != null
                      ? ctx.read<ProductsManager>().findById(productId)
                      : null,
                    );
                  },
                );
              }
              return null;
            },
          );
        }
      ),
    );
  }
}
