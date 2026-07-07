# WrapKit Review Docs

Документы для архитектурного и code review изменений в WrapKit.

## Что здесь

- [wrapkit-architecture-reference.md](./wrapkit-architecture-reference.md) - reference по слоям, архитектурным правилам и текущим рискам WrapKit.
- [wrapkit-review-agent.md](./wrapkit-review-agent.md) - prompt общего ревьюера WrapKit.

## Как использовать

1. Перед review прочитать `AGENTS.md`.
2. Сверить изменение с `wrapkit-architecture-reference.md`.
3. Запустить review-agent из `wrapkit-review-agent.md` на текущий diff или на список файлов.
4. Если изменение UI-компонента влияет на downstream, сначала проверить snapshot в WrapKit, потом экран в потребителе.
