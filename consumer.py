import pika

# Укажите IP вашего RabbitMQ-сервера
rabbitmq_host = '192.168.10.117'
queue_name = 'hello'

# Устанавливаем соединение с RabbitMQ, используя нового пользователя
connection = pika.BlockingConnection(pika.ConnectionParameters(
    host=rabbitmq_host,
    credentials=pika.PlainCredentials('larin', 'SEk610i')  # используем нового пользователя
))
channel = connection.channel()

# Создаём очередь, если её ещё нет
channel.queue_declare(queue=queue_name)

# Определяем функцию обработки полученного сообщения
def callback(ch, method, properties, body):
    print(f" [x] Received {body}")

# Подписываемся на очередь и начинаем ожидать сообщений
channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=True)

print(' [*] Waiting for messages. To exit press Ctrl+C')
channel.start_consuming()

