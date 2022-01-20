# pihole-updatescript

Bash Update-Script for the Pihole Adblocker

## Zweck und Nutzung

Das Programm stopt die Service's die zur ausführung des Pihole Dienstes nötig sind.

- Erfolgen einer Statusüberprüfung der betroffenen Services.
- Prüfen ob ein pihle Update vorliegt.
- Abfrage ob ein update vorgenommen werden soll.
- Services werden gestoppt.
- Ein Betriebssystem apt update und upgrade wird ausfegührt
- Das Update des Pihle wird durchgeführt
- Services werden wieder gestartet.
