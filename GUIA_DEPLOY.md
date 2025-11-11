# 🚀 Guia de Deploy e Publicação do Acessibus

Este guia explica como preparar e publicar o aplicativo Acessibus em produção.

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Preparação do Projeto](#preparação-do-projeto)
3. [Configuração do Firebase](#configuração-do-firebase)
4. [Build para Produção](#build-para-produção)
5. [Publicação na Google Play Store](#publicação-na-google-play-store)
6. [Publicação na App Store (iOS)](#publicação-na-app-store-ios)
7. [Deploy Web](#deploy-web)
8. [Pós-Deploy](#pós-deploy)

---

## 🔧 Pré-requisitos

Antes de iniciar o processo de deploy, certifique-se de ter:

- [ ] Flutter SDK instalado e atualizado
- [ ] Conta de desenvolvedor na Google Play Console (para Android)
- [ ] Conta de desenvolvedor na Apple App Store Connect (para iOS)
- [ ] Projeto Firebase configurado e ativo
- [ ] Chave de API do Google Maps configurada
- [ ] Certificados de assinatura configurados (Android KeyStore, iOS Certificates)

---

## 📦 Preparação do Projeto

### 1. Atualizar Versão

Edite o arquivo `pubspec.yaml`:

```yaml
version: 1.0.0+1  # Formato: versionName+versionCode
```

- **versionName**: Versão visível ao usuário (ex: 1.0.0)
- **versionCode**: Número interno de build (deve incrementar a cada release)

### 2. Limpar Builds Anteriores

```bash
flutter clean
flutter pub get
```

### 3. Verificar Dependências

```bash
flutter pub outdated
flutter pub upgrade
```

### 4. Executar Testes

```bash
flutter test
```

### 5. Verificar Análise de Código

```bash
flutter analyze
```

---

## 🔥 Configuração do Firebase

### 1. Verificar Configuração do Firebase

Certifique-se de que o arquivo `lib/firebase_options.dart` está atualizado:

```bash
flutterfire configure
```

### 2. Configurar Firebase Realtime Database

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto `acessibus-df8c9`
3. Vá em **Realtime Database**
4. Configure as regras de segurança:

```json
{
  "rules": {
    "user": {
      "$emailKey": {
        ".read": "auth != null || $emailKey == auth.uid",
        ".write": "auth != null || $emailKey == auth.uid"
      }
    },
    "dados": {
      "$idOnibus": {
        ".read": true,
        ".write": false
      }
    }
  }
}
```

### 3. Configurar Firebase Authentication

1. No Firebase Console, vá em **Authentication**
2. Habilite os métodos de autenticação:
   - Email/Password
   - Google (se necessário)

### 4. Configurar SHA-1 para Android

Obtenha o SHA-1 do certificado de release:

```bash
# Windows
cd android
gradlew signingReport

# Linux/Mac
cd android
./gradlew signingReport
```

Adicione o SHA-1 no Firebase Console:
1. Vá em **Project Settings** > **Your apps** > **Android app**
2. Adicione o SHA-1 na seção **SHA certificate fingerprints**

### 5. Configurar Google Maps API

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Crie ou selecione o projeto
3. Habilite a **Maps SDK for Android** e **Maps SDK for iOS**
4. Configure restrições de API (recomendado para produção)
5. Adicione a chave de API no projeto

---

## 📱 Build para Produção

### Android

#### 1. Configurar Assinatura (KeyStore)

Crie um arquivo `android/key.properties` (NÃO commite este arquivo!):

```properties
storePassword=sua_senha_aqui
keyPassword=sua_senha_aqui
keyAlias=acessibus
storeFile=../acessibus-release-key.jks
```

Crie o KeyStore (apenas na primeira vez):

```bash
keytool -genkey -v -keystore android/acessibus-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias acessibus
```

#### 2. Configurar build.gradle.kts

Edite `android/app/build.gradle.kts` para usar o KeyStore:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... outras configurações

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 3. Gerar APK Release

```bash
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

#### 4. Gerar App Bundle (Recomendado para Play Store)

```bash
flutter build appbundle --release
```

O AAB será gerado em: `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### 1. Configurar Certificados e Provisioning Profiles

1. Abra o projeto no Xcode: `open ios/Runner.xcworkspace`
2. Configure o **Signing & Capabilities** no Xcode
3. Selecione seu **Team** e **Bundle Identifier**

#### 2. Atualizar Versão no Xcode

1. No Xcode, vá em **Runner** > **General**
2. Atualize **Version** e **Build**

#### 3. Gerar Build para App Store

```bash
flutter build ipa --release
```

O IPA será gerado em: `build/ios/ipa/`

---

## 📲 Publicação na Google Play Store

### 1. Criar Conta de Desenvolvedor

1. Acesse [Google Play Console](https://play.google.com/console)
2. Pague a taxa única de $25 USD
3. Complete o perfil de desenvolvedor

### 2. Criar Aplicativo

1. Clique em **Criar aplicativo**
2. Preencha:
   - Nome do app: **Acessibus**
   - Idioma padrão: **Português (Brasil)**
   - Tipo de app: **Aplicativo**
   - Gratuito ou pago: **Gratuito**

### 3. Preparar Assets

Você precisará de:
- [ ] Ícone do app (512x512px)
- [ ] Screenshots (mínimo 2, máximo 8)
- [ ] Descrição curta (80 caracteres)
- [ ] Descrição completa (4000 caracteres)
- [ ] Categoria: **Transporte**
- [ ] Classificação de conteúdo
- [ ] Política de privacidade (URL)

### 4. Upload do App Bundle

1. Vá em **Produção** > **Criar nova versão**
2. Faça upload do arquivo `app-release.aab`
3. Preencha as **Notas da versão**
4. Clique em **Revisar versão**

### 5. Revisar e Publicar

1. Revise todas as informações
2. Verifique se todos os campos obrigatórios estão preenchidos
3. Clique em **Iniciar lançamento para produção**
4. Aguarde a revisão do Google (pode levar algumas horas a dias)

### 6. Checklist de Publicação Android

- [ ] App Bundle gerado e testado
- [ ] Versão atualizada no `pubspec.yaml`
- [ ] Firebase configurado corretamente
- [ ] SHA-1 adicionado no Firebase
- [ ] Google Maps API configurada
- [ ] Ícone e screenshots preparados
- [ ] Descrição e metadados preenchidos
- [ ] Política de privacidade publicada
- [ ] Testado em dispositivos reais
- [ ] Permissões justificadas

---

## 🍎 Publicação na App Store (iOS)

### 1. Criar Conta de Desenvolvedor

1. Acesse [Apple Developer](https://developer.apple.com/)
2. Pague a taxa anual de $99 USD
3. Complete o cadastro

### 2. Configurar App Store Connect

1. Acesse [App Store Connect](https://appstoreconnect.apple.com/)
2. Crie um novo app:
   - Nome: **Acessibus**
   - Idioma primário: **Português (Brasil)**
   - Bundle ID: (deve corresponder ao do Xcode)
   - SKU: Identificador único

### 3. Preparar Assets iOS

Você precisará de:
- [ ] Ícone do app (1024x1024px)
- [ ] Screenshots para diferentes tamanhos de tela
- [ ] Descrição do app
- [ ] Palavras-chave
- [ ] URL de suporte
- [ ] Política de privacidade

### 4. Upload via Xcode

1. Abra o projeto no Xcode
2. Selecione **Product** > **Archive**
3. Após o build, clique em **Distribute App**
4. Escolha **App Store Connect**
5. Siga o assistente de upload

### 5. Submeter para Revisão

1. No App Store Connect, vá em **App Store** > **Versão**
2. Preencha todas as informações
3. Adicione screenshots e descrição
4. Clique em **Enviar para revisão**

### 6. Checklist de Publicação iOS

- [ ] Certificados e provisioning profiles configurados
- [ ] Versão atualizada
- [ ] Firebase configurado para iOS
- [ ] Google Maps API configurada para iOS
- [ ] Ícone e screenshots preparados
- [ ] Descrição e metadados preenchidos
- [ ] Política de privacidade publicada
- [ ] Testado em dispositivos iOS reais
- [ ] Permissões justificadas no Info.plist

---

## 🌐 Deploy Web

### 1. Build para Web

```bash
flutter build web --release
```

### 2. Opções de Deploy

#### Opção A: Firebase Hosting (Recomendado)

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar (se ainda não tiver)
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### Opção B: GitHub Pages

1. Configure o GitHub Actions para build automático
2. Publique na branch `gh-pages`

#### Opção C: Netlify/Vercel

1. Conecte o repositório
2. Configure o build command: `flutter build web`
3. Configure o publish directory: `build/web`

### 3. Configurações Web

Certifique-se de que:
- [ ] Firebase está configurado para web
- [ ] Google Maps API está habilitada para web
- [ ] CORS está configurado corretamente
- [ ] HTTPS está habilitado

---

## ✅ Pós-Deploy

### 1. Monitoramento

- Configure **Firebase Crashlytics** para monitorar erros
- Configure **Firebase Analytics** para métricas
- Monitore reviews e feedbacks nas lojas

### 2. Atualizações

Para atualizar o app:

1. Incremente a versão no `pubspec.yaml`
2. Gere novo build
3. Faça upload na loja correspondente
4. Preencha as notas da versão

### 3. Manutenção

- [ ] Monitorar logs de erro
- [ ] Responder a reviews
- [ ] Atualizar dependências regularmente
- [ ] Manter documentação atualizada

---

## 🔐 Segurança em Produção

### Checklist de Segurança

- [ ] Remover logs de debug
- [ ] Não commitar credenciais
- [ ] Usar variáveis de ambiente para secrets
- [ ] Configurar regras de segurança do Firebase
- [ ] Habilitar HTTPS em todas as comunicações
- [ ] Validar inputs do usuário
- [ ] Implementar rate limiting (se necessário)
- [ ] Revisar permissões do app

---

## 📝 Checklist Final de Deploy

### Antes de Publicar

- [ ] Todos os testes passando
- [ ] Código analisado sem erros críticos
- [ ] Versão atualizada
- [ ] Firebase configurado
- [ ] Google Maps API configurada
- [ ] Build de release testado
- [ ] Assets preparados (ícones, screenshots)
- [ ] Descrições e metadados preenchidos
- [ ] Política de privacidade publicada
- [ ] Testado em dispositivos reais
- [ ] Backup do código feito

### Após Publicar

- [ ] Monitorar primeiras instalações
- [ ] Verificar logs de erro
- [ ] Responder a primeiros reviews
- [ ] Documentar processo de deploy
- [ ] Atualizar README com link da loja

---

## 🆘 Troubleshooting

### Problema: Build falha

**Solução:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Problema: Firebase não funciona em produção

**Solução:**
- Verifique se o SHA-1 está correto no Firebase Console
- Verifique se o `google-services.json` está no lugar correto
- Verifique as regras de segurança do Realtime Database

### Problema: Google Maps não aparece

**Solução:**
- Verifique se a chave de API está configurada
- Verifique se as restrições de API permitem seu app
- Verifique se a billing está habilitada no Google Cloud

---

## 📚 Referências

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)

---

**Boa sorte com o deploy! 🚀**

