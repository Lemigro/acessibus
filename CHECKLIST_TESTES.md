# ✅ Checklist de Testes - Acessibus

Este documento contém um checklist completo para testar todas as funcionalidades do aplicativo Acessibus antes do deploy.

## 📋 Como Usar Este Checklist

- [ ] Marque cada item conforme for testando
- [ ] Anote problemas encontrados na seção de **Observações**
- [ ] Teste em diferentes dispositivos e versões do Android/iOS
- [ ] Teste em modo debug e release
- [ ] Documente bugs encontrados

---

## 🔐 Autenticação e Cadastro

### Tela de Boas-Vindas (Welcome Page)
- [ ] Tela carrega corretamente
- [ ] Botão "Entrar" redireciona para Login
- [ ] Botão "Cadastrar" redireciona para Cadastro
- [ ] Logo aparece corretamente
- [ ] Layout responsivo em diferentes tamanhos de tela

### Login
- [ ] Campo de email aceita entrada válida
- [ ] Campo de senha oculta caracteres
- [ ] Validação de email (formato correto)
- [ ] Validação de senha (não vazia)
- [ ] Mensagem de erro para email inválido
- [ ] Mensagem de erro para senha incorreta
- [ ] Mensagem de erro para usuário não encontrado
- [ ] Login bem-sucedido redireciona corretamente
- [ ] Botão "Esqueci minha senha" (se implementado)
- [ ] Botão "Voltar" funciona
- [ ] Loading durante autenticação
- [ ] Dados do usuário são salvos após login

### Cadastro
- [ ] Campo de nome aceita entrada
- [ ] Campo de email valida formato
- [ ] Campo de senha valida (mínimo de caracteres)
- [ ] Campo de confirmação de senha valida correspondência
- [ ] Mensagem de erro para email já cadastrado
- [ ] Mensagem de erro para senhas não correspondentes
- [ ] Cadastro bem-sucedido cria usuário no Firebase
- [ ] Cadastro bem-sucedido faz login automático
- [ ] Botão "Voltar" funciona
- [ ] Loading durante cadastro

### Logout
- [ ] Botão de logout funciona
- [ ] Logout limpa dados locais
- [ ] Logout redireciona para Welcome Page
- [ ] Logout desconecta do Firebase

---

## 🚌 Funcionalidades de Linhas de Ônibus

### Seleção de Linha
- [ ] Lista de linhas carrega corretamente
- [ ] Busca de linha funciona
- [ ] Filtros funcionam (se implementados)
- [ ] Seleção de linha salva no Firebase
- [ ] Seleção de linha salva localmente
- [ ] Linha selecionada aparece na tela principal
- [ ] Botão "Alterar linha" funciona

### Informações da Linha
- [ ] Tela de informações carrega dados corretos
- [ ] Nome da linha aparece
- [ ] Origem e destino aparecem
- [ ] Horários aparecem (se disponíveis)
- [ ] Pontos de parada aparecem
- [ ] Mapa mostra rota da linha
- [ ] Botão "Voltar" funciona
- [ ] Botão "Ver no mapa" funciona

### Lista de Linhas
- [ ] Lista completa de linhas carrega
- [ ] Busca funciona
- [ ] Ordenação funciona (se implementada)
- [ ] Scroll funciona suavemente
- [ ] Seleção de linha funciona

---

## 🗺️ Mapa e Localização

### Permissões
- [ ] Solicita permissão de localização
- [ ] Trata permissão negada
- [ ] Trata permissão permanentemente negada
- [ ] Abre configurações quando necessário

### Mapa
- [ ] Mapa carrega corretamente
- [ ] Localização atual aparece
- [ ] Marcadores de pontos de parada aparecem
- [ ] Rota da linha aparece no mapa
- [ ] Zoom funciona (pinch, botões)
- [ ] Pan funciona
- [ ] Botão "Minha localização" centraliza mapa
- [ ] Performance do mapa é aceitável

### Localização em Tempo Real
- [ ] Localização atualiza em tempo real
- [ ] Marcador de localização se move suavemente
- [ ] Distância até ponto de parada calcula corretamente
- [ ] Não consome bateria excessivamente

---

## 🔔 Notificações e Alertas

### Notificações Locais
- [ ] Notificação aparece quando ônibus está próximo
- [ ] Vibração funciona
- [ ] Som de notificação funciona (se implementado)
- [ ] Notificação tem título correto
- [ ] Notificação tem corpo correto
- [ ] Tocar na notificação abre o app
- [ ] Notificações não duplicam

