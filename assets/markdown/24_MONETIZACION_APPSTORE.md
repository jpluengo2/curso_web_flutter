# Monetización y App Stores en Flutter

## Introducción a Monetización

Existen múltiples estrategias para monetizar apps Flutter:

- 💰 In-App Purchases
- 📺 Publicidad (Ads)
- 🎁 Suscripciones
- 🛍️ Compras directas
- 🎮 Freemium

---

## 1. In-App Purchases (IAP)

### 1.1 Setup Inicial

```yaml
dependencies:
  in_app_purchase: ^3.1.0
```

### 1.2 Configuración Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="com.android.vending.BILLING" />
```

En Google Play Console:
1. Crear productos "In-App"
2. Definir ID (ej: premium_feature)
3. Establecer precios
4. Publicar

### 1.3 Configuración iOS

En App Store Connect:
1. Crear "In-App Purchases"
2. Definir producto
3. Establecer precio y duración
4. Enviar para review

### 1.4 Implementar IAP

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static const String premiumFeatureId = 'premium_feature';
  static const String removeAdsId = 'remove_ads';

  final InAppPurchase _iap = InAppPurchase.instance;

  Future<void> initIAP() async {
    final available = await _iap.isAvailable();
    
    if (available) {
      print('IAP disponible');
    } else {
      print('IAP no disponible');
    }
  }

  // Obtener productos disponibles
  Future<List<ProductDetails>> getProducts() async {
    final productIds = <String>{premiumFeatureId, removeAdsId};
    
    final ProductDetailsResponse response = 
        await _iap.queryProductDetails(productIds);

    return response.productDetails;
  }

  // Comprar producto
  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Restaurar compras
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // Escuchar cambios en compras
  Stream<List<PurchaseDetails>> get purchaseStream {
    return _iap.purchaseStream;
  }

  // Completar compra
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  // Verificar si tiene premium
  Future<bool> hasPremiumFeature() async {
    final purchases = await _iap.queryPastPurchases();
    
    return purchases.any((purchase) => 
        purchase.productID == premiumFeatureId);
  }
}
```

### 1.5 Widget de Tienda

```dart
class IAPStore extends StatefulWidget {
  const IAPStore({Key? key}) : super(key: key);

  @override
  State<IAPStore> createState() => _IAPStoreState();
}

class _IAPStoreState extends State<IAPStore> {
  final IAPService _iapService = IAPService();
  List<ProductDetails> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _listenToPurchases();
  }

  Future<void> _loadProducts() async {
    final products = await _iapService.getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _listenToPurchases() {
    _iapService.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _iapService.completePurchase(purchase);
          _showSuccessDialog('¡Compra exitosa!');
        } else if (purchase.status == PurchaseStatus.error) {
          _showErrorDialog('Error en la compra');
        }
      }
    });
  }

  void _buyProduct(ProductDetails product) async {
    await _iapService.buyProduct(product);
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tienda')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            trailing: ElevatedButton(
              onPressed: () => _buyProduct(product),
              child: Text(product.price),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 2. Publicidad (Google AdMob)

### 2.1 Setup AdMob

```yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

1. Crear cuenta en Google AdMob
2. Crear aplicación
3. Obtener Ad Unit IDs
4. Configurar en AndroidManifest.xml

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
</manifest>
```

### 2.2 Inicializar AdMob

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Google Mobile Ads
  await MobileAds.instance.initialize();
  
  runApp(const MyApp());
}
```

### 2.3 Banner Ads

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isBannerAdReady
        ? SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: AdWidget(ad: _bannerAd),
          )
        : const SizedBox.shrink();
  }
}
```

### 2.4 Interstitial Ads

```dart
class InterstitialAdManager {
  InterstitialAd? _interstitialAd;

  Future<void> loadInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('Ad showed'),
      onAdDismissedFullScreenContent: (ad) {
        print('Ad dismissed');
        ad.dispose();
        loadInterstitialAd(); // Cargar siguiente
      },
    );

    _interstitialAd!.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
