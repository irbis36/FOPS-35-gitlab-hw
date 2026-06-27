# Домашнее задание к занятию «Основы Git»

## Автор: Ларин Владимир

---

## Окружение

- ОС: Ubuntu (VM2), Git 2.47.3
- Пользователь: Vladimir Larin / lrnvv@mail.ru
- Репозиторий: https://github.com/irbis36/devops-netology

```bash
root@vm2:~# git --version
git version 2.47.3

root@vm2:~# git config --list | grep -E "user.name|user.email"
user.name=Vladimir Larin
user.email=lrnvv@mail.ru
```

---

## Задание 1. Знакомимся с GitLab

Репозиторий `devops-netology` уже существовал с предыдущего задания. Проверил состояние:

```bash
root@vm2:~/devops-netology# git log --oneline -5
dd6c48d (HEAD -> main, origin/main, origin/HEAD) Moved and deleted
68f307c Prepare to delete and move
011bd81 Added gitignore
3080213 First commit
2a5a9aa Initial commit

root@vm2:~/devops-netology# git remote -v
origin  https://github.com/irbis36/devops-netology.git (fetch)
origin  https://github.com/irbis36/devops-netology.git (push)
```

Создал репозиторий `devops-netology` на GitLab (visibility: Public, без README).

**Скриншот 1 — репозиторий создан на GitLab:**

![GitLab репозиторий](screenshots/Screenshot_1.png)

Для аутентификации по HTTPS создал Personal Access Token в GitLab (Settings → Access Tokens, scopes: read_repository, write_repository).

Добавил GitLab как дополнительный remote:

```bash
root@vm2:~/devops-netology# git remote add gitlab https://irbis36-group:glpat-***@gitlab.com/irbis36-group/devops-netology.git

root@vm2:~/devops-netology# git remote -v
gitlab  https://irbis36-group:glpat-***@gitlab.com/irbis36-group/devops-netology.git (fetch)
gitlab  https://irbis36-group:glpat-***@gitlab.com/irbis36-group/devops-netology.git (push)
origin  https://github.com/irbis36/devops-netology.git (fetch)
origin  https://github.com/irbis36/devops-netology.git (push)
```

Запушил ветку `main` в GitLab:

```bash
root@vm2:~/devops-netology# git push -u gitlab main
Enumerating objects: 18, done.
Counting objects: 100% (18/18), done.
Compressing objects: 100% (11/11), done.
Writing objects: 100% (18/18), 2.92 KiB | 1.46 MiB/s, done.
Total 18 (delta 2), reused 3 (delta 0), pack-reused 0 (from 0)
To https://gitlab.com/irbis36-group/devops-netology.git
 * [new branch]      main -> main
branch 'main' set up to track 'gitlab/main'.
```

---

## Задание 2. Теги

Создал лёгковесный тег `v0.0` и аннотированный тег `v0.1`:

```bash
root@vm2:~/devops-netology# git tag v0.0
root@vm2:~/devops-netology# git tag -a v0.1 -m "Annotated tag v0.1"
root@vm2:~/devops-netology# git tag
v0.0
v0.1
```

Запушил теги в оба репозитория:

```bash
root@vm2:~/devops-netology# git push origin v0.0 v0.1
To https://github.com/irbis36/devops-netology.git
 * [new tag]         v0.0 -> v0.0
 * [new tag]         v0.1 -> v0.1

root@vm2:~/devops-netology# git push gitlab v0.0 v0.1
To https://gitlab.com/irbis36-group/devops-netology.git
 * [new tag]         v0.0 -> v0.0
 * [new tag]         v0.1 -> v0.1
```

