# ACESSIBUS

Aplicativo de acessibilidade para transporte público, desenvolvido para auxiliar pessoas com deficiência visual a identificar a chegada dos ônibus.

## 📱 Sobre o Projeto

O **Acessibus** é um aplicativo móvel integrado a um dispositivo físico portátil que fornece notificações acessíveis (vibração, som e sinais luminosos) quando o ônibus desejado está se aproximando do ponto de parada.

### Funcionalidades

- ✅ Autenticação de usuário (Login e Cadastro)
- ✅ Seleção de linha de ônibus
- ✅ Comunicação com dispositivo físico
- ✅ Interface acessível com suporte a leitores de tela
- ✅ Validação de formulários
- ✅ Tema consistente e alto contraste

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.9.2 ou superior)
- Dart SDK
- Android Studio / VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

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

3. Adicione a logo do projeto:
   - Coloque o arquivo `logo.png` na pasta `assets/`
   - O app já está configurado para usar a logo, mas se não encontrar, usará ícones como fallback

4. Execute o aplicativo:
```bash
flutter run -d web-server
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Configuração principal do app
├── welcome.dart              # Tela de boas-vindas
├── login.dart                # Tela de login
├── cadastro.dart             # Tela de cadastro
├── linha_onibus.dart         # Tela principal de linha de ônibus
├── selecionar_linha.dart     # Tela para selecionar linha
├── feedback.dart             # Tela de feedback/confirmação
└── services/
    ├── dispositivo_service.dart  # Serviço de comunicação com dispositivo
    └── linha_service.dart        # Serviço de gerenciamento de linhas
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
- **Alto contraste**: Cores com bom contraste para facilitar visualização
- **Botões grandes**: Áreas de toque amplas para facilitar interação
- **Navegação por teclado**: Suporte a navegação via teclado
- **Feedback visual e sonoro**: Indicadores claros de ações e estados

## 🔧 Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **Material Design**: Sistema de design

## 📝 Funcionalidades Futuras

- [ ] Integração com API de transporte público
- [ ] Comunicação Bluetooth/WiFi real com dispositivo
- [ ] Geolocalização e rastreamento de ônibus
- [ ] Notificações push quando o ônibus se aproxima
- [ ] Armazenamento local de dados do usuário
- [ ] Histórico de linhas utilizadas
- [ ] Favoritos de linhas

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
