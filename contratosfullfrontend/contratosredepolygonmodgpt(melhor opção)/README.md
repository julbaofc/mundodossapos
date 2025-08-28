# Sapo Pack (deploy barato)
Este pacote entrega contratos otimizados p/ deploy econômico, mantendo segurança básica.

## Contratos
- `SapoCore.sol` — base com owner/pause/nonReentrant/timelock/SafeERC20.
- `SuperRegistry.sol` — versão compactada (packing agressivo).
- `SapoToken.sol` — ERC20 simples com cap, construtor mínimo.
- `SapoGameHub.sol` — construtor mínimo; structs reordenadas.
- `SapoFinance.sol` — construtor mínimo; structs reordenadas; SafeERC20 via Core.
- `SapoMetaHub.sol` — orquestrador simples.
- `SapoEquip1155.sol` — links via setter (sem custos no constructor).
- `FrogNFT.sol` — stats reordenadas p/ packing; links via setter.

## Ordem de Deploy sugerida
1. `SapoToken` (owner, name, symbol, cap)
2. `SuperRegistry` (owner)
3. `SapoMetaHub` (owner)
4. `SapoFinance` (owner)
5. `SapoGameHub` (owner)
6. `SapoEquip1155` (owner)
7. `FrogNFT` (owner)

## Pós-deploy (setters baratos)
- `SapoGameHub.setLinks(finance, token, frog, registry)`
- `SapoFinance.setLinks(registry, bankToken)`
- `SapoMetaHub.setRegistry(registry)`
- `SapoEquip1155.setLinks(frogs, registry)`
- `FrogNFT.setLinks(token, gameHub, registry)`

## Notas de economia
- Construtores mínimos reduzem **initcode** e custo de deploy.
- Structs reordenadas reduzem slots e SSTORE/SLOAD.
- SafeERC20 padronizado evita duplicação.
- `SuperRegistry` usa packing agressivo para cortar slots.

> Ajuste os contratos para a lógica completa do seu jogo conforme necessário. Este pack é um esqueleto otimizado e seguro para caber em orçamento apertado de deploy.
