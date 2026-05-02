# clean_architecture_flutter

Projeto de estudo aplicando a arquitetura recomendada oficialmente pelo time
do Flutter, descrita em
[docs.flutter.dev/app-architecture/guide](https://docs.flutter.dev/app-architecture/guide).

A API consumida é a [JSONPlaceholder](https://jsonplaceholder.typicode.com/)
(endpoints `/posts` e `/users`).

---

## 1. Por que esta arquitetura?

O guia oficial recomenda **MVVM em camadas**.

**MVVM = Model · View · ViewModel** — três responsabilidades, uma por letra:

- **M — Model**: o **dado** e as regras que o cercam. Aqui são os modelos
  imutáveis em [`lib/domain/models/`](lib/domain/models) (`Post`, `User`) e
  as classes da camada de dados que produzem esses modelos
  ([`Repository`](lib/data/repositories) + [`Service/ApiClient`](lib/data/services/api/api_client.dart)).
  O Model não conhece a UI.
- **V — View**: o **widget** que desenha pixels. Stateless, "burra":
  só lê estado da ViewModel e dispara comandos. Ex.:
  [`PostsListScreen`](lib/ui/posts/widgets/posts_list_screen.dart). Sem
  HTTP, sem `setState` de regra de negócio, sem cache.
- **VM — ViewModel**: a **ponte**. Pega dados do Model, transforma para o
  formato que a View precisa, guarda UI state (loading, erro, seleção…) e
  expõe `Command`s que a View chama em resposta a interação do usuário. Ex.:
  [`PostsListViewModel`](lib/ui/posts/view_models/posts_list_viewmodel.dart).
  Em Flutter, ela costuma ser um `ChangeNotifier`. Cada View tem **uma**
  ViewModel (1:1).

Ou seja, o fluxo é sempre `View ⇄ ViewModel ⇄ Model` — a View nunca fala
direto com o Model.

Por que essa arquitetura?

- **Separação de responsabilidades** — UI não conhece HTTP, repositório não
  conhece widgets.
- **Testabilidade** — cada camada é testada isoladamente trocando dependências
  por _fakes_/_mocks_.
- **Escalabilidade** — features são adicionadas sem mexer em código existente.
- **Fluxo de dados unidirecional** — estado desce, eventos sobem; menos bugs.

> _"UI = f(state)"_ — a UI é função do estado imutável vindo da camada de
> dados.

---

## 2. Camadas

```
┌────────────────────────── UI Layer ──────────────────────────┐
│  View (Widget)  ──►  ViewModel (ChangeNotifier + Commands)   │
└──────────────────────────────────────────────────────────────┘
                          ▲     ▼
┌──────────────── Domain Layer (opcional) ─────────────────────┐
│            Modelos imutáveis · Use cases (quando precisar)   │
└──────────────────────────────────────────────────────────────┘
                          ▲     ▼
┌────────────────────────── Data Layer ────────────────────────┐
│  Repository (abstract + impl)  ──►  Service (ApiClient)      │
└──────────────────────────────────────────────────────────────┘
```

| Camada       | Responsabilidade                                                 | Conhece               |
|--------------|------------------------------------------------------------------|-----------------------|
| **View**     | Renderizar estado, repassar eventos, layout, animação.           | Sua própria ViewModel |
| **ViewModel**| Manter UI state, transformar dados do repositório, expor commands. | Repositórios          |
| **Repository** | _Source of truth_, cache, retries, mapeia DTO → domínio.       | Services              |
| **Service**  | Apenas falar com fonte externa (HTTP, DB). Sem estado.            | Mundo externo         |

Regras importantes do guia:

- View **nunca** acessa Repository ou Service.
- Repositories **nunca** dependem de outros repositories.
- ViewModel é 1:1 com a View.
- Dependências são **privadas** (`_apiClient`) e injetadas via construtor.

---

## 3. Estrutura de pastas

A estrutura segue exatamente o _case study_ do guia oficial
([Compass App](https://github.com/flutter/samples/tree/main/compass_app)) e
adota organização **vertical por feature** dentro de cada camada — ou seja,
em `data/repositories/`, `ui/` (e, quando precisar, `domain/use_cases/`)
**cada subpasta nomeada é uma feature** do app. Aqui temos duas:
[`posts/`](lib/ui/posts) e [`users/`](lib/ui/users). Adicionar uma nova
feature = criar uma pasta nova com o mesmo nome nas três camadas.

```
lib/
├── main.dart                       # Bootstrapping (MultiProvider + MaterialApp.router)
├── config/
│   ├── dependencies.dart           # Lista de Providers (DI)
│   ├── router.dart                 # go_router + instanciação de ViewModels
│   └── routes.dart                 # Constantes de rota
├── data/
│   ├── repositories/               # ⬇️ uma subpasta por FEATURE
│   │   ├── comments/               # 🟨 feature: comments (usados na tela de detalhe)
│   │   │   ├── comments_repository.dart
│   │   │   └── comments_repository_remote.dart
│   │   ├── posts/                  # 🟦 feature: posts
│   │   │   ├── posts_repository.dart           # interface
│   │   │   └── posts_repository_remote.dart    # impl HTTP
│   │   └── users/                  # 🟩 feature: users
│   │       ├── users_repository.dart
│   │       └── users_repository_remote.dart
│   └── services/                   # ⬇️ services são CROSS-FEATURE
│       ├── api/                    #     (api_client é compartilhado)
│       │   ├── api_client.dart                 # service stateless
│       │   └── model/
│       │       ├── comment_api_model.dart      # DTO + toDomain()
│       │       ├── post_api_model.dart
│       │       └── user_api_model.dart
│       └── http/                   # ⬇️ camada HTTP isolada (ver §4.6)
│           ├── http_service.dart                # interface + HttpResponse
│           ├── http_service_http.dart           # impl com package:http
│           ├── error_injector.dart              # ErrorMode + listenable
│           └── error_injecting_http_service.dart # decorator (interceptor)
├── domain/
│   └── models/                     # modelos de domínio (compartilháveis entre features)
│       ├── comment.dart
│       ├── post.dart                           # modelo imutável
│       └── user.dart                           # usa records p/ company/address
├── ui/
│   ├── core/                       # widgets/utilidades CROSS-FEATURE
│   │   └── ui/
│   │       ├── error_indicator.dart            # widget reaproveitável
│   │       └── error_banner.dart                # debug strip do ShellRoute (§4.6)
│   ├── home/                       # 🟪 feature: home (entry point)
│   │   └── widgets/
│   │       └── home_screen.dart
│   ├── posts/                      # 🟦 feature: posts
│   │   ├── view_models/
│   │   │   ├── posts_list_viewmodel.dart
│   │   │   └── post_detail_viewmodel.dart
│   │   └── widgets/
│   │       ├── posts_list_screen.dart
│   │       └── post_detail_screen.dart
│   └── users/                      # 🟩 feature: users
│       ├── view_models/
│       │   └── users_list_viewmodel.dart
│       └── widgets/
│           └── users_list_screen.dart
└── utils/                          # building blocks da arquitetura (não-feature)
    ├── result.dart                 # sealed Result<T> = Ok | Error
    └── command.dart                # Command0 / Command1
```

> **Por que feature-based?** O guia oficial recomenda separar por
> "_feature or functionality_" (ex.: lógica de auth fica longe da lógica de
> busca). Em vez de ter uma pasta `view_models/` gigante com tudo junto, cada
> feature carrega o próprio trio _repositório / view-models / views_. Isso
> mantém commits e PRs focados, facilita remover uma feature inteira (basta
> deletar a pasta nas 3 camadas) e dá pra dois devs trabalharem em features
> diferentes sem conflito.

---

## 4. Padrões usados

### 4.1 Result pattern
A camada de dados nunca lança exceções pra cima — ela retorna
`Result<T> = Ok(value) | Error(exception)`. A ViewModel decide como reagir
(ex.: mostrar erro, manter cache, etc.) sem precisar de `try/catch`.

### 4.2 Command pattern
Toda ação assíncrona disparada pela View é encapsulada num `Command0` ou
`Command1`. Ele expõe `running`, `error`, `result` e impede re-entrância. A
View só dá `viewModel.load.execute()` e ouve com `ListenableBuilder`.

### 4.3 Domain model imutável + Records
Modelos são classes `@immutable` com `==`/`hashCode` por mão (sem
code-gen). Para sub-objetos pequenos (ex.: `company`, `address`) usamos
**Dart records** — exatamente o uso recomendado pelo guia para "agrupar
valores relacionados sem criar uma classe completa".

> Records **não substituem** modelos de domínio: não suportam `fromJson`, não
> têm nome de tipo distinto e não levam métodos. Por isso `Post` e `User`
> continuam classes.

### 4.4 Dependency Injection (Provider)
- `ApiClient`, `PostsRepository`, `UsersRepository` são registrados em
  [`lib/config/dependencies.dart`](lib/config/dependencies.dart) e expostos
  pelos seus tipos **abstratos**.
- ViewModels são instanciadas no `builder` de cada `GoRoute`
  ([`lib/config/router.dart`](lib/config/router.dart)) — vivem o tempo da tela.

### 4.5 Navegação (go_router)
O guia recomenda `go_router` para ~90% dos apps. As rotas são tipadas em
[`lib/config/routes.dart`](lib/config/routes.dart) e usadas como `context.go(...)`.

### 4.6 Camada HTTP + injeção de erros (ShellRoute)

O app **não chama `package:http` direto** em lugar nenhum acima da camada de
serviços. Toda chamada de rede passa pela interface
[`HttpService`](lib/data/services/http/http_service.dart), que define
`get/post/put/patch/delete` retornando um `HttpResponse` neutro. Isso
significa que trocar `http` por `dio`, `chopper` ou qualquer outro pacote é
mexer em **um único arquivo**:
[`http_service_http.dart`](lib/data/services/http/http_service_http.dart).

A pilha HTTP é composta como uma cadeia de decorators:

```
                    ┌──────────────┐
                    │  ApiClient   │   só conhece HttpService
                    └──────┬───────┘
                           ▼
        ┌─────────────────────────────────────┐
        │   ErrorInjectingHttpService         │   decorator (interceptor)
        │   (consulta o ErrorInjector)        │
        └──────┬──────────────────────────────┘
               ▼
        ┌─────────────────────────────────────┐
        │   HttpServiceHttp                   │   ÚNICO arquivo que importa
        │   (impl real com package:http)      │   `package:http`
        └─────────────────────────────────────┘
```

Em cima dessa camada existe um **`ShellRoute`** do `go_router` que renderiza
um [`ErrorBanner`](lib/ui/core/ui/error_banner.dart) persistente em todas as
telas. O banner é um dropdown que escreve no
[`ErrorInjector`](lib/data/services/http/error_injector.dart) (`ChangeNotifier`)
o `ErrorMode` ativo. Modos disponíveis:

| Modo                     | O que o repositório vê                          | Como aparece na UI                |
|--------------------------|-------------------------------------------------|-----------------------------------|
| `none`                   | comportamento normal (rede real)                | —                                 |
| `timeout`                | `TimeoutException` após ~600 ms                 | "Timeout"                         |
| `noInternet`             | `SocketException` (igual offline real)          | "No internet"                     |
| `400` Bad Request        | `HttpResponse(400)` → `HttpException` no caller | "400 Bad Request"                 |
| `401` Unauthorized       | idem                                            | "401 Unauthorized"                |
| `403` Forbidden          | idem                                            | "403 Forbidden"                   |
| `404` Not Found          | idem                                            | "404 Not Found"                   |
| `422` Unprocessable Entity (**não-mapeado**) | idem               | "422 (unmapped status)" ← fallback |
| `429` Too Many Requests  | idem                                            | "429 Too Many Requests"           |
| `500` Internal Server    | idem                                            | "500 Internal Server Error"       |
| `502` Bad Gateway        | idem                                            | "502 Bad Gateway"                 |
| `503` Service Unavailable| idem                                            | "503 Service Unavailable"         |

> Nada na UI nem nos repositórios precisa saber que existe injetor. Eles só
> recebem o erro **exatamente como receberiam da rede real** e disparam o
> caminho `try/catch` → `Result.error` → `ErrorIndicator` que já existia.
> Para testar, escolha um modo no banner e dê _pull-to-refresh_ na lista.

A coluna "Como aparece na UI" é produzida pelo util
[`errorMessageFor`](lib/utils/error_message.dart): mapeia
`TimeoutException` / `SocketException` / `HttpException(statusCode)` para
labels curtos. Status que não estão na tabela (ex.: 422, 418) caem no
fallback `"<code> (unmapped status)"` em vez de mostrar
`Instance of 'HttpException'` — o 422 está intencionalmente fora do mapa pra
exercitar exatamente esse caminho.

---

## 5. Fluxo unidirecional (exemplo: abrir lista de posts)

```
1. View (PostsListScreen) faz `context.go('/posts')`
2. Router cria PostsListViewModel(postsRepository: …)
3. ViewModel.load (Command0) é executado no construtor
4. Command chama PostsRepositoryRemote.getPosts()
5. Repository chama ApiClient.getPosts() → DTOs
6. Repository converte DTO → Post (domínio) e devolve Result.ok([…])
7. ViewModel guarda lista, notifyListeners()
8. ListenableBuilder reconstrói a UI
```

Erro? O passo 5/6 retorna `Result.error`, a View reage via
`viewModel.load.error` mostrando o `ErrorIndicator`.

---

## 6. Pacotes

| Pacote      | Por quê                                                       |
|-------------|---------------------------------------------------------------|
| `provider`  | DI recomendada pelo guia oficial.                             |
| `go_router` | Navegação recomendada pelo guia oficial.                      |
| `http`      | Cliente HTTP simples e oficial do Dart team.                  |

Linter ativo em [`analysis_options.yaml`](analysis_options.yaml) baseado nas
regras usadas pelo time do Flutter no Compass App
(`flutter_lints` + `strict-casts/inference/raw-types` + lints extras).

---

## 7. Como rodar

```bash
flutter pub get
flutter run
flutter analyze   # esperado: No issues found!
flutter test      # 16 testes, todos verdes
```

A primeira tela é a Home (`/`); a partir dela navega-se para `/posts` ou
`/users` via `context.push`, e o `Scaffold` adiciona automaticamente a seta
de voltar até retornar à Home.

---

## 8. Testes

A suíte testa cada camada **isoladamente**, exatamente como o guia recomenda.
São usados **fakes feitos à mão** em vez de mocks gerados — sem `mockito`,
sem `build_runner`. Os fakes ficam em
[`test/utils/fakes.dart`](test/utils/fakes.dart) e são reaproveitados por
todos os testes.

```
test/
├── utils/fakes.dart                                      # Fakes compartilhados
├── data/repositories/
│   ├── posts/posts_repository_remote_test.dart           # MockClient (http)
│   └── users/users_repository_remote_test.dart
├── ui/
│   ├── posts/
│   │   ├── view_models/posts_list_viewmodel_test.dart    # FakePostsRepository
│   │   ├── view_models/post_detail_viewmodel_test.dart
│   │   └── widgets/posts_list_screen_test.dart           # widget test E2E
│   └── users/view_models/users_list_viewmodel_test.dart
```

| Camada     | Estratégia                                                                          |
|------------|-------------------------------------------------------------------------------------|
| Repository | Real `ApiClient` + [`MockClient`](https://pub.dev/documentation/http/latest/testing/MockClient-class.html) do `package:http` para simular respostas HTTP. |
| ViewModel  | `FakePostsRepository` / `FakeUsersRepository` — verifica chamadas, estado e ramo de erro. |
| View       | `PostsListScreen` real + ViewModel real + Fake repo (testa spinner / lista / erro / retry). |

Pontos cobertos:

- Mapeamento DTO → domínio (incl. records de `company`/`address`).
- Conversão de exceção em `Result.error` na fronteira do repositório.
- Estado inicial `running` do `Command0` (com `Completer` controlado pelo teste).
- Re-execução do command (pull-to-refresh).
- Render de erro + clique no botão "Try again".

---

## 9. Onde estender

| Quero adicionar…                    | Onde                                                 |
|-------------------------------------|------------------------------------------------------|
| Uma nova tela                       | `lib/ui/<feature>/widgets/` + `view_models/`         |
| Um novo endpoint                    | método em `ApiClient` + DTO em `services/api/model/` |
| Uma nova fonte de dados (cache, DB) | nova impl de Repository (mantém a interface)         |
| Uma rota                            | `lib/config/routes.dart` + entrada em `router.dart`  |
| Lógica usada por várias ViewModels  | criar uma `UseCase` em `lib/domain/usecases/`        |

---

## 10. Referências

- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Architecture Concepts](https://docs.flutter.dev/app-architecture/concepts)
- [Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Design Patterns (Result, Command, Optimistic State, …)](https://docs.flutter.dev/app-architecture/design-patterns)
- [Case Study — Dependency Injection](https://docs.flutter.dev/app-architecture/case-study/dependency-injection)
- [Compass App (sample oficial)](https://github.com/flutter/samples/tree/main/compass_app)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)
