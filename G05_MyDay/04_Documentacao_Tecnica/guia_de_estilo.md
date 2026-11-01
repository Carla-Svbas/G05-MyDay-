# Guia de estilo

As cores, a tipografia e as medidas foram tiradas do ecrã 12 do Figma e estão definidas no ficheiro lib/theme/app_theme.dart.

## Cores

• Primária: #3D5AFE (AppColors.primary)

• Texto: #161A24 (AppColors.ink)

• Texto secundário: #5B6372 (AppColors.text2)

• Fundo: #F4F5F7 (AppColors.background)

• Cartões e superfícies: #FFFFFF (AppColors.surface)

• Linhas e separadores: #E3E6EC (AppColors.line)

• Dias seguidos: #FFB020 (AppColors.streak)

• Erros e ações de apagar: #C62828 (AppColors.danger)

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