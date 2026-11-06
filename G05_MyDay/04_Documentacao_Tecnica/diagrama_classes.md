# Diagrama de classes (conceptual) — MyDay

Esboço das entidades do domínio e das relações entre elas. Os atributos são os mais importantes; a lista completa está no `dicionario_de_dados.md`.

```mermaid
classDiagram
    direction LR

    class Utilizador {
      +int id
      +String email
      +String nome
      +String nomeUtilizador
      +String curso
      +Papel papel
      +bool consentLocalizacao
      +bool consentAudio
      +primeiroNome() String
      +eAmigoDe(Utilizador) bool
    }
    class Papel {
      <<enumeration>>
      estudante
      professor
      administrador
    }
    class Visibilidade {
      <<enumeration>>
      privado
      amigos
      publico
    }
    class Registo {
      +int id
      +String uuidCliente
      +String titulo
      +String texto
      +Visibilidade? visibilidade
      +Localizacao? local
      +DateTime dataRegisto
      +bool oculto
      +visibilidadeEfetiva() Visibilidade
      +temFoto() bool
    }
    class Localizacao {
      +double latitude
      +double longitude
      +double latitudeAprox
      +double longitudeAprox
      +String morada
    }
    class Ficheiro {
      +TipoFicheiro tipo
      +String caminho
      +int tamanhoBytes
      +int? duracaoSeg
    }
    class Projeto {
      +int id
      +String titulo
      +String descricao
      +Visibilidade visibilidade
      +linhaTemporal() List~Registo~
    }
    class Disciplina {
      +String nome
      +String area
    }
    class Tag {
      +String nome
    }
    class Comentario {
      +String texto
      +DateTime criadoEm
    }
    class Favorito
    class Grupo {
      +String nome
      +String descricao
    }
    class Lembrete {
      +String titulo
      +Time hora
      +int diasSemana
      +bool ativo
    }
    class Conquista {
      +String codigo
      +String nome
    }
    class Denuncia {
      +String motivo
      +EstadoDenuncia estado
      +DateTime? tratadaEm
    }
    class Desafio {
      +String titulo
      +Date inicio
      +Date fim
    }
    class Mensagem {
      +String texto
      +DateTime? lidaEm
    }
    class AcaoAdmin {
      +String acao
      +String entidadeTipo
      +int entidadeId
      +JSON detalhes
    }

    Utilizador --> Papel
    Utilizador "1" --> "*" Registo : escreve
    Utilizador "1" --> "*" Projeto : cria
    Utilizador "*" --> "*" Utilizador : segue
    Utilizador "1" --> "*" Mensagem : envia
    Utilizador "1" --> "*" Lembrete : tem
    Utilizador "*" --> "*" Conquista : obtém
    Utilizador "*" --> "*" Tag : acompanha
    Utilizador "*" --> "*" Disciplina : acompanha
    Projeto "0..1" o-- "*" Registo : agrupa
    Projeto --> Visibilidade
    Registo --> Visibilidade
    Registo "1" *-- "0..1" Localizacao
    Registo "1" *-- "*" Ficheiro : anexa
    Registo "*" --> "0..1" Disciplina
    Projeto "*" --> "0..1" Disciplina
    Registo "*" --> "*" Tag
    Comentario "*" --> "0..1" Registo : sobre
    Comentario "*" --> "0..1" Projeto : sobre
    Favorito "*" --> "0..1" Registo
    Favorito "*" --> "0..1" Projeto
    Grupo "*" --> "*" Utilizador : membros
    Grupo "*" --> "*" Registo : partilhados
    Denuncia "*" --> "0..1" Registo : alvo
    Denuncia "*" --> "0..1" Utilizador : tratadaPor
    Desafio "*" --> "1" Utilizador : criadoPor
    AcaoAdmin "*" --> "1" Utilizador : admin
```

## Notas

- **Visibilidade efetiva:** `Registo.visibilidadeEfetiva()` devolve a visibilidade do registo, senão a do projeto, senão `privado`. Na BD isto é a view `v_registo`.
- **Amigos:** `Utilizador.eAmigoDe(outro)` é verdadeiro quando os dois se seguem. Não há uma classe "Amizade".
- **Localização:** é uma parte do registo (composição). Só existe quando há consentimento.
- **Comentário, Favorito e Denúncia:** têm um único alvo (registo ou projeto), garantido pelos triggers da BD.
- **Na app Flutter**, estas entidades correspondem às classes de `lib/models/` (`Utilizador`, `Registo`, `Projeto`, `Comentario`, `Denuncia`, `Conquista`, `GrupoEstudo`, `AcaoAdmin`…). Os controllers de `lib/controllers/` guardam as listas e falam com a API através de `lib/data/myday_api.dart`.
