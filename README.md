# Debian-skrypt-aktualizacji-i-konserwacji
Założeniem było utrzymanie systemu w "dobrej kondycji"
Jednym poleceniem (uruchomienie skryptu) powinno się wykonać:
Sprawdza aktualizacje systemu i flatpak-ów.
Pobiera i instaluje (aktualizuje).
Usuwa niepotrzebne pliki.
Wyświetla na ekranie postęp (tryb gadatliwy).
Zapisuje do plików log, co zrobił.
Usuwa pliki log (większe niż 500 MB i starszych niż 3 tygodnie).
Skrypt przed aktualizacją tworzy kopię Timeshift -em.
Poza tym sprawdza ilość miejsca na dysku, sprawdza, czy jest zainstalowany Timeshift, Flatpak, Synaptic, Jeżeli nie to, pyta, czy chcesz go zainstalować.
Zapraszam wszystkich do poprawiania i dodawania innych pożytecznych funkcji, w celu stworzenia uniwersalnego kompleksowego skryptu.
Skrypt kopiujemy do katalogu głównego urzytkownika.
Nadajemy uprawniena do uruchomienia
chmod +x aktualizacja.sh 
uruchamiamy poleceniem
sudo ./aktualizacja.sh 
