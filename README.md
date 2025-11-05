# ACESSIBUS

Aplicativo de acessibilidade para transporte público, desenvolvido para auxiliar pessoas com deficiência visual a identificar a chegada dos ônibus.

## 📱 Sobre o Projeto

O **Acessibus** é um aplicativo móvel integrado a um dispositivo físico portátil que fornece notificações acessíveis (vibração, som e sinais luminosos) quando o ônibus desejado está se aproximando do ponto de parada.

### Funcionalidades

- ✅ Autenticação de usuário (Login e Cadastro com email/senha)
- ✅ Integração com Firebase Realtime Database
- ✅ Seleção de linha de ônibus
- ✅ Visualização de informações detalhadas da linha
- ✅ Mapa interativo com localização em tempo real
- ✅ Visualização de rotas e pontos de parada
- ✅ Comunicação com dispositivo físico (ESP8266)
- ✅ Interface acessível com suporte a leitores de tela
- ✅ Configurações de acessibilidade (alto contraste, tamanho de fonte)
- ✅ Perfil do usuário
- ✅ Validação de formulários
- ✅ Tema consistente e alto contraste
- ✅ Notificações multimodais (vibração, som, luz)

## 🏗️ Arquitetura

O projeto segue o padrão **MVC (Model-View-Controller)**:

- **Models**: Classes de dados (LinhaOnibus, PontoParada)
- **Views**: Interfaces de usuário (Pages)
- **Controllers**: Lógica de negócio (AuthController, LinhaController, etc.)
- **Services**: Serviços auxiliares (AuthService, ThemeService, etc.)

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.9.2 ou superior)
- Dart SDK
- Android Studio / VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico
- Conta Firebase configurada (para Realtime Database)

### Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd acessibus
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o Firebase:
   - Adicione o arquivo `firebase_options.dart` na pasta `lib/`
   - Configure o Firebase Realtime Database no console do Firebase
   - A URL do banco de dados deve estar configurada em `lib/services/auth_service.dart`

4. Execute o aplicativo:
```bash
# Para web
flutter run -d web-server

# Para Android
flutter run

# Para iOS
flutter run -d ios
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Configuração principal do app
├── firebase_options.dart        # Configurações do Firebase
│
├── models/                      # Modelos de dados
│   ├── linha_onibus_model.dart
│   └── ponto_parada_model.dart
│
├── controllers/                 # Controllers (Lógica de negócio)
│   ├── auth_controller.dart
│   ├── config_controller.dart
│   ├── linha_controller.dart
│   └── perfil_controller.dart
│
├── pages/                       # Views (Telas)
│   ├── welcome_page.dart
│   ├── login_page.dart
│   ├── cadastro_page.dart
│   ├── linha_onibus_page.dart
│   ├── selecionar_linha_page.dart
│   ├── informacoes_onibus_page.dart
│   ├── mapa_page.dart
│   ├── configuracoes_page.dart
│   ├── perfil_page.dart
│   └── alerta_onibus_page.dart
│
└── services/                    # Serviços auxiliares
    ├── auth_service.dart              # Autenticação e usuários
    ├── theme_service.dart             # Gerenciamento de tema
    ├── preferences_service.dart        # Armazenamento local
    ├── linha_service.dart             # Serviço de linhas de ônibus
    ├── database_service.dart           # Banco de dados local
    ├── dispositivo_service.dart        # Comunicação com dispositivo
    ├── firebase_realtime_service.dart  # Firebase Realtime Database
    ├── firebase_device_service.dart    # Serviço de dispositivos Firebase
    ├── esp8266_service.dart            # Comunicação ESP8266
    ├── directions_service.dart         # Serviço de rotas
    └── notificacao_service.dart        # Notificações locais
```

## 🎨 Assets

### Logo do Projeto

O projeto utiliza uma logo personalizada que deve ser adicionada em:
- `assets/logo.png`

**Características da logo:**
- Ícone de ônibus verde com símbolo de acessibilidade
- Texto "ACESSIBUS" em azul escuro
- Formato recomendado: PNG com fundo transparente
- Dimensões recomendadas: 512x512px ou maior (resoluções múltiplas)

Se a logo não for encontrada, o app usa ícones Material Design como fallback.

## ♿ Acessibilidade

O aplicativo foi desenvolvido com foco em acessibilidade:

- **Suporte a leitores de tela**: Uso de `Semantics` widgets para descrever elementos
- **Alto contraste**: Modo de alto contraste configurável nas configurações
- **Tamanho de fonte ajustável**: Controle de tamanho de fonte (0.8x a 2.0x)
- **Botões grandes**: Áreas de toque amplas para facilitar interação
- **Navegação por teclado**: Suporte a navegação via teclado
- **Feedback multimodal**: Vibração, som e sinais luminosos
- **Descrições semânticas**: Todos os elementos têm descrições para leitores de tela