### Alertas de Ônibus
- [ ] Alerta aparece quando distância < 0.5m
- [ ] Alerta mostra linha correta
- [ ] Alerta mostra distância correta
- [ ] Alerta desaparece quando ônibus se afasta
- [ ] Múltiplos alertas não conflitam

---

## 🔌 Comunicação com Dispositivo

### MQTT
- [ ] Conexão MQTT estabelece corretamente
- [ ] Reconexão automática funciona
- [ ] Recebe dados da parada corretamente
- [ ] Processa mensagens MQTT corretamente
- [ ] Trata desconexão graciosamente
- [ ] Logs de conexão aparecem (debug)

### Firebase Realtime Database
- [ ] Monitoramento de dados inicia corretamente
- [ ] Recebe atualizações em tempo real
- [ ] Processa dados corretamente
- [ ] Trata erros de conexão
- [ ] Para monitoramento corretamente

### Configuração de Dispositivo
- [ ] Tela de configuração carrega
- [ ] Campo de ID do dispositivo funciona
- [ ] Campo de broker MQTT funciona
- [ ] Salva configurações corretamente
- [ ] Carrega configurações salvas
- [ ] Validação de campos funciona

---

## ⚙️ Configurações

### Tela de Configurações
- [ ] Tela carrega corretamente
- [ ] Todas as opções aparecem
- [ ] Navegação funciona

### Alto Contraste
- [ ] Toggle de alto contraste funciona
- [ ] Mudança de tema é imediata
- [ ] Tema persiste após fechar app
- [ ] Todas as telas respeitam o tema

### Tamanho de Fonte
- [ ] Controle de tamanho de fonte funciona
- [ ] Mudança é aplicada imediatamente
- [ ] Configuração persiste
- [ ] Textos não quebram layout

### Outras Configurações
- [ ] Configurações de notificação funcionam
- [ ] Configurações de vibração funcionam
- [ ] Configurações de som funcionam
- [ ] Botão "Voltar" funciona

---

## 👤 Perfil do Usuário

### Visualização de Perfil
- [ ] Nome do usuário aparece
- [ ] Email do usuário aparece
- [ ] Foto do perfil aparece (se implementado)
- [ ] Linha selecionada aparece
- [ ] Dados são carregados do Firebase

### Edição de Perfil
- [ ] Edição de nome funciona
- [ ] Validação de campos funciona
- [ ] Salva alterações no Firebase
- [ ] Atualiza dados locais
- [ ] Mensagem de sucesso aparece

---

## ♿ Acessibilidade

### Leitores de Tela
- [ ] Todos os botões têm labels descritivos
- [ ] Campos de texto têm hints
- [ ] Navegação por leitor de tela funciona
- [ ] Anúncios de mudanças de estado funcionam

### Alto Contraste
- [ ] Cores têm contraste adequado
- [ ] Textos são legíveis
- [ ] Botões são visíveis
- [ ] Ícones são distinguíveis

### Tamanho de Fonte
- [ ] Textos aumentam corretamente
- [ ] Layout não quebra com fonte grande
- [ ] Todos os textos respeitam configuração

### Navegação
- [ ] Navegação por teclado funciona (web)
- [ ] Áreas de toque são grandes o suficiente
- [ ] Feedback tátil funciona

---

## 🔄 Fluxos de Navegação

### Fluxo Principal
- [ ] Welcome → Login → Linha Onibus → Mapa
- [ ] Welcome → Cadastro → Linha Onibus → Mapa
- [ ] Navegação entre telas funciona
- [ ] Botão "Voltar" funciona em todas as telas
- [ ] Deep linking funciona (se implementado)

### Persistência de Estado
- [ ] App mantém estado ao minimizar
- [ ] Dados do usuário persistem
- [ ] Linha selecionada persiste
- [ ] Configurações persistem

---

## 🌐 Integrações

### Firebase
- [ ] Firebase inicializa corretamente
- [ ] Autenticação funciona
- [ ] Realtime Database funciona
- [ ] Dados são salvos corretamente
- [ ] Dados são lidos corretamente
- [ ] Regras de segurança funcionam

### Google Maps
- [ ] Mapa carrega
- [ ] API key está configurada
- [ ] Restrições de API funcionam
- [ ] Billing está configurado (se necessário)

### MQTT Broker
- [ ] Conexão ao broker funciona
- [ ] Autenticação MQTT funciona
- [ ] Tópicos são subscritos corretamente
- [ ] Mensagens são recebidas corretamente

---

