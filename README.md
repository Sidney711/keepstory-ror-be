# Deploy Instrukce

## 1. Úprava konfigurace databáze

Před nasazením je potřeba upravit soubor `config/database.yml`, aby obsahoval správné přihlašovací údaje k databázi.

1. Otevřete soubor `config/database.yml`.
2. Najděte část s konfigurací pro produkční prostředí (`production`).
3. Změňte hodnotu `username` z `postgres` na `keepstory`:

   ```yaml
   production:
     adapter: postgresql
     encoding: unicode
     database: your_database_name
     username: keepstory
     password: your_password
     host: your_database_host

2. Změna FE URL v Rails Credentials

Aplikace využívá Rails Credentials (šifrované credentials), které se neupravují přímo v souboru. Postupujte podle následujících kroků:

    Přihlášení do kontejneru:

        Zjistěte název nebo ID kontejneru:

docker ps

Spusťte interaktivní shell:

    docker exec -it <jméno_nebo_ID_kontejneru> /bin/bash

Nastavení editoru:

    Nastavte proměnnou prostředí pro editor (např. nano):

    export EDITOR=nano

Úprava credentials pomocí Rails:

    Spusťte příkaz pro úpravu credentials:

    rails credentials:edit

    Otevře se dočasný soubor s dešifrovanými credentials. Najděte proměnnou (např. FE_URL) a změňte její hodnotu na produkční URL.

    Uložte změny a ukončete editor (v nano: Ctrl+O, potvrďte Enter, a pak Ctrl+X).

Ukončení shellu:

    Po uložení se změny automaticky zašifrují a uloží do souboru config/credentials.yml.enc.

    Ukončete shell:

        exit

3. Úprava Dockerfile pro produkční prostředí

   Zachování lokální konfigurace:

        Přejmenujte stávající soubor Dockerfile na Dockerfile.local, aby se zachovala lokální verze:

   mv Dockerfile Dockerfile.local

Aktivace produkční konfigurace:

    Přejmenujte soubor Dockerfile.production na Dockerfile (odeberte příponu .production):

        mv Dockerfile.production Dockerfile

4. Úprava docker-compose souboru

   Přejmenujte soubor docker-compose.yml na docker-compose.yml.local:

   mv docker-compose.yml docker-compose.yml.local

5. Spuštění deploy skriptu

   Na konci spusťte deploy pomocí příkazu:

   kamal deploy