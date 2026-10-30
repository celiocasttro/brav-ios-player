# BRAV Player — iOS

Aplicativo nativo para iPhone/iPad em SwiftUI. Este repositório contém a primeira base funcional do player; não é uma conversão direta do APK Android.

## O que já está implementado

- Interface inicial escura com identidade BRAV.
- Importação de playlists M3U/M3U8 por endereço HTTP/HTTPS.
- Importação de arquivo de playlist pelo app Arquivos do iPhone.
- Leitura de nome, categoria (`group-title`) e logotipo (`tvg-logo`) dos itens M3U.
- Filtro por categoria.
- Reprodução inicial com AVPlayer / VideoPlayer.
- Item de demonstração para validar a tela e o player.
- Teste unitário inicial para o parser M3U.
- Workflow de GitHub Actions para tentar compilar o projeto em macOS.

## Estrutura

```
brav-ios-player/
├── App/
│   ├── Main/
│   ├── Player/
│   ├── Catalog/
│   └── Settings/
├── Resources/
│   ├── Images/
│   ├── Logos/
│   ├── Catalog/
│   └── Playlists/
├── PlayerEngine/
├── Configuration/
├── Tests/
├── project.yml
└── README.md
```

## Gerar o projeto Xcode

Requisitos: macOS, Xcode e XcodeGen.

```bash
brew install xcodegen
xcodegen generate
open BRAVPlayer.xcodeproj
```

Para compilar no simulador:

```bash
xcodebuild -project BRAVPlayer.xcodeproj -scheme BRAVPlayer -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

A geração de IPA para instalação em iPhone exige macOS/Xcode e assinatura válida da Apple (certificado e provisioning profile apropriados).

## Próximas etapas

1. Validar o build no Xcode e corrigir eventuais diferenças de SDK.
2. Melhorar o parser para formatos M3U usados nas listas reais.
3. Implementar persistência local das playlists e favoritos.
4. Melhorar controles do player, tratamento de erros e compatibilidade de streams.
5. Integrar catálogo próprio e metadados/capas com direitos de uso.

## Observações

O AVPlayer reproduz formatos suportados pelo iOS, incluindo HLS quando a origem está corretamente configurada. Nem todo link TS, contêiner ou protocolo usado por players Android será compatível automaticamente. Conteúdos remotos dependem de internet e da disponibilidade dos servidores. Use somente listas e transmissões que você tenha autorização para acessar.
