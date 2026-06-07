# Credencial Digital Estudiantil — Flutter

## Estructura del proyecto

```
lib/
├── main.dart                  ← Entry point + Tema global
├── models/
│   └── student_model.dart     ← Modelo de datos plano
└── screens/
    ├── form_screen.dart       ← Formulario de configuración
    └── credential_screen.dart ← Pantalla de la credencial
```

---

## Instalación rápida

```bash
# 1. Dentro de la carpeta del proyecto:
cd credencial_estudiantil

# 2. Instalar dependencias
flutter pub get

# 3. Correr en emulador Android
flutter run
```

---

## Permisos necesarios (ya configurados por image_picker)

### Android → `android/app/src/main/AndroidManifest.xml`
Agrega dentro de `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<!-- Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### iOS → `ios/Runner/Info.plist`
Agrega:
```xml
<key>NSCameraUsageDescription</key>
<string>Se necesita la cámara para tomar la foto de perfil.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Se necesita acceso a la galería para seleccionar la foto de perfil.</string>
```

---

## Generar APK Debug

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

## Generar APK Release

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Dependencias utilizadas

| Paquete | Versión | Uso |
|---------|---------|-----|
| `image_picker` | ^1.1.2 | Cámara/galería para foto de perfil |
| `intl` | ^0.19.0 | Formato de fechas en español |
| `google_fonts` | ^6.2.1 | Tipografía Poppins (opcional) |

---

## Paleta de colores

| Rol | Hex | Color |
|-----|-----|-------|
| Fondo canvas | `#F4F5FA` | Blanco humo lavanda |
| Fondo reloj | `#DCADFA` | Lavanda pastel |
| Rojo corporativo | `#E31937` | Rojo nombre/icono |
| Texto principal | `#2D3142` | Gris oscuro |
| Texto secundario | `#757575` | Gris medio |
| Acento morado | `#7B68EE` | Bordes/íconos |
