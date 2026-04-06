# MotorFlow

**MotorFlow** é um aplicativo mobile para **gestão automotiva pessoal**: veículos, manutenções, abastecimentos e visão consolidada de custos e consumo — com experiência **Material 3**, dados **locais** e foco em clareza no dia a dia.

---

## Visão geral

O MotorFlow centraliza o que importa para quem dirige: cadastro de carros, histórico de serviços, registros de combustível e um painel com leitura rápida de métricas e alertas. O objetivo é reduzir atrito (menos planilhas, menos esquecimento) e manter o histórico sempre à mão, **sem depender de nuvem** para o núcleo do app.

---

## Principais funcionalidades

| Área | O que você encontra hoje |
|------|---------------------------|
| **Início (Dashboard)** | Resumo, métricas e sinais úteis para acompanhar o uso do veículo |
| **Carros** | Cadastro, listagem e detalhe do veículo |
| **Serviços** | Manutenções e histórico de serviços |
| **Combustível** | Abastecimentos, consumo e parâmetros de preço |
| **Ajustes** | Preferências e configurações do app |

Fluxos já presentes incluem cadastro de veículo, manutenção e abastecimento; cálculos de consumo e custos; alertas de manutenção no domínio; e tema visual unificado com componentes reutilizáveis (`mf_*`).

---

## Arquitetura do projeto

A base segue **camadas claras**, alinhadas ao que o código já reflete:

- **`lib/domain/`** — entidades, regras de negócio (ex.: métricas de combustível, motor de alertas de manutenção) e contrato do repositório
- **`lib/data/`** — implementação do repositório, **store local** (Isar / memória), modelo de **snapshot** e mapeadores
- **`lib/features/`** — telas e fluxos por funcionalidade (dashboard, veículos, manutenção, combustível, configurações)
- **`lib/core/`** — tema, tokens (cor, espaçamento, tipografia) e widgets compartilhados
- **`lib/presentation/`** — shell da aplicação (`HomeShell` com navegação inferior) e raiz do `MaterialApp`

A navegação principal usa **`IndexedStack`** com cinco destinos, preservando o estado das abas ao trocar entre elas.

---

## Stack

- **Flutter** (Dart)
- **Material 3** (`ThemeData` centralizado em `lib/core/theme/`)
- **Isar** — persistência local estruturada
- **`path_provider`** — diretório de suporte da aplicação para o banco
- **`intl`** — formatação de datas e números

Ferramentas de desenvolvimento: **`build_runner`** e **`isar_generator`** para código gerado do Isar, quando necessário.

---

## Persistência local com Isar

O estado persistido é modelado como um **snapshot versionado** (`MotorflowSnapshot`), armazenado no Isar com registro de chave fixa (`primaryKey = 1`), conforme `lib/data/local/isar_motorflow_local_store.dart` e `lib/data/models/motorflow_snapshot.dart`.

- Leitura e escrita passam por transações Isar onde aplicável
- Há **fail-safe**: falhas de storage não derrubam o app; o fluxo continua de forma degradada quando preciso
- O mapeamento entre entidade Isar e modelo de domínio fica em `lib/data/local/mapper/snapshot_mapper.dart`

Para desenvolvimento e testes sem disco, existe também um store em memória (`MemoryMotorflowLocalStore`).

---

## Status atual

**Em desenvolvimento ativo**, com fluxos principais utilizáveis: cadastros, listagens, métricas e persistência local real via Isar no `main` da aplicação. O produto evolui como app **100% local-first** no núcleo, com espaço para recursos futuros listados abaixo.

---

## Roadmap (próximas evoluções)

- Notificações e lembretes de manutenção
- Relatórios e visualizações mais ricas (gráficos, períodos)
- Central de alertas na UI
- Reforço de cenários multi-veículo e migrações de schema
- Backup e restauração (export/import)

*(Prioridades podem mudar conforme feedback e uso real.)*

---

## Como rodar o projeto

**Pré-requisitos:** Flutter SDK compatível com o `environment.sdk` do `pubspec.yaml` (Dart ^3.11.1).

```bash
cd motorflow
flutter pub get
flutter run
```

Se você alterar schemas Isar ou precisar regenerar código:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Testes e análise:**

```bash
flutter analyze
flutter test
```

---

## Override local do `isar_flutter_libs`

O `pubspec.yaml` declara um **`dependency_overrides`** apontando `isar_flutter_libs` para o pacote em **`packages/isar_flutter_libs`** (caminho local).

Isso permite alinhar binários/plugin à versão do Isar usada no projeto ou contornar incompatibilidades de ambiente sem abandonar o stack Isar 3.x. **Não remova** esse override sem verificar compatibilidade com a versão do `isar` e com as plataformas alvo; após mudanças, rode `flutter pub get` e teste em dispositivo ou emulador.

---

## Screenshots

*(Em breve: capturas de tela do dashboard, listas e fluxos de cadastro serão adicionadas aqui para o repositório público.)*

---

## Licença e contribuição

Este repositório está em evolução. Para sugestões ou issues, use o fluxo padrão do GitHub do projeto.