## 🔧 Tecnologias Utilizadas

### Core
- **Flutter**: Framework de desenvolvimento multiplataforma
- **Dart**: Linguagem de programação
- **Material Design**: Sistema de design

### Banco de Dados
- **Firebase Realtime Database**: Armazenamento de usuários e dados em tempo real
- **SQLite (sqflite)**: Banco de dados local para linhas e pontos de parada
- **SharedPreferences**: Armazenamento de preferências do usuário

### Serviços e APIs
- **Firebase Core**: Core do Firebase
- **Firebase Auth**: Autenticação (preparado para uso futuro)
- **Google Maps Flutter**: Mapas interativos
- **Geolocator**: Localização GPS
- **HTTP**: Requisições HTTP para APIs

### Notificações e Dispositivos
- **Flutter Local Notifications**: Notificações locais
- **Vibration**: Vibração do dispositivo
- **Permission Handler**: Gerenciamento de permissões

### Outros
- **Crypto**: Hash de senhas (SHA256)
- **Google Sign In**: Login com Google (preparado para uso futuro)

## 🔐 Configuração do Firebase

### Realtime Database

O projeto utiliza Firebase Realtime Database para armazenar:
- Dados de usuários (`/user/{emailKey}`)
- Linhas selecionadas pelos usuários
- Dados de dispositivos conectados

**Estrutura de dados:**
```
/user/
  {emailKey}/
    name: string
    email: string
    passwordHash: string
    linhaSelecionada: {
      numero: string
      nome: string
      origem: string
      destino: string
      confirmadoEm: timestamp
    }
    createdAt: timestamp
    ultimoAcesso: timestamp
```

## 📝 Funcionalidades Implementadas

### ✅ Implementado
- [x] Autenticação com email/senha
- [x] Cadastro de usuários
- [x] Armazenamento no Firebase Realtime Database
- [x] Seleção de linhas de ônibus
- [x] Visualização de informações da linha
- [x] Mapa interativo com Google Maps
- [x] Localização GPS em tempo real
- [x] Visualização de rotas e pontos de parada
- [x] Configurações de acessibilidade
- [x] Perfil do usuário
- [x] Tema global com alto contraste
- [x] Configurações de dispositivo físico
- [x] Notificações locais
- [x] Arquitetura MVC

### 🚧 Em Desenvolvimento
- [ ] Integração completa com API de transporte público
- [ ] Comunicação Bluetooth/WiFi real com dispositivo ESP8266
- [ ] Rastreamento em tempo real de ônibus
- [ ] Notificações push quando o ônibus se aproxima
- [ ] Histórico de linhas utilizadas
- [ ] Favoritos de linhas
- [ ] Login com Google (configuração Android necessária)

## 🎯 Padrões de Desenvolvimento

### MVC (Model-View-Controller)
- **Models**: Definem a estrutura de dados
- **Views (Pages)**: Interface do usuário
- **Controllers**: Orquestram a lógica de negócio
- **Services**: Serviços auxiliares e comunicação com APIs

### Nomenclatura
- **Pages**: PascalCase (ex: `WelcomePage`, `LoginPage`)
- **Controllers**: PascalCase com sufixo "Controller" (ex: `AuthController`)
- **Models**: PascalCase (ex: `LinhaOnibus`, `PontoParada`)
- **Services**: PascalCase com sufixo "Service" (ex: `AuthService`)

## 👥 Equipe

- **Pedro H. A. Nascimento** - Gestor do Projeto
- **José Luiz Henrique Pereira** - Responsável pelo Hardware
- **Yago Barbosa de Andrade Oliveira** - Responsável pelo Aplicativo
- **Laila Maria Silva Pereira** - Responsável pelo Design

**Supervisor**: Prof. MSc Claudio Pereira da Silva

## 📄 Licença

Este projeto é desenvolvido para fins acadêmicos como parte do Projeto Integrador 6 da Faculdade Nova Roma.

## 🤝 Contribuindo

Para contribuir com o projeto:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Contato

Para dúvidas ou sugestões, entre em contato:
- Pedro: pedro.cosmica@gmail.com
- José Luiz: jose.luiznovo45@gmail.com
- Yago: yagobarbosaoliveira@gmail.com
- Laila: lailamaria.sp@gmail.com

## 📚 Documentação Adicional

### Configuração do Ambiente

1. Certifique-se de ter o Flutter instalado e configurado
2. Configure o Firebase Console e baixe o `firebase_options.dart`
3. Configure as permissões de localização no dispositivo
4. Para desenvolvimento web, certifique-se de ter uma chave de API do Google Maps configurada

### Troubleshooting

**Erro de null value**: Verifique se o Firebase está configurado corretamente
**Mapa não aparece**: Verifique se a chave de API do Google Maps está configurada
**Localização não funciona**: Verifique as permissões de localização no dispositivo