**Скриншот 2 — теги в GitHub** (https://github.com/irbis36/devops-netology/tags):

![Теги GitHub](screenshots/Screenshot_2.png)

**Скриншот 3 — теги в GitLab** (https://gitlab.com/irbis36-group/devops-netology/-/tags):

![Теги GitLab](screenshots/Screenshot_3.png)

Разница между тегами: `v0.0` — лёгковесный, хранит только указатель на коммит. `v0.1` — аннотированный, хранит отдельный объект с сообщением, автором и датой. В GitLab это хорошо видно: у `v0.1` отображается текст `Annotated tag v0.1`, у `v0.0` — нет.

---

## Задание 3. Ветки

Нашёл хеш коммита `Prepare to delete and move`:

```bash
root@vm2:~/devops-netology# git log --oneline
dd6c48d Moved and deleted
68f307c Prepare to delete and move   <-- нужный коммит
011bd81 Added gitignore
3080213 First commit
2a5a9aa Initial commit
```

Переключился на коммит `68f307c`, создал ветку `fix` и запушил её:

```bash
root@vm2:~/devops-netology# git checkout 68f307c
HEAD is now at 68f307c Prepare to delete and move

root@vm2:~/devops-netology# git switch -c fix
Switched to a new branch 'fix'

root@vm2:~/devops-netology# git push -u origin fix
To https://github.com/irbis36/devops-netology.git
 * [new branch]      fix -> fix
branch 'fix' set up to track 'origin/fix'.
```

**Скриншот 4 — граф коммитов после создания ветки fix:**

![Network graph после создания fix](screenshots/Screenshot_4.png)

Добавил изменение в `README.md` и запушил:

```bash
root@vm2:~/devops-netology# echo -e "\n## Fix branch test line" >> README.md
root@vm2:~/devops-netology# git add README.md
root@vm2:~/devops-netology# git commit -m "fix: added test line to README"
[fix 51a2a9d] fix: added test line to README

root@vm2:~/devops-netology# git push
To https://github.com/irbis36/devops-netology.git
   68f307c..51a2a9d  fix -> fix
```

**Скриншот 5 — граф коммитов после коммита в ветку fix:**

![Network graph после коммита в fix](screenshots/Screenshot_5.png)

На графе видно, что ветка `fix` ответвляется от коммита `68f307c`, а `main` продолжается отдельно от коммита `dd6c48d`.

---

## Задание 4. Работа с визуальным редактором (Git GUI)

По заданию требовалось поработать с Git через визуальный редактор (рекомендуется PyCharm). PyCharm недоступен для скачивания с официального сайта без VPN. По рекомендации нейросети был использован **Git GUI** — штатный графический интерфейс, входящий в состав Git для Windows.

Репозиторий был открыт локально на Windows-машине (`F:\Hyper-V\devops-netology`). Переключился на ветку `fix` через Git Bash:

```bash
PS F:\Hyper-V\devops-netology> git checkout -b fix origin/fix
branch 'fix' set up to track 'origin/fix'.
Switched to a new branch 'fix'
```

В Git GUI открыт репозиторий, ветка `fix` активна. Внёс изменение в `README.md` (добавил строку `IDE commit test via Git GUI`), файл появился в разделе Unstaged Changes:

**Скриншот 6 — изменение README.md в Git GUI, файл в Unstaged Changes:**

![Git GUI unstaged](screenshots/Screenshot_6.png)

Выполнил Stage Changed → заполнил Commit Message → Commit → Push:

**Скриншот 7 — успешный push через Git GUI:**

![Git GUI push success](screenshots/Screenshot_7.png)

```
Pushing to https://github.com/irbis36/devops-netology.git
51a2a9d..57a3c6b  fix -> fix
Success
```

Проверка итогового состояния на Linux VM:

```bash
root@vm2:~/devops-netology# git fetch --all && git log --oneline --all --graph
* 57a3c6b (origin/fix) feat: test commit via Git GUI
* 51a2a9d (HEAD -> fix) fix: added test line to README
| * dd6c48d (tag: v0.1, tag: v0.0, origin/main, gitlab/main, main) Moved and deleted
|/
* 68f307c Prepare to delete and move
* 011bd81 Added gitignore
* 3080213 First commit
* 2a5a9aa Initial commit
```

---

## Итог

| Задание | Результат |
|---|---|
| Репозиторий на GitLab создан и заполнен | ✅ |
| remote `gitlab` добавлен, push выполнен | ✅ |
| Теги `v0.0` и `v0.1` созданы и запушены в GitHub и GitLab | ✅ |
| Ветка `fix` создана от нужного коммита, запушена в GitHub | ✅ |
| Коммиты через визуальный редактор (Git GUI) выполнены | ✅ |

**Ссылки на репозитории:**
- GitHub: https://github.com/irbis36/devops-netology
- GitLab: https://gitlab.com/irbis36-group/devops-netology
