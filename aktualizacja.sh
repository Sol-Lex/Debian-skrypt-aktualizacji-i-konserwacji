#!/bin/bash

LOG_FILE="/var/log/konserwacja.log"
ERROR_LOG_FILE="/var/log/konserwacja_bledy.log"

# Funkcja logowania z czasem
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$ERROR_LOG_FILE"
}

# Funkcja sprawdzania i instalacji brakujących pakietów
check_and_install() {
    local package=$1
    if ! dpkg -l | grep -q "$package"; then
        read -p "$package nie jest zainstalowany. Czy chcesz go zainstalować? (T/N): " choice
        case "$choice" in
            [Tt]*)
                log "Instalowanie $package..."
                if apt-get install -y "$package" 2>&1 | tee -a "$LOG_FILE"; then
                    log "$package został pomyślnie zainstalowany."
                else
                    log_error "Błąd podczas instalacji $package."
                fi
                ;;
            *)
                log "$package nie zostanie zainstalowany."
                ;;
        esac
    fi
}

# Sprawdzenie wymaganych pakietów
check_and_install "flatpak"
check_and_install "timeshift"
check_and_install "synaptic"

# Funkcja sprawdzania dostępnego miejsca na dysku
check_disk_space() {
    local MIN_SPACE=1048576  # 1 GB w KB
    local AVAILABLE_SPACE=$(df / | tail -1 | awk '{print $4}')
    if [[ $AVAILABLE_SPACE -lt $MIN_SPACE ]]; then
        log_error "Za mało miejsca na dysku! Dostępne: $((AVAILABLE_SPACE / 1024)) MB, wymagane: 1024 MB."
        exit 1
    fi
}

# Funkcja tworzenia kopii zapasowej systemu za pomocą Timeshift
backup_system() {
    log "Tworzenie kopii zapasowej systemu za pomocą Timeshift..."
    if timeshift --create --comments "Automatyczna kopia zapasowa przed konserwacją" --tags D &> "$LOG_FILE"; then
        log "Kopia zapasowa zakończona sukcesem."
    else
        log_error "Błąd podczas tworzenia kopii zapasowej."
        exit 1
    fi
}

# Funkcja aktualizacji systemu
update_system() {
    check_disk_space
    log "Aktualizacja list pakietów..."
    if apt-get update -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie zaktualizowano listę pakietów."
    else
        log_error "Błąd podczas aktualizacji listy pakietów."
        return 1
    fi

    log "Aktualizacja systemu..."
    if apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie zaktualizowano system."
    else
        log_error "Błąd podczas aktualizacji systemu."
        return 1
    fi

    log "Usuwanie niepotrzebnych pakietów..."
    if apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie usunięto niepotrzebne pakiety."
    else
        log_error "Błąd podczas usuwania niepotrzebnych pakietów."
        return 1
    fi

    log "Czyszczenie pamięci podręcznej pakietów..."
    if apt-get clean 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie wyczyszczono pamięć podręczną pakietów."
    else
        log_error "Błąd podczas czyszczenia pamięci podręcznej pakietów."
        return 1
    fi
}

# Funkcja konserwacji dziennika systemowego
maintain_logs() {
    log "Oczyszczanie dziennika systemowego..."
    if journalctl --vacuum-size=500M 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie ograniczono rozmiar dziennika systemowego."
    else
        log_error "Błąd podczas ograniczania rozmiaru dziennika systemowego."
        return 1
    fi

    if journalctl --vacuum-time=3weeks 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie usunięto stare wpisy dziennika systemowego."
    else
        log_error "Błąd podczas usuwania starych wpisów dziennika systemowego."
        return 1
    fi
}

# Funkcja konserwacji aplikacji Flatpak
maintain_flatpak() {
    log "Aktualizacja aplikacji Flatpak..."
    if flatpak update -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie zaktualizowano aplikacje Flatpak."
    else
        log_error "Błąd podczas aktualizacji aplikacji Flatpak."
        return 1
    fi

    log "Usuwanie nieużywanych aplikacji Flatpak..."
    if flatpak uninstall --unused -y 2>&1 | tee -a "$LOG_FILE"; then
        log "Pomyślnie usunięto nieużywane aplikacje Flatpak."
    else
        log_error "Błąd podczas usuwania nieużywanych aplikacji Flatpak."
        return 1
    fi
}

# Wyświetlanie pomocy
show_help() {
    echo "Użycie: $0 [opcje]"
    echo "Opcje:"
    echo "  --backup-system       Tworzenie kopii zapasowej systemu (Timeshift)"
    echo "  --update-system       Aktualizacja systemu i pakietów"
    echo "  --maintain-logs       Konserwacja dziennika systemowego"
    echo "  --maintain-flatpak    Konserwacja aplikacji Flatpak"
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
        --backup-system)
            backup_system
            ;;
        --update-system)
            update_system
            ;;
        --maintain-logs)
            maintain_logs
            ;;
        --maintain-flatpak)
            maintain_flatpak
            ;;
        --all)
            backup_system
            update_system
            maintain_logs
            maintain_flatpak
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Nieznana opcja: $arg"
            echo "Nieznana opcja: $arg"
            show_help
            exit 1
            ;;
    esac
done

log "Konserwacja systemu zakończona pomyślnie."
exit 0

