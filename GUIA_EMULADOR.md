# 🚀 Guia: Como Iniciar o Projeto no Emulador Android

Este guia explica passo a passo como configurar e executar o projeto **Acessibus** em um emulador Android.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

1. **Flutter SDK** (versão 3.9.2 ou superior)
   - Verifique a instalação: `flutter --version`
   - Se não tiver, baixe em: https://flutter.dev/docs/get-started/install

2. **Android Studio** (recomendado) ou **VS Code** com extensão Flutter
   - Android Studio: https://developer.android.com/studio
   - VS Code: https://code.visualstudio.com/

3. **Android SDK** (geralmente instalado com Android Studio)
   - Certifique-se de ter o Android SDK Platform-Tools instalado

4. **Java JDK 11** ou superior
   - Verifique: `java -version`

## 🔧 Configuração Inicial

### 1. Verificar Instalação do Flutter

Abra o terminal (PowerShell no Windows) e execute:

```bash
flutter doctor
```

Este comando verifica se tudo está configurado corretamente. Resolva quaisquer problemas indicados antes de continuar.

### 2. Instalar Dependências do Projeto

Navegue até a pasta do projeto e instale as dependências:

```bash
cd C:\Users\pedro.nascimento\Documents\PEDRON\PROJETOS_PESSOAIS\PROJETO_ACESSIBUS\acessibus
flutter pub get
```

### 3. Configurar Firebase (Opcional, mas Recomendado)

O projeto utiliza Firebase. Certifique-se de que o arquivo `lib/firebase_options.dart` está configurado corretamente. Se não estiver, você precisará:

1. Acessar o Firebase Console: https://console.firebase.google.com/
2. Criar/configurar seu projeto Firebase
3. Baixar o arquivo de configuração e gerar o `firebase_options.dart` usando:
   ```bash
   flutterfire configure
   ```

## 📱 Configurando o Emulador Android

### Opção 1: Usando Android Studio (Recomendado)

1. **Abrir Android Studio**
   - Inicie o Android Studio

2. **Abrir o AVD Manager (Android Virtual Device Manager)**
   - Clique em **Tools** → **Device Manager** (ou **AVD Manager** em versões antigas)
   - Ou clique no ícone de dispositivo na barra de ferramentas

3. **Criar um Novo Emulador**
   - Clique em **Create Device** (ou **Create Virtual Device**)
   - Escolha um dispositivo (recomendado: **Pixel 5** ou **Pixel 6**)
   - Clique em **Next**

4. **Selecionar Imagem do Sistema**
   - Escolha uma imagem do sistema Android (recomendado: **API 33** ou **API 34**)
   - Se não tiver, clique em **Download** ao lado da imagem
   - Clique em **Next**

5. **Configurar o Emulador**
   - Nome: escolha um nome (ex: "Pixel_5_API_33")
   - Verifique as configurações (RAM, etc.)
   - Clique em **Finish**

6. **Iniciar o Emulador**
   - Na lista de dispositivos, clique no botão ▶️ (Play) ao lado do emulador criado
   - Aguarde o emulador inicializar completamente

### Opção 2: Usando Linha de Comando

1. **Listar Imagens Disponíveis**
   ```bash
   flutter emulators
   ```

2. **Criar Emulador via Linha de Comando**
   ```bash
   # Primeiro, liste os targets disponíveis
   avdmanager list targets
   
   # Crie o emulador (substitua os valores conforme necessário)
   avdmanager create avd -n Pixel_5_API_33 -k "system-images;android-33;google_apis;x86_64"
   ```

3. **Iniciar o Emulador**
   ```bash
   flutter emulators --launch <nome_do_emulador>
   ```

## ▶️ Executando o Projeto

### Passo 1: Verificar Dispositivos Disponíveis

Antes de executar, verifique se o emulador está rodando e detectado:

```bash
flutter devices
```

