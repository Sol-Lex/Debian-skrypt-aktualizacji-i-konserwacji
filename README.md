# Debian-skrypt-aktualizacji-i-konserwacji
Założeniem było utrzymanie systemu w "dobrej kondycji"
Jednym poleceniem (uruchomienie skryptu) powinno się wykonać:
Sprawdza aktualizacje systemu i flatpak-ów.
Pobiera i instaluje (aktualizuje).
Usuwa niepotrzebne pliki.
Wyświetla na ekranie postęp (tryb gadatliwy).
Zapisuje do plików log, co zrobił.
Usuwa pliki log (500 MB i starszych niż 3 tygodnie).
Do poprawnego działania skryptu potrzebne jest zainstalowanie nakładki na apt nala komędą 

sudo apt install nala

