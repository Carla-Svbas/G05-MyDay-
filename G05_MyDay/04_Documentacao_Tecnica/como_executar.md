# Como executar a app

Requisitos: Flutter instalado (testado com Flutter 3.13.9 / Dart 3.1.5).

1. Abrir um terminal na pasta `05_Artefactos/my_day`.
2. Descarregar as dependências do Flutter:
   ```
   flutter pub get
   ```
3. Correr a app (num emulador Android, telemóvel ligado, Chrome ou Windows):
   ```
   flutter run
   ```
4. Correr os testes:
   ```
   flutter test
   ```

Contas de teste: ver `arquitetura_mvc.md`, secção "Contas de teste".

**Nota (Windows):** se a pasta do projeto tiver um caminho muito longo, o Flutter pode falhar a compilar ("Directory listing failed"). Nesse caso, copiem o projeto para uma pasta com caminho curto (por exemplo `C:\projetos\my_day`).