Você deve ver algo como:
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33) (emulator)
Chrome (web)                • chrome        • web-javascript • Google Chrome 120.0.0.0
```

### Passo 2: Executar o Projeto

Execute um dos seguintes comandos:

**Opção A: Executar no primeiro dispositivo disponível**
```bash
flutter run
```

**Opção B: Executar em um dispositivo específico**
```bash
flutter run -d emulator-5554
```
(Substitua `emulator-5554` pelo ID do seu emulador)

**Opção C: Executar em modo release (mais rápido, mas sem hot reload)**
```bash
flutter run --release
```

**Opção D: Executar em modo debug com hot reload (recomendado para desenvolvimento)**
```bash
flutter run --debug
```

### Passo 3: Aguardar a Compilação

Na primeira execução, o Flutter irá:
1. Compilar o código Dart
2. Construir o APK
3. Instalar no emulador
4. Iniciar o aplicativo

Isso pode levar alguns minutos. Execuções subsequentes serão mais rápidas.

## 🔥 Hot Reload e Hot Restart

Após o aplicativo estar rodando, você pode usar:

- **Hot Reload** (r): Recarrega as mudanças sem perder o estado
- **Hot Restart** (R): Reinicia o app completamente
- **Quit** (q): Encerra o aplicativo

Pressione a tecla correspondente no terminal onde o Flutter está rodando.

## 🐛 Troubleshooting (Solução de Problemas)

### Problema: "No devices found"

**Solução:**
1. Verifique se o emulador está rodando: `flutter devices`
2. Se não estiver, inicie o emulador pelo Android Studio
3. Verifique se o ADB está funcionando: `adb devices`

### Problema: "Gradle build failed"

**Solução:**
1. Limpe o projeto:
   ```bash
   flutter clean
   flutter pub get
   ```
2. Verifique se o `minSdk` no `android/app/build.gradle.kts` está compatível
3. Tente executar: `cd android && ./gradlew clean` (Linux/Mac) ou `cd android && gradlew.bat clean` (Windows)

### Problema: "Firebase not initialized"

**Solução:**
1. Verifique se o arquivo `lib/firebase_options.dart` existe
2. Se não existir, configure o Firebase:
   ```bash
   flutterfire configure
   ```
3. Certifique-se de que o Firebase está inicializado no `main.dart`

### Problema: Emulador muito lento

**Solução:**
1. Aumente a RAM alocada para o emulador no AVD Manager
2. Habilite a aceleração de hardware (HAXM no Windows)
3. Use uma imagem do sistema x86_64 em vez de arm64 (mais rápido em PCs)
4. Feche outros aplicativos pesados

### Problema: "SDK location not found"

**Solução:**
1. Configure a variável de ambiente `ANDROID_HOME`:
   - Windows: `C:\Users\<seu_usuario>\AppData\Local\Android\Sdk`
   - Adicione ao PATH: `%ANDROID_HOME%\platform-tools`
2. Ou crie o arquivo `android/local.properties` com:
   ```
   sdk.dir=C:\\Users\\<seu_usuario>\\AppData\\Local\\Android\\Sdk
   ```

### Problema: Erro de permissões no Android

**Solução:**
1. O app solicita permissões automaticamente na primeira execução
2. Se necessário, vá em **Configurações** → **Apps** → **Acessibus** → **Permissões** no emulador

## 📝 Comandos Úteis

```bash
# Verificar status do Flutter
flutter doctor

# Listar dispositivos disponíveis
flutter devices

# Listar emuladores disponíveis
flutter emulators

# Limpar build anterior
flutter clean

# Atualizar dependências
flutter pub get

# Executar testes
flutter test

# Ver logs do dispositivo
flutter logs

# Build APK para teste
flutter build apk --debug

# Build APK para release
flutter build apk --release
```

## 🎯 Dicas para Desenvolvimento

1. **Mantenha o emulador aberto**: Não feche o emulador entre execuções para economizar tempo
2. **Use Hot Reload**: Faça mudanças pequenas e use `r` para ver instantaneamente
3. **Monitore os logs**: Use `flutter logs` em outro terminal para ver erros em tempo real
4. **Teste em diferentes tamanhos**: Crie emuladores com diferentes tamanhos de tela
5. **Use modo Release ocasionalmente**: Teste performance com `flutter run --release`

## 📱 Configurações Recomendadas do Emulador

Para melhor performance, configure o emulador com:
- **RAM**: 2GB ou mais
- **VM Heap**: 256MB ou mais
- **Graphics**: Hardware - GLES 2.0
- **Multi-core CPU**: 2 ou mais cores
- **API Level**: 33 ou superior (Android 13+)

## ✅ Checklist Antes de Executar

- [ ] Flutter instalado e funcionando (`flutter doctor` sem erros críticos)
- [ ] Dependências instaladas (`flutter pub get` executado)
- [ ] Emulador criado e iniciado
- [ ] Emulador detectado pelo Flutter (`flutter devices`)
- [ ] Firebase configurado (se necessário)
- [ ] Permissões de localização habilitadas no emulador (para funcionalidades de mapa)

## 🆘 Ainda com Problemas?

Se você ainda encontrar problemas:

1. Execute `flutter doctor -v` para diagnóstico detalhado
2. Verifique os logs: `flutter logs`
3. Consulte a documentação oficial: https://flutter.dev/docs
4. Verifique issues conhecidos no repositório do projeto

---

**Boa sorte com o desenvolvimento! 🚀**