```

### 2.5 Rewarded Ads

```dart
class RewardedAdManager {
  RewardedAd? _rewardedAd;

  Future<void> loadRewardedAd() async {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd(VoidCallback onReward) {
    if (_rewardedAd == null) {
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('Ad showed'),
      onAdDismissedFullScreenContent: (ad) {
        print('Ad dismissed');
        ad.dispose();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount}');
        onReward();
      },
    );
  }
}
```

---

## 3. Suscripciones

### 3.1 Configurar Suscripciones

```dart
class SubscriptionService {
  static const String monthlyPlanId = 'monthly_subscription';
  static const String yearlyPlanId = 'yearly_subscription';

  final InAppPurchase _iap = InAppPurchase.instance;

  Future<void> subscribeMonthly() async {
    final products = await _iap.queryProductDetails({monthlyPlanId});
    
    if (products.productDetails.isNotEmpty) {
      final product = products.productDetails.first;
      
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    }
  }

  Future<bool> hasActiveSubscription() async {
    final purchases = await _iap.queryPastPurchases();
    
    final activeSubscriptions = purchases.where((purchase) =>
        (purchase.productID == monthlyPlanId || 
         purchase.productID == yearlyPlanId) &&
        purchase.status == PurchaseStatus.purchased);

    return activeSubscriptions.isNotEmpty;
  }

  Future<void> cancelSubscription(String productId) async {
    // Implementar según plataforma
    // En iOS: El usuario cancela en App Store
    // En Android: Usar Google Play Billing Library
  }
}
```

---

## 4. Backend para Pagos

### 4.1 Validación de Recibos

```dart
import 'package:http/http.dart' as http;