## 📱 Testes em Diferentes Dispositivos

### Android
- [ ] Testado em Android 10 (API 29)
- [ ] Testado em Android 11 (API 30)
- [ ] Testado em Android 12 (API 31)
- [ ] Testado em Android 13 (API 33)
- [ ] Testado em Android 14 (API 34)
- [ ] Testado em diferentes tamanhos de tela
- [ ] Testado em modo claro e escuro

### iOS (se aplicável)
- [ ] Testado em iOS 14+
- [ ] Testado em diferentes modelos de iPhone
- [ ] Testado em iPad (se suportado)

---

## 🐛 Tratamento de Erros

### Erros de Rede
- [ ] Trata falta de conexão
- [ ] Mensagem de erro clara
- [ ] Botão de retry funciona
- [ ] App não crasha

### Erros de Firebase
- [ ] Trata erro de autenticação
- [ ] Trata erro de leitura/escrita
- [ ] Mensagens de erro são claras

### Erros de Localização
- [ ] Trata GPS desabilitado
- [ ] Trata permissão negada
- [ ] Trata localização indisponível

### Erros Gerais
- [ ] App não crasha inesperadamente
- [ ] Erros são logados
- [ ] Usuário recebe feedback

---

## ⚡ Performance

### Tempo de Carregamento
- [ ] App inicia em < 3 segundos
- [ ] Telas carregam rapidamente
- [ ] Dados do Firebase carregam rapidamente
- [ ] Mapa carrega em tempo aceitável

### Uso de Recursos
- [ ] Uso de memória é aceitável
- [ ] Uso de CPU é aceitável
- [ ] Bateria não drena rapidamente
- [ ] Dados móveis não são excessivos

### Animações
- [ ] Animações são suaves (60 FPS)
- [ ] Transições são rápidas
- [ ] Não há lag perceptível

---

## 🔒 Segurança

### Dados Sensíveis
- [ ] Senhas não são armazenadas em texto plano
- [ ] Tokens não são expostos
- [ ] Logs não contêm informações sensíveis

### Validação
- [ ] Inputs são validados
- [ ] SQL injection não é possível
- [ ] XSS não é possível (web)

### Permissões
- [ ] Apenas permissões necessárias são solicitadas
- [ ] Permissões são justificadas

---

## 📊 Testes de Regressão

### Funcionalidades Críticas
- [ ] Login ainda funciona após mudanças
- [ ] Seleção de linha ainda funciona
- [ ] Mapa ainda funciona
- [ ] Notificações ainda funcionam

### Compatibilidade
- [ ] App funciona após atualização do Flutter
- [ ] Dependências estão atualizadas
- [ ] Não há warnings de deprecação

---

## 📝 Observações

Use este espaço para anotar problemas encontrados durante os testes:

### Problemas Encontrados

1. **Data**: _______________
   - **Tela/Funcionalidade**: _______________
   - **Problema**: _______________
   - **Severidade**: [ ] Crítico [ ] Alto [ ] Médio [ ] Baixo
   - **Status**: [ ] Resolvido [ ] Em andamento [ ] Pendente

2. **Data**: _______________
   - **Tela/Funcionalidade**: _______________
   - **Problema**: _______________
   - **Severidade**: [ ] Crítico [ ] Alto [ ] Médio [ ] Baixo
   - **Status**: [ ] Resolvido [ ] Em andamento [ ] Pendente

3. **Data**: _______________
   - **Tela/Funcionalidade**: _______________
   - **Problema**: _______________
   - **Severidade**: [ ] Crítico [ ] Alto [ ] Médio [ ] Baixo
   - **Status**: [ ] Resolvido [ ] Em andamento [ ] Pendente

---

## ✅ Checklist Final

Antes de considerar os testes completos:

- [ ] Todos os itens críticos foram testados
- [ ] Problemas encontrados foram documentados
- [ ] Bugs críticos foram corrigidos
- [ ] App foi testado em pelo menos 2 dispositivos diferentes
- [ ] App foi testado em modo debug e release
- [ ] Performance é aceitável
- [ ] Acessibilidade está funcionando
- [ ] Integrações estão funcionando
- [ ] Tratamento de erros está adequado
- [ ] Documentação está atualizada

---

**Data do Teste**: _______________
**Testado por**: _______________
**Versão Testada**: _______________
**Dispositivos Testados**: _______________

---

**Status Geral**: [ ] ✅ Aprovado [ ] ⚠️ Aprovado com ressalvas [ ] ❌ Reprovado

**Observações Finais**: 
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________

