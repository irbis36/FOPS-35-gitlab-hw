# Домашнее задание: Инструменты Git

## Автор: Ларин Владимир

---

## Подготовка

Клонируем репозиторий и переходим в него:

```bash
git clone https://github.com/hashicorp/terraform
cd terraform
```

---

## 1. Полный хеш и комментарий коммита `aefea`

```bash
git show aefea
```

```
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

    Update CHANGELOG.md
```

**Полный хеш:** `aefead2207ef7e2aa5dc81a34aedf0cad4c32545`  
**Комментарий:** `Update CHANGELOG.md`

---

## 2. Какому тегу соответствует коммит `85024d3`?

```bash
git tag --points-at 85024d3
```

```
v0.12.23
```

**Ответ:** коммит `85024d3` соответствует тегу `v0.12.23`

---

## 3. Сколько родителей у коммита `b8d720`? Их хеши.

```bash
git log --pretty=format:"%P" -1 b8d720
```

```
56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
```

**Ответ:** у коммита два родителя — это merge-коммит.

- `56cd7859e05c36c06b56d013b55a252d0bb7e158`
- `9ea88f22fc6269854151c571162c5bcf958bee2b`

---

## 4. Коммиты между тегами `v0.12.23` и `v0.12.24`

```bash
git log v0.12.23..v0.12.24 --pretty=format:"%H %s"
```

```
33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release
```

**Ответ:** между тегами `v0.12.23` и `v0.12.24` было сделано 10 коммитов.

---

## 5. Коммит, в котором была создана функция `func providerSource`

```bash
git log -S 'func providerSource' --pretty=format:"%H %s"
```

```
5af1e6234ab6da412fb8637393c5a17a1b293663 main: Honor explicit provider_installation CLI config when present
8c928e83589d90a031f811fae52a81be7153e82f main: Consult local directories as potential mirrors of providers
```

Для определения коммита, в котором функция была именно создана, проверяем содержимое более раннего коммита:

```bash
git show 8c928e83589d90a031f811fae52a81be7153e82f | grep -A 5 'func providerSource'
```

```
+func providerSource(services *disco.Disco) getproviders.Source {
+       // We're not yet using the CLI config here because we've not implemented
+       // yet the new configuration constructs to customize provider search
+       // locations. That'll come later.
+       // For now, we have a fixed set of search directories:
```

Знак `+` означает добавление строки — функция создана в этом коммите.

**Ответ:** функция `func providerSource` была создана в коммите:  
`8c928e83589d90a031f811fae52a81be7153e82f` — `main: Consult local directories as potential mirrors of providers`

---

## 6. Коммиты, в которых изменялась функция `globalPluginDirs`

Так как функция уже не существует в текущей ветке, используем `-G` для поиска по всей истории:

```bash
git log -G 'globalPluginDirs' --pretty=format:"%H %s" -- '*.go'
```

```
7c4aeac5f30aed09c5ef3198141b033eea9912be stacks: load credentials from config file on startup (#35952)
22a2580e93170eac46621ab97decaec989d52edb main: Use the new cliconfig package credentials source
35a058fb3ddfae9cfee0b3893822c9a95b920f4c main: configure credentials from the CLI config file
c0b17610965450a89598da491ce9b6b5cbd6393f prevent log output during init
8364383c359a6b738a436d1b7745ccdce178df47 Push plugin discovery down into command package
```

**Ответ:** функция `globalPluginDirs` изменялась в 5 коммитах, перечислены выше.

---

## 7. Автор функции `synchronizedWriters`

```bash
git log -S 'func synchronizedWriters' --pretty=format:"%H %an %s"
```

```
bdfea50cc85161dea41be0fe3381fd98731ff786 James Bardin remove unused
5ac311e2a91e381e2f52234668b49ba670aa0fe5 Martin Atkins main: synchronize writes to VT100-faker on Windows
```

Более ранний коммит — `5ac311e2...` (Martin Atkins) — это создание функции.  
Коммит `bdfea50c...` (James Bardin) — удаление функции как неиспользуемой.

**Ответ:** автор функции `synchronizedWriters` — **Martin Atkins**

---

## Использованные команды

| Команда | Описание |
|---------|----------|
| `git show <hash>` | Показывает информацию о коммите: автор, дата, комментарий, diff |
| `git tag --points-at <hash>` | Показывает тег, которому соответствует указанный коммит |
| `git log --pretty=format:"%P" -1 <hash>` | Выводит хеши родительских коммитов (для определения merge-коммитов) |
| `git log <tag1>..<tag2> --pretty=format:"%H %s"` | Выводит список коммитов между двумя тегами |
| `git log -S 'pattern'` | Ищет коммиты, в которых строка была добавлена или удалена |
| `git log -G 'pattern' -- '*.go'` | Ищет коммиты, в которых строка изменялась (включая контекст) |
| `git show <hash> \| grep -A N 'pattern'` | Показывает изменения в коммите с контекстом вокруг найденной строки |
