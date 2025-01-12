# Debian-skrypt-aktualizacji-i-konserwacji
Założeniem było utrzymanie systemu w "dobrej kondycji"
Jednym poleceniem (uruchomienie skryptu) powinno się wykonać:
Sprawdza aktualizacje systemu i flatpak-ów.
Pobiera i instaluje (aktualizuje).
Usuwa niepotrzebne pliki.
Wyświetla na ekranie postęp (tryb gadatliwy).
Zapisuje do plików log, co zrobił.
Usuwa pliki log (500 MB i starszych niż 3 tygodnie).
W przypadku gdy aktualizacja spowoduje błędy w systemie, jest możliwość wycofania aktualizacji.
Do poprawnego działania skryptu potrzebne jest zainstalowanie nakładki na apt "nala" komędą 

sudo apt install nala

Skrypt umożliwia wybranie opcji aktualizacji
Użycie: ./aktualizacja.sh [opcje]
Opcje:
  --update-system       Aktualizacja systemu i pakietów
  --maintain-logs       Konserwacja dziennika systemowego
  --maintain-flatpak    Konserwacja aplikacji Flatpak
  --clean-cache         Czyszczenie pamięci podręcznej
  --undo                Wycofanie ostatniej aktualizacji
  --all                 Wykonanie wszystkich czynności
  --help                Wyświetlenie tej pomocy

uruchamiamy komędą
 sudo ./aktualizacja.sh --
