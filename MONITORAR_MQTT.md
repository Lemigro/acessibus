# 📡 Como Monitorar Mensagens MQTT no Servidor DigitalOcean

## 🖥️ Opção 1: Via Terminal SSH (Recomendado)

### 1. Conecte-se ao servidor via SSH:
```bash
ssh root@134.209.9.157
# ou
ssh seu_usuario@134.209.9.157
```

### 2. Instale o Mosquitto Client (se não tiver):
```bash
sudo apt update
sudo apt install mosquitto-clients -y
```

### 3. Monitore TODAS as mensagens MQTT:
```bash
mosquitto_sub -h localhost -p 1883 -u acessibus -P 123456 -t "#" -v
```

**Explicação:**
- `-h localhost` - Host (use localhost se estiver no servidor)
- `-p 1883` - Porta
- `-u acessibus` - Usuário
- `-P 123456` - Senha
- `-t "#"` - Tópico wildcard (recebe TODOS os tópicos)
- `-v` - Modo verbose (mostra tópico + mensagem)

### 4. Monitorar tópicos específicos:

**Seleções de botões:**
```bash
mosquitto_sub -h localhost -p 1883 -u acessibus -P 123456 -t "paradas/selecao/+" -v
```

**Localização do ônibus:**
```bash
mosquitto_sub -h localhost -p 1883 -u acessibus -P 123456 -t "localizacao_onibus/+" -v
```

**Chegada de ônibus:**
```bash
mosquitto_sub -h localhost -p 1883 -u acessibus -P 123456 -t "onibus/chegando/+" -v
```

**Tudo relacionado a paradas:**
```bash
mosquitto_sub -h localhost -p 1883 -u acessibus -P 123456 -t "paradas/#" -v
```

## 🖥️ Opção 2: Ver Logs do Mosquitto

### Ver logs em tempo real:
```bash
sudo tail -f /var/log/mosquitto/mosquitto.log
```

### Ver últimas 100 linhas:
```bash
sudo tail -n 100 /var/log/mosquitto/mosquitto.log
```

## 💻 Opção 3: Ferramentas Gráficas (Recomendado para Testes)

### MQTT Explorer (Windows/Mac/Linux)
1. Baixe: https://mqtt-explorer.com/
2. Configure:
   - Host: `134.209.9.157`
   - Port: `1883`
   - Username: `acessibus`
   - Password: `123456`
3. Clique em "Connect"
4. Veja todas as mensagens em tempo real!

### MQTT.fx (Windows/Mac/Linux)
1. Baixe: https://mqttfx.jensd.de/
2. Configure as mesmas credenciais
3. Conecte e monitore

### HiveMQ WebSocket Client (Navegador)
1. Acesse: http://www.hivemq.com/demos/websocket-client/
2. Configure:
   - Host: `134.209.9.157`
   - Port: `1883` (ou `9001` se usar WebSocket)
   - Username: `acessibus`
   - Password: `123456`

## 📊 Opção 4: Script Python para Monitorar

Crie um arquivo `monitor_mqtt.py` no servidor:

```python
#!/usr/bin/env python3
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Conectado com código {rc}")
    client.subscribe("#")  # Todos os tópicos

def on_message(client, userdata, msg):
    print(f"Tópico: {msg.topic}")
    print(f"Mensagem: {msg.payload.decode()}")
    print("-" * 50)

client = mqtt.Client()
client.username_pw_set("acessibus", "123456")
client.on_connect = on_connect
client.on_message = on_message

client.connect("134.209.9.157", 1883, 60)
client.loop_forever()
```

Execute:
```bash
python3 monitor_mqtt.py
```

## 🔍 Verificar Status do Mosquitto

### Ver se está rodando:
```bash
sudo systemctl status mosquitto
```

### Ver conexões ativas:
```bash
sudo netstat -tulpn | grep 1883
```

### Ver processos MQTT:
```bash
ps aux | grep mosquitto
```

## 📝 Exemplo de Saída Esperada

Quando você pressionar os botões no Arduino, deve ver:

```
paradas/selecao/parada_123 {"linha":"132A","tipo":"VISUAL"}
paradas/selecao/parada_123 {"linha":"251B","tipo":"AUDITIVO"}
localizacao_onibus/linha_132A {"lat":-8.047600,"lon":-34.877000}
onibus/chegando/parada_123 {"linha":"132A"}
```

## ⚠️ Troubleshooting

### Se não conseguir conectar:
1. Verifique firewall:
```bash
sudo ufw status
sudo ufw allow 1883/tcp
```

2. Verifique se Mosquitto está escutando:
```bash
sudo netstat -tulpn | grep 1883
```

3. Verifique configuração do Mosquitto:
```bash
sudo nano /etc/mosquitto/mosquitto.conf
```

Certifique-se de ter:
```
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
```

## 🚀 Comando Rápido (Copiar e Colar)

```bash
mosquitto_sub -h localhost -p 1883 -u acessibus -P 123456 -t "#" -v
```

Este comando mostra TODAS as mensagens MQTT em tempo real!

