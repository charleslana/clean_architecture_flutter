# TODO — adicionar as features que faltam

Este projeto consome `/posts`, `/users` e `/comments` da
[JSONPlaceholder](https://jsonplaceholder.typicode.com/). Restam três
endpoints para completar a API:

- [ ] `/albums`        — lista de álbuns (cada álbum pertence a um user)
- [ ] `/photos`        — fotos (cada foto pertence a um álbum)
- [ ] `/todos`         — to-dos (cada to-do pertence a um user)

A intenção deste documento é servir como **guia para quem pegar a base** —
qualquer feature nova segue exatamente o mesmo padrão. Use a feature
`comments` (entregue completa) como referência viva: ela cobre o caso
"recurso aninhado em outro" (`/posts/:id/comments`).

---

## Receita geral (vale para qualquer feature nova)

Para cada novo recurso da API (chamamos genericamente de `<feature>`),
crie/edite os arquivos abaixo na ordem. Cada passo é independente — se algo
quebrar, o `flutter analyze` aponta exatamente onde.

### 1. Domain model
`lib/domain/models/<feature_singular>.dart`

- Classe `@immutable` com construtor `const`, campos `final`, `==` e
  `hashCode` por mão.
- **Não** tem `fromJson`/`toJson` (isso é do API model).
- Use **records** para sub-objetos pequenos (ver `User.company` / `User.address`).

### 2. API model (DTO)
`lib/data/services/api/model/<feature_singular>_api_model.dart`

- Classe espelhando o JSON 1:1 (cada campo é `String`/`int`/etc).
- `factory <Feature>ApiModel.fromJson(Map<String, dynamic>)`.
- Método `toDomain()` que devolve o modelo de domínio.

### 3. Endpoint no `ApiClient`
`lib/data/services/api/api_client.dart`

Adicione um método (ou mais, se houver `getById`) seguindo o padrão dos
existentes:
```dart
Future<List<XxxApiModel>> getXxxs() async {
  final response = await _http.get(_baseUrl.resolve('/xxxs'));
  if (!response.isSuccessful) {
    throw HttpException(response.statusCode, 'Failed to load xxxs');
  }
  final list = jsonDecode(response.body) as List<dynamic>;
  return list
      .map((dynamic e) => XxxApiModel.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}
```

### 4. Repository (interface + impl remota)
`lib/data/repositories/<feature_plural>/<feature_plural>_repository.dart`
`lib/data/repositories/<feature_plural>/<feature_plural>_repository_remote.dart`

- Interface abstrata (`abstract class`) com os métodos retornando `Future<Result<T>>`.
- Implementação que chama o `ApiClient`, faz `dto.toDomain()` e captura
  `Exception → Result.error`.

### 5. Wiring no DI
`lib/config/dependencies.dart`

Adicione um `Provider<XxxRepository>` na seção apropriada (mantendo o
agrupamento `// ── Feature: xxx ──`).

### 6. UI: ViewModel
`lib/ui/<feature_plural>/view_models/<feature_plural>_list_viewmodel.dart`

Use `Command0` para a ação principal. Olhe o `UsersListViewModel` como
template mais simples. Para telas com múltiplas cargas em paralelo (ex.: a
mesma tela carrega posts E comments), olhe `PostDetailViewModel`.

### 7. UI: View
`lib/ui/<feature_plural>/widgets/<feature_plural>_list_screen.dart`

- `StatelessWidget` recebendo a `ViewModel` por construtor.
- `ListenableBuilder` em volta do command para reagir a `running`/`error`/`completed`.
- Em caso de erro, use o utilitário `errorMessageFor` para o `detail` do
  `ErrorIndicator`.
- Para navegar pra outra tela use `context.push(Routes.<feature>)`
  (assim o Scaffold já adiciona a seta de voltar).

### 8. Rota
`lib/config/routes.dart` — adicione a constante.
`lib/config/router.dart` — adicione o `GoRoute` dentro do `ShellRoute`,
construindo a `ViewModel` com `context.read<XxxRepository>()`.

### 9. Home
`lib/ui/home/widgets/home_screen.dart` — adicione um `_HomeTile` apontando
para a nova rota.

### 10. Testes
- `test/utils/fakes.dart` — adicione amostras `fakeXxx1/2` e
  `FakeXxxRepository implements XxxRepository`.
- `test/data/repositories/<feature_plural>/<feature_plural>_repository_remote_test.dart` —
  use `FakeHttpService` (200 e não-200 cobertos).
- `test/ui/<feature_plural>/view_models/<feature_plural>_list_viewmodel_test.dart` —
  sucesso, falha, re-execução do command.
- (Opcional, mas recomendado) widget test da tela.

---

## Checklist específico por feature

### `/albums` (modelo "lista simples")
Endpoint: `GET https://jsonplaceholder.typicode.com/albums`
Shape:
```json
{ "userId": 1, "id": 1, "title": "..." }
```

- [ ] `lib/domain/models/album.dart`
- [ ] `lib/data/services/api/model/album_api_model.dart`
- [ ] `ApiClient.getAlbums()`
- [ ] `lib/data/repositories/albums/{albums_repository,albums_repository_remote}.dart`
- [ ] DI em `dependencies.dart` (seção "Feature: albums")
- [ ] `lib/ui/albums/view_models/albums_list_viewmodel.dart`
- [ ] `lib/ui/albums/widgets/albums_list_screen.dart`
- [ ] Constante de rota + `GoRoute` no `ShellRoute`
- [ ] Tile na `HomeScreen`
- [ ] Testes (fakes, repo, viewmodel)

> Use `UsersListViewModel`/`UsersListScreen` como template — tem o mesmo
> formato (lista simples sem detalhe).

### `/photos` (modelo "lista grande, possivelmente paginada")
Endpoint: `GET /photos` (5000 itens — listar todos é OK pra demo, mas
considere paginar `?_start=0&_limit=20`).
Shape:
```json
{ "albumId": 1, "id": 1, "title": "...", "url": "...", "thumbnailUrl": "..." }
```

- [ ] Mesma receita acima.
- [ ] **Considerar**: filtrar por `albumId` (ex.: `/albums/:id/photos`) na
  tela de detalhe do álbum, espelhando o que `comments` fez com posts.
- [ ] Renderizar a thumbnail com `Image.network(photo.thumbnailUrl)` —
  testar offline mode no banner para ver `errorBuilder` do `Image.network`
  cair quando `noInternet` está ativo.

### `/todos` (modelo "com booleano + filtro")
Endpoint: `GET /todos`
Shape:
```json
{ "userId": 1, "id": 1, "title": "...", "completed": false }
```

- [ ] Receita padrão.
- [ ] **Demonstrar UI state no ViewModel**: adicionar um `bool showCompleted`
  e um command `toggleCompleted()` que chama `notifyListeners`. A View
  observa o bool e filtra a lista. Esse é o padrão recomendado pelo guia
  ("ViewModel maintains UI state").

---

## Antes de abrir o PR

- [ ] `flutter analyze` → `No issues found!`
- [ ] `flutter test` → todos verdes
- [ ] Testar manualmente cada modo do `ErrorBanner` na tela nova
  (timeout, no internet, 404, 500, **422 unmapped**) — todos devem cair no
  `ErrorIndicator` com `detail` legível.
- [ ] README §3 atualizado com a nova pasta na árvore de estrutura.

---

## Como esse projeto te ajuda

A arquitetura faz com que **cada feature acima seja basicamente um
copy/paste mecânico das pastas existentes**. Você não precisa entender o
resto do app; só precisa seguir os passos numerados. Quando terminar, o
diff vai estar 100% concentrado na pasta da nova feature, e os testes
existentes continuarão verdes — o que prova que você não quebrou nada.

Boa sorte.
