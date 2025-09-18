# To-Do List App

Um aplicativo simples de Lista de Tarefas feito em Flutter.

## Funcionalidades
- Adicionar nova tarefa
- Editar tarefa
- Marcar tarefa como concluída
- Remover tarefa
- Filtrar tarefas (todas, pendentes, concluídas)
- Interface moderna com cards, animações e tema escuro/claro
- Persistência local das tarefas

## Como executar

1. Instale as dependências:
   ```bash
   flutter pub get
   ```

2. Execute o app:
   - Web:
     ```bash
     flutter run -d chrome
     ```
   - Android:
     ```bash
     flutter run -d emulator-5554
     ```
   - Desktop (Linux, Windows, macOS):
     ```bash
     flutter run -d linux
     ```
     (ou troque `linux` por `windows` ou `macos` conforme seu sistema)

## Estrutura do projeto
- `lib/models/task.dart`: Modelo da tarefa
- `lib/utils/storage.dart`: Persistência local
- `lib/screens/home_screen.dart`: Tela principal
- `lib/widgets/task_input.dart`: Campo de entrada de tarefa
- `lib/widgets/task_tile.dart`: Item visual de tarefa
- `pubspec.yaml`: Dependências do projeto

## Observações
- O projeto pode ser executado em web, Android, Windows, Linux e macOS.
- Para entregar, suba o código no GitHub e envie o link conforme solicitado.

---

Feito para fins acadêmicos.
