#!/bin/bash

LOG_FILE="/var/log/konserwacja.log"

# Funkcja logowania z czasem
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Funkcja aktualizacji systemu
update_system() {
    log "Aktualizacja list pakietów..."
    if nala update 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie zaktualizowano listę pakietów."
    else
        log "Błąd podczas aktualizacji listy pakietów."
        return 1
    fi

    log "Aktualizacja systemu..."
    if nala upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie zaktualizowano system."
    else
        log "Błąd podczas aktualizacji systemu."
        return 1
    fi

    log "Usuwanie niepotrzebnych pakietów..."
    if nala autoremove -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie usunięto niepotrzebne pakiety."
    else
        log "Błąd podczas usuwania niepotrzebnych pakietów."
        return 1
    fi

    log "Czyszczenie pamięci podręcznej pakietów..."
    if nala clean 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie wyczyszczono pamięć podręczną pakietów."
    else
        log "Błąd podczas czyszczenia pamięci podręcznej pakietów."
        return 1
    fi
}

# Funkcja konserwacji dziennika systemowego
maintain_logs() {
    log "Oczyszczanie dziennika systemowego..."
    if journalctl --vacuum-size=500M 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie ograniczono rozmiar dziennika systemowego."
    else
        log "Błąd podczas ograniczania rozmiaru dziennika systemowego."
        return 1
    fi

    if journalctl --vacuum-time=3weeks 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie usunięto stare wpisy dziennika systemowego."
    else
        log "Błąd podczas usuwania starych wpisów dziennika systemowego."
        return 1
    fi
}

# Funkcja konserwacji aplikacji Flatpak
maintain_flatpak() {
    log "Aktualizacja aplikacji Flatpak..."
    if flatpak update -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie zaktualizowano aplikacje Flatpak."
    else
        log "Błąd podczas aktualizacji aplikacji Flatpak."
        return 1
    fi

    log "Usuwanie nieużywanych aplikacji Flatpak..."
    if flatpak uninstall --unused -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie usunięto nieużywane aplikacje Flatpak."
    else
        log "Błąd podczas usuwania nieużywanych aplikacji Flatpak."
        return 1
    fi
}

# Funkcja czyszczenia pamięci podręcznej
clean_cache() {
    log "Czyszczenie pamięci podręcznej użytkownika..."
    if rm -rf ~/.cache/* 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie wyczyszczono pamięć podręczną użytkownika."
    else
        log "Błąd podczas czyszczenia pamięci podręcznej użytkownika."
        return 1
    fi
}

# Wyświetlanie pomocy
show_help() {
    echo "Użycie: $0 [opcje]"
    echo "Opcje:"
    echo "  --update-system       Aktualizacja systemu i pakietów"
    echo "  --maintain-logs       Konserwacja dziennika systemowego"
    echo "  --maintain-flatpak    Konserwacja aplikacji Flatpak"
    echo "  --clean-cache         Czyszczenie pamięci podręcznej"
    echo "  --all                 Wykonanie wszystkich czynności"
    echo "  --help                Wyświetlenie tej pomocy"
}

# Główna logika skryptu
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

for arg in "$@"; do
    case $arg in
        --update-system)
            update_system
            ;;
        --maintain-logs)
            maintain_logs
            ;;
        --maintain-flatpak)
            maintain_flatpak
            ;;
        --clean-cache)
            clean_cache
            ;;
        --all)
            update_system
            maintain_logs
            maintain_flatpak
            clean_cache
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Nieznana opcja: $arg"
            show_help
            exit 1
            ;;
    esac
done

log "Konserwacja systemu zakończona pomyślnie."
exit 0

