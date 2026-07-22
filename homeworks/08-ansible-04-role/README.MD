# Домашнее задание к занятию 4 «Работа с roles»

## Автор: Ларин Владимир

---

## Подготовка к выполнению

Для начала сгенерировал SSH-ключ и добавил его в GitHub, чтобы можно было пушить по SSH. Потом создал два пустых публичных репозитория — `vector-role` и `lighthouse-role`. Также установил Ansible и Git на свою машину (Debian 13).

```bash
ssh-keygen -t ed25519 -C "larin" -f /root/.ssh/id_ed25519 -N ""
apt install -y ansible git
```

Проверил подключение к GitHub:

```
ssh -T git@github.com
Hi irbis36! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## Основная часть

### 1. Создал файл `requirements.yml`

Заполнил его ссылкой на готовую роль clickhouse:

```yaml
---
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.13"
    name: clickhouse
```

### 2. Скачал роль clickhouse через ansible-galaxy

```bash
ansible-galaxy install -r requirements.yml -p roles
```

Роль успешно скачалась в `roles/clickhouse`.

### 3. Создал роль vector-role

```bash
ansible-galaxy role init vector-role
```

Команда создала стандартную структуру каталогов для роли.

### 4–5. Заполнил роль vector-role

Разнёс переменные:

- `defaults/main.yml` — переменные, которые пользователь может переопределить (версия Vector, путь к конфигу)
- `vars/main.yml` — внутренние переменные (URL скачивания, каталог установки)

Задачи в `tasks/main.yml`: скачивание архива, распаковка, создание конфига из шаблона, настройка systemd-юнита.

Шаблоны в `templates/`: конфиг `vector.yml.j2` и systemd-юнит `vector.service.j2`.

### 6. Описал роль в README.md

В README указал какие переменные есть, что можно менять, пример использования в playbook.

### 7. Повторил шаги 3–6 для Lighthouse

```bash
ansible-galaxy role init lighthouse-role
```

Роль lighthouse ставит nginx и git, клонирует репозиторий Lighthouse, раскладывает конфиг nginx через шаблон. Всё тоже разнесено по defaults/vars/tasks/templates/handlers.

### 8. Выложил роли в репозитории с тегами

Для каждой роли сделал `git init`, закоммитил и запушил с тегом `1.0.0`:

```bash
git tag 1.0.0
git push origin 1.0.0
```

Добавил обе роли в `requirements.yml`:

```yaml
---
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.13"
    name: clickhouse

  - src: git@github.com:irbis36/vector-role.git
    scm: git
    version: "1.0.0"
    name: vector-role

  - src: git@github.com:irbis36/lighthouse-role.git
    scm: git
    version: "1.0.0"
    name: lighthouse-role
```

### 9. Переработал playbook на использование ролей

Файл `site.yml`:

```yaml
---
- name: Install Clickhouse
  hosts: clickhouse
  roles:
    - clickhouse

- name: Install Vector
  hosts: vector
  roles:
    - vector-role

- name: Install Lighthouse
  hosts: lighthouse
  roles:
    - lighthouse-role
```

Инвентарь `inventory/prod.yml` содержит три группы хостов: clickhouse, vector, lighthouse.

### 10–11. Ссылки на репозитории

| Репозиторий | Ссылка |
|---|---|
| vector-role | https://github.com/irbis36/vector-role |
| lighthouse-role | https://github.com/irbis36/lighthouse-role |
| playbook | https://github.com/irbis36/FOPS-35-gitlab-hw/tree/main/homeworks/08-ansible-04-role |
