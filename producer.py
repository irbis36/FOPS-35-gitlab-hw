import pika

# Укажите IP вашего RabbitMQ-сервера
rabbitmq_host = '192.168.10.108'
queue_name = 'hello'

# Устанавливаем соединение с RabbitMQ, используя нового пользователя
connection = pika.BlockingConnection(pika.ConnectionParameters(
    host=rabbitmq_host,
    credentials=pika.PlainCredentials('larin', 'SEk610i')  # используем нового пользователя
))
channel = connection.channel()

# Создаём очередь, если её ещё нет
channel.queue_declare(queue=queue_name)

# Отправляем сообщение в очередь
message = 'Hello, RabbitMQ!'  # сообщение для отправки
channel.basic_publish(exchange='',
                      routing_key=queue_name,
                      body=message)

print(f" [x] Sent '{message}'")

# Закрываем соединение
connection.close()