class PaymentValidationService {
  // Validar compra en Google Play
  Future<bool> validateGooglePlayPurchase(
    String packageName,
    String productId,
    String token,
    String accessToken,
  ) async {
    final url = Uri.parse(
      'https://www.googleapis.com/androidpublisher/v3/applications/'
      '$packageName/purchases/products/$productId/tokens/$token'
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return response.statusCode == 200;
  }

  // Validar compra en App Store
  Future<bool> validateAppStorePurchase(String receipt) async {
    final response = await http.post(
      Uri.parse('https://buy.itunes.apple.com/verifyReceipt'),
      body: {'receipt-data': receipt},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['status'] == 0; // 0 = válido
    }

    return false;
  }
}
```

---

## 5. Analytics para Monetización

### 5.1 Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class MonetizationAnalytics {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void logPurchase({
    required String productId,
    required double price,
    required String currency,
  }) {
    _analytics.logPurchase(
      value: price,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
          itemCategory: 'premium',
          price: price,
        ),
      ],
    );
  }

  void logAdImpression(String adUnitId) {
    _analytics.logEvent(
      name: 'ad_impression',
      parameters: {
        'ad_unit_id': adUnitId,
      },
    );
  }

  void logSubscriptionStarted(String planId) {
    _analytics.logEvent(
      name: 'subscription_started',
      parameters: {
        'plan_id': planId,
      },
    );
  }
}
```

---

## 6. Distribución en App Stores

### 6.1 Google Play Store

```bash
# Generar keystore para firma
keytool -genkey -v -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias

# Build app bundle para Play Store
flutter build appbundle --release

# El archivo está en:
# build/app/outputs/bundle/release/app-release.aab

# Subir a Google Play Console:
# 1. Crear release en Google Play Console
# 2. Subir app bundle
# 3. Configurar descripción, screenshots, etc.
# 4. Enviar para review
```

### 6.2 Apple App Store

```bash
# Build iOS para App Store
flutter build ios --release

# Subir con Xcode o Application Loader:
# 1. Abrir en Xcode
# 2. Product → Archive
# 3. Distributor → App Store Connect
# 4. Configurar en App Store Connect
# 5. Enviar para review
```

---

## 7. Antipatrones en Monetización

### Antipatrón 1: No validar recibos en backend
```dart
// ❌ MALO - Confía en cliente (¡hackeable!)
if (purchaseDetails.status == PurchaseStatus.purchased) {
  unlockPremium(); // Alguien puede modificar
}

// ✅ BIEN - Validar en servidor
if (purchaseDetails.status == PurchaseStatus.purchased) {
  final isValid = await validateInBackend(
    purchaseDetails.verificationData
  );
  if (isValid) unlockPremium();
}
```

### Antipatrón 2: Demasiados ads molestos
```dart
// ❌ MALO - Ad cada 10 segundos (experiencia pésima)
Timer.periodic(Duration(seconds: 10), (_) => showInterstitialAd());

// ✅ BIEN - Ads estratégicos (cada 5 eventos)
int actionCount = 0;
void onUserAction() {
  actionCount++;
  if (actionCount % 5 == 0) showInterstitialAd();
}
```

### Antipatrón 3: Suscripciones sin comunicar
```dart
// ❌ MALO - Usuario sorprendido
ElevatedButton(
  onPressed: () => buyProduct(monthlyPlan),
  child: Text('Comprar Premium'),
)

// ✅ BIEN - Comunicar claramente
ElevatedButton(
  onPressed: () => showSubscriptionDialog(),
  child: Text('Suscribirse - \$9.99/mes'),
)

void showSubscriptionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Suscripción Premium'),
      content: Text(
        'Se te cobrarán \$9.99 cada mes.\n'
        'Puedes cancelar en App Store en cualquier momento.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => buyProduct(monthlyPlan),
          child: Text('Aceptar'),
        ),
      ],
    ),
  );
}
```

---

## 8. Problemas Comunes

### Problema: "Compra pendiente no se completa"
**Causa:** No llamaste `completePurchase()`  
**Solución:** Siempre llamar en listener de compras

### Problema: "Ad no carga"
**Causa:** Ad Unit ID inválido  
**Solución:** Verificar en Google AdMob Console

### Problema: IAP no funciona en prueba
**Causa:** Cuenta test no configurada  
**Solución:** Agregar cuenta de prueba en Play Console

---

## 9. Estrategias de Monetización

### Opción 1: Freemium
- App gratuita + features premium pagadas
- **Ventaja:** Bajo rozamiento inicial
- **Desventaja:** Menos ingresos inmediatos

### Opción 2: Ads + IAP
- Ads para usuarios gratuitos
- Opción de remover ads pagando
- **Ventaja:** Múltiples flujos de ingresos
- **Desventaja:** UI más compleja

### Opción 3: Suscripción Pura
- Acceso completo pagado mensualmente
- **Ventaja:** Ingresos predecibles
- **Desventaja:** Requiere valor continuado

### Opción 4: Híbrida
- Demo gratuita limitada
- Premium completo
- Ads opcionales por monedas virtuales
- **Ventaja:** Máxima flexibilidad

---

## 📚 Conceptos Relacionados

- [15 Firebase](15_FIREBASE.md) - Analytics monetización
- [23 Deployment](23_DEPLOYMENT_STORES.md) - Publicar apps
- [EJERCICIOS_24](EJERCICIOS_24_MONETIZACION.md) - Prácticas

## 7. Best Practices

✅ **DO's:**
- Ofrecer valor real
- Transparencia en precios
- Fácil proceso de compra
- Ofrecer período de prueba
- Soportar restauración de compras
- Validar recibos en backend

❌ **DON'Ts:**
- Cobrar sin valor
- Ocultar costos
- Publicidad excesiva
- Hacer difícil cancelar suscripción
- Trusted Client-side validation
- Ignorar regulaciones (GDPR, CCPA)

---

## Resumen

Monetización es esencial para:
- ✅ Sustentar desarrollo
- ✅ Proporcionar valor
- ✅ Crecer negocio
- ✅ Profesionalismo
