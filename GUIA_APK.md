# 📱 Guia para Gerar APK e Testar no Emulador Android

## Pré-requisitos

1. **Android Studio instalado** (já instalado: versão 2025.1.4)
2. **Android SDK configurado**
3. **Emulador Android criado e configurado**

## Passo 1: Verificar Dispositivos Disponíveis

Primeiro, verifique se há emuladores disponíveis:

```bash
flutter devices
```

Se não houver emuladores, você precisará criar um no Android Studio.

## Passo 2: Criar um Emulador Android (se necessário)

1. Abra o **Android Studio**
2. Vá em **Tools > Device Manager**
3. Clique em **Create Device**
4. Escolha um dispositivo (ex: Pixel 5)
5. Escolha uma imagem do sistema (recomendado: **API 33 ou superior**)
6. Clique em **Finish**

## Passo 3: Iniciar o Emulador

### Opção 1: Pelo Android Studio
1. Abra o **Device Manager** no Android Studio
2. Clique no botão ▶️ ao lado do emulador que deseja usar

### Opção 2: Pelo Terminal
```bash
# Listar emuladores disponíveis
emulator -list-avds

# Iniciar um emulador específico (substitua NOME_DO_AVD pelo nome do seu emulador)
emulator -avd NOME_DO_AVD
```

## Passo 4: Verificar se o Emulador está Rodando

```bash
flutter devices
```

Você deve ver algo como:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 13 (API 33)
Chrome (web)                • chrome         • web-javascript • Google Chrome 131.0.6778.85
```

## Passo 5: Executar o App no Emulador

### Modo Debug (para desenvolvimento)
```bash
flutter run
```

Ou especifique o dispositivo:
```bash
flutter run -d emulator-5554
```

### Modo Release (otimizado)
```bash
flutter run --release
```

## Passo 6: Gerar APK

### APK Debug (para testes)
```bash
flutter build apk --debug
```

O APK será gerado em:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### APK Release (otimizado para produção)
```bash
flutter build apk --release
```

O APK será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### APK Split por Arquitetura (reduz tamanho)
```bash
# Gera APKs separados para cada arquitetura
flutter build apk --split-per-abi
```

Isso gera:
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit)
- `app-x86_64-release.apk` (x86_64)

## Passo 7: Instalar APK no Emulador

### Opção 1: Instalar via Flutter (recomendado)
```bash
# Instala o APK debug no emulador
flutter install
```

### Opção 2: Instalar APK manualmente
```bash
# Instalar APK no emulador via ADB
adb install build/app/outputs/flutter-apk/app-debug.apk
```

Ou arraste e solte o arquivo APK no emulador.

## Passo 8: Verificar Logs (Debug)

Para ver os logs do app em execução:

```bash
flutter logs
```

Ou use o comando específico:
```bash
adb logcat
```

## Comandos Úteis

### Listar dispositivos conectados
```bash
flutter devices
adb devices
```

### Reiniciar o emulador
```bash
adb reboot
```

### Limpar cache do build
```bash
flutter clean
flutter pub get
```

### Verificar problemas
```bash
flutter doctor -v
```

### Build para diferentes arquiteturas
```bash
# APK universal (todas as arquiteturas)
flutter build apk

# APK apenas para ARM64 (mais comum)
flutter build apk --target-platform android-arm64

# APK apenas para ARM32
flutter build apk --target-platform android-arm
```

## Troubleshooting

### Problema: "Android license status unknown"
```bash
flutter doctor --android-licenses
```
Aceite todas as licenças quando solicitado.

### Problema: "No devices found"
1. Verifique se o emulador está rodando
2. Verifique se o ADB está funcionando: `adb devices`
3. Reinicie o ADB: `adb kill-server && adb start-server`

### Problema: "SDK location not found"
Configure a variável de ambiente `ANDROID_HOME`:
```bash
# Windows (PowerShell)
$env:ANDROID_HOME = "C:\Users\SeuUsuario\AppData\Local\Android\Sdk"

# Linux/Mac
export ANDROID_HOME=$HOME/Library/Android/sdk
```

### Problema: Build falha
1. Limpe o projeto: `flutter clean`
2. Atualize dependências: `flutter pub get`
3. Verifique o `android/app/build.gradle.kts`
4. Verifique se o `google-services.json` está presente (se usar Firebase)

## Configuração do Firebase para Android

Se você estiver usando Firebase, certifique-se de:

1. Ter o arquivo `google-services.json` em `android/app/`
2. Ter o Google Services plugin configurado no `build.gradle.kts`
3. Ter o SHA-1 configurado no Firebase Console

### Obter SHA-1 para Firebase
```bash
# Windows
cd android
gradlew signingReport

# Linux/Mac
cd android
./gradlew signingReport
```

## Próximos Passos

1. **Teste no emulador** com `flutter run`
2. **Gere APK debug** para testes rápidos
3. **Gere APK release** quando estiver pronto para produção
4. **Configure signing** para releases (necessário para publicação na Play Store)

## Referências

- [Flutter Build and Release](https://docs.flutter.dev/deployment/android)
- [Android Studio Setup](https://developer.android.com/studio)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/windows)

