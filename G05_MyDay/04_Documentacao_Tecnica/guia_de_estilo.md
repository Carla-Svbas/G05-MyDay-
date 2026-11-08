# Guia de estilo

As cores, a tipografia e as medidas foram tiradas do ecrã 12 do Figma (guia de estilo). As cores estão definidas na classe Cores, em lib/widgets/cores.dart.

Ficheiro do Figma: https://www.figma.com/design/Z10SqibLprkXmmXoTZuEwg/G05_MyDay_D01?node-id=5-2

## Cores

• Primária: #3D5AFE (Cores.primaria)

• Texto: #161A24 (Cores.tinta)

• Texto secundário: #5B6372 (Cores.texto2)

• Fundo: #F4F5F7 (Cores.fundo)

• Cartões e superfícies: #FFFFFF (Cores.branco)

• Linhas e separadores: #E3E6EC (Cores.linha)

• Dias seguidos: #FFB020 (Cores.laranja)

• Erros e ações de apagar: #C62828 (Cores.perigo)

## Tipografia

A fonte é a Plus Jakarta Sans, com quatro estilos:

• Título: tamanho 28, peso 800

• Subtítulo: tamanho 17, peso 700

• Texto corrido: tamanho 15, peso 400, altura de linha 1,5

• Legenda: tamanho 12, peso 600

O ficheiro da fonte está em assets/fonts e é declarado no pubspec.yaml. A licença (OFL) está na pasta 07_Autorizacoes.

## Medidas

Os espaçamentos partem de uma base de 4 px e usam os valores 8, 12, 16, 20 e 24. A margem lateral dos ecrãs é de 20 px e todos os elementos onde se toca têm pelo menos 44 px.

Os cantos arredondados variam com o elemento:

• Etiquetas: 6

• Botões e campos: 12

• Cartões: 16

• Folhas que abrem de baixo: 24