# 🚀 Início Rápido - Executar no Emulador

## Passos Rápidos

### 1. Abrir Terminal no Projeto

Abra o PowerShell ou Terminal e navegue até o projeto:

```powershell
cd "C:\Users\pedro.nascimento\Documents\PEDRON\PROJETOS_PESSOAIS\PROJETO_ACESSIBUS\acessibus"
```

### 2. Instalar Dependências (se ainda não fez)

```bash
flutter pub get
```

### 3. Verificar Dispositivos Disponíveis

```bash
flutter devices
```

Se não aparecer nenhum emulador, você precisa criar um primeiro.

---

## 📱 Criar e Iniciar Emulador

### Opção A: Pelo Android Studio (Mais Fácil)

1. **Abrir Android Studio**
2. **Ir em Tools → Device Manager** (ou AVD Manager)
3. **Criar Novo Emulador:**
   - Clique em **Create Device**
   - Escolha **Pixel 5** ou **Pixel 6**
   - Escolha **API 33** ou **API 34** (Android 13/14)
   - Clique em **Finish**
4. **Iniciar Emulador:**
   - Clique no botão ▶️ ao lado do emulador criado
   - Aguarde inicializar completamente

### Opção B: Pelo Terminal

```bash
# Listar emuladores disponíveis
flutter emulators

# Iniciar um emulador específico
flutter emulators --launch <nome_do_emulador>
```

---

## ▶️ Executar o App

### Depois que o emulador estiver rodando:

```bash
# Verificar se o emulador foi detectado
flutter devices

# Executar o app
flutter run
```

Ou especifique o dispositivo:

```bash
flutter run -d emulator-5554
```

---

## ⚡ Comandos Úteis Durante Execução

- **r** - Hot reload (recarrega mudanças)
- **R** - Hot restart (reinicia o app)
- **q** - Sair

---

## 🐛 Problemas Comuns

### "No devices found"

**Solução:**
1. Verifique se o emulador está rodando
2. Aguarde alguns segundos após iniciar o emulador
3. Execute: `flutter devices` novamente

### Emulador não aparece

**Solução:**
1. Crie um emulador pelo Android Studio
2. Ou use: `flutter emulators --launch <nome>`

### Erro de dependências

**Solução:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📝 Checklist Rápido

- [ ] Terminal aberto na pasta do projeto
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Emulador criado e rodando
- [ ] Emulador detectado (`flutter devices`)
- [ ] App executado (`flutter run`)

---

**Pronto!** O app deve estar rodando no emulador agora! 🎉

Para mais detalhes, consulte o **GUIA_EMULADOR.md**

