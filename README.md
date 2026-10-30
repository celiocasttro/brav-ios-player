# BRAV iOS Player

Projeto de aplicativo nativo para iPhone, desenvolvido em Swift e SwiftUI.

## Objetivo

Criar um player iOS com catálogo integrado, categorias, capas, playlists e reprodução de streams compatíveis com iOS. O aplicativo será desenvolvido como projeto próprio; não é uma conversão direta do APK Android.

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
└── README.md
```

## Tecnologias previstas

- Swift
- SwiftUI para a interface
- AVKit / AVPlayer para reprodução de mídia compatível
- XCTest para testes

## Organização inicial

As pastas foram preparadas para receber os arquivos do aplicativo. Os arquivos `.gitkeep` mantêm as pastas vazias no Git até que os componentes reais sejam adicionados.

## Observações

- O catálogo poderá ser empacotado em `Resources/Catalog/` e as playlists autorizadas em `Resources/Playlists/`.
- Streams ao vivo e conteúdos hospedados remotamente ainda dependem de conexão e disponibilidade dos respectivos servidores.
- O projeto ainda não contém um app compilável nem um IPA. A configuração do projeto Xcode e a implementação serão feitas nas próximas etapas.
- A compilação e assinatura do IPA exigem Xcode em um Mac e uma configuração de assinatura Apple adequada.
