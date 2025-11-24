# Veicoli mare

**Categoria:** Categorizzazione
**Tipo:** Esercizio di training cognitivo

## 📦 Struttura Esercizio Autonomo

Questo esercizio è stato **migrato** per essere completamente autonomo:

- ✅ Propri file PHP (config, API)
- ✅ Manifest e Service Worker PWA
- ✅ Database tables dedicate
- ✅ Nessuna dipendenza da file comuni

## 🗄️ Database

### Setup
Esegui in phpMyAdmin:
\`\`\`
api/setup_database.sql
\`\`\`

### Tabelle
- \`categorizzazione_veicoli_mare_config\` - Configurazione esercizio
- \`categorizzazione_veicoli_mare_risultati\` - Risultati e punteggi
- \`categorizzazione_veicoli_mare_log\` - Log azioni utente

## 📱 PWA - Progressive Web App

L'esercizio è installabile come app:

1. Apri da Chrome mobile
2. Menu → "Aggiungi a Home"
3. Usa come app nativa

## 🚀 Deploy

Upload via FTP:
\`\`\`
/training_cognitivo/categorizzazione/veicoli_mare/
\`\`\`

## 📝 Note Migrazione

Esercizio migrato automaticamente da \`migrate_existing_exercises.php\`.
La logica originale è stata preservata, aggiunte solo:
- Autonomia file (api/, config.php)
- Supporto PWA
- Documentazione

---

**Migrato:** {date('Y-m-d H:i:s')}
**Sistema:** AssistiveTech Training Cognitivo