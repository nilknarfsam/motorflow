# MotorFlow

Aplicativo Flutter para gestão automotiva moderna, com foco em manutenção preventiva, abastecimentos, consumo e controle de custos do veículo.

## Visão do projeto

O MotorFlow foi pensado para ajudar o usuário a manter o carro em dia, organizar o histórico de manutenção e acompanhar os gastos com combustível de forma inteligente.

## Principais objetivos

- Controle de manutenção preventiva
- Histórico de serviços realizados
- Registro de abastecimentos
- Cálculo de consumo e custos
- Lembretes de revisão e troca de itens importantes

## Estrutura atual

- Flutter
- Material 3
- Arquitetura organizada por camadas
- Navegação inferior
- Fluxo inicial funcional para evolução futura

### Camadas

- `domain`: entidades e contrato do repositório
- `data`: implementação do repositório, local store e snapshot
- `presentation`: shell de navegação e telas por feature
- `core`: tema centralizado, tokens visuais e widgets reutilizáveis

## Módulos atuais

- Dashboard
- Veículos
- Manutenções
- Abastecimentos
- Configurações

## Funcionalidades já implementadas

- Cadastro de veículo
- Listagem e detalhe do veículo
- Cadastro de manutenção
- Cadastro de abastecimento
- Cálculo automático de litros
- Configuração de preço padrão da gasolina
- Persistência local simples em memória
- Persistência local real com Isar (snapshot versionado)
- Tema visual centralizado com identidade premium
- Componentes reutilizáveis `mf_*` para listas, métricas e estados vazios

## Tema e identidade visual

- Material 3 com `ThemeData` centralizado em `core/theme`
- Tokens de cor, tipografia e espaçamento para consistência visual
- Aparência moderna, limpa e automotiva com componentes padronizados

## Próximas evoluções

- Notificações e lembretes
- Relatórios e gráficos
- Central de alertas
- Múltiplos veículos
- Backup e restauração

## Persistência local

- Implementação principal em `data/local/isar_motorflow_local_store.dart`
- Contrato assíncrono em `data/local/motorflow_local_store.dart`
- Snapshot com `schemaVersion = 1` e chave fixa (`primaryKey = 1`)
- Mapeamento desacoplado em `data/local/mapper/snapshot_mapper.dart`
- Fail-safe no carregamento e escrita para manter app funcional mesmo em erro de storage

## Tecnologias

- Flutter
- Dart
- Material 3

## Status

Projeto em desenvolvimento.