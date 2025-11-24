-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 31.11.39.242
-- Creato il: Set 18, 2025 alle 17:46
-- Versione del server: 8.0.43-34
-- Versione PHP: 8.0.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Sql1073852_1`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `classi`
--

CREATE TABLE `classi` (
  `id_classe` int NOT NULL,
  `id_settore` int NOT NULL,
  `nome_classe` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descrizione` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ordine_visualizzazione` int DEFAULT '0',
  `stato_classe` enum('attiva','sospesa') COLLATE utf8mb4_unicode_ci DEFAULT 'attiva',
  `data_creazione` varchar(19) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dump dei dati per la tabella `classi`
--

INSERT INTO `classi` (`id_classe`, `id_settore`, `nome_classe`, `descrizione`, `ordine_visualizzazione`, `stato_classe`, `data_creazione`) VALUES
(1, 1, 'Rosa', NULL, 1, 'attiva', '14/09/2025 19:20:18'),
(2, 1, 'Mimosa', NULL, 2, 'attiva', '14/09/2025 19:20:18'),
(3, 2, 'Viola 1', NULL, 1, 'attiva', '14/09/2025 19:20:18'),
(4, 2, 'Viola 2', NULL, 2, 'attiva', '14/09/2025 19:20:18'),
(5, 2, 'Lavanda 1', NULL, 3, 'attiva', '14/09/2025 19:20:18'),
(6, 2, 'Lavanda 2', NULL, 4, 'attiva', '14/09/2025 19:20:18'),
(7, 2, 'Tulipano 1', NULL, 5, 'attiva', '14/09/2025 19:20:18'),
(8, 2, 'Tulipano 2', NULL, 6, 'attiva', '14/09/2025 19:20:18'),
(9, 2, 'Geraneo 1', NULL, 7, 'attiva', '14/09/2025 19:20:18'),
(10, 2, 'Geraneo 2', NULL, 8, 'attiva', '14/09/2025 19:20:18'),
(11, 3, 'Papavero 1', NULL, 1, 'attiva', '14/09/2025 19:20:18'),
(12, 3, 'Papavero 2', NULL, 2, 'attiva', '14/09/2025 19:20:18'),
(13, 3, 'Margherita 1', NULL, 3, 'attiva', '14/09/2025 19:20:18'),
(14, 3, 'Margherita 2', NULL, 4, 'attiva', '14/09/2025 19:20:18'),
(15, 3, 'Primula 1', NULL, 5, 'attiva', '14/09/2025 19:20:18'),
(16, 3, 'Primula 2', NULL, 6, 'attiva', '14/09/2025 19:20:18'),
(17, 3, 'Girasole 1', NULL, 7, 'attiva', '14/09/2025 19:20:18'),
(18, 3, 'Girasole 2', NULL, 8, 'attiva', '14/09/2025 19:20:18'),
(19, 4, 'Diurno 1', NULL, 1, 'attiva', '14/09/2025 19:20:18'),
(20, 4, 'Diurno 2', NULL, 2, 'attiva', '14/09/2025 19:20:18'),
(21, 4, 'Diurno 3', NULL, 3, 'attiva', '14/09/2025 19:20:18'),
(22, 5, 'AD1 Celeste 1', NULL, 1, 'attiva', '14/09/2025 19:20:19'),
(23, 5, 'AD2 Celeste 2', NULL, 2, 'attiva', '14/09/2025 19:20:19'),
(24, 5, 'AD3 Celeste 2', NULL, 3, 'attiva', '14/09/2025 19:20:19'),
(25, 5, 'AD4 Viola 2', NULL, 4, 'attiva', '14/09/2025 19:20:19'),
(26, 5, 'AD5 Viola 1', NULL, 5, 'attiva', '14/09/2025 19:20:19'),
(27, 5, 'AD6 Viola 2', NULL, 6, 'attiva', '14/09/2025 19:20:19'),
(28, 5, 'AD7 Viola 1', NULL, 7, 'attiva', '14/09/2025 19:20:19'),
(29, 5, 'AD8 Celeste 2', NULL, 8, 'attiva', '14/09/2025 19:20:19'),
(30, 5, 'AD9 Celeste 1', NULL, 9, 'attiva', '14/09/2025 19:20:19'),
(31, 5, 'AD10 Viola 1', NULL, 10, 'attiva', '14/09/2025 19:20:19'),
(32, 5, 'AD11 Celeste 1', NULL, 11, 'attiva', '14/09/2025 19:20:19'),
(33, 5, 'AD12 Viola 3', NULL, 12, 'attiva', '14/09/2025 19:20:19');

-- --------------------------------------------------------

--
-- Struttura della tabella `educatori`
--

CREATE TABLE `educatori` (
  `id_educatore` int NOT NULL,
  `id_registrazione` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cognome` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_sede` int DEFAULT '1',
  `email_contatto` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note_professionali` text COLLATE utf8mb4_unicode_ci,
  `stato_educatore` enum('attivo','sospeso','in_formazione','eliminato') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo',
  `data_creazione` varchar(19) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_settore` int DEFAULT NULL,
  `id_classe` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dump dei dati per la tabella `educatori`
--

INSERT INTO `educatori` (`id_educatore`, `id_registrazione`, `nome`, `cognome`, `id_sede`, `email_contatto`, `telefono`, `note_professionali`, `stato_educatore`, `data_creazione`, `id_settore`, `id_classe`) VALUES
(1, 4, 'fabio', 'marchetti', 1, 'marchettisoft@gmail.com', '3398063701', '', 'attivo', '18/09/2025 09:37:41', 1, 1),
(2, 13, 'nomeEdu2', 'cognomeEdu2', 1, 'marchettisoft@gmail.com', '3398063701', 'inserimento edu2', 'attivo', '18/09/2025 09:39:17', 5, 23);

-- --------------------------------------------------------

--
-- Struttura della tabella `educatori_pazienti`
--

CREATE TABLE `educatori_pazienti` (
  `id_associazione` int NOT NULL,
  `id_educatore` int NOT NULL,
  `id_paziente` int NOT NULL,
  `data_associazione` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_attiva` tinyint(1) DEFAULT '1',
  `note` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `pazienti`
--

CREATE TABLE `pazienti` (
  `id_paziente` int NOT NULL,
  `id_registrazione` int NOT NULL,
  `id_sede` int DEFAULT '1',
  `id_settore` int DEFAULT NULL,
  `id_classe` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `registrazioni`
--

CREATE TABLE `registrazioni` (
  `id_registrazione` int NOT NULL,
  `nome_registrazione` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cognome_registrazione` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username_registrazione` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_registrazione` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruolo_registrazione` enum('amministratore','educatore','paziente','sviluppatore') COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_sede` int DEFAULT '1',
  `data_registrazione` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ultimo_accesso` varchar(19) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stato_account` enum('attivo','sospeso','eliminato') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dump dei dati per la tabella `registrazioni`
--

INSERT INTO `registrazioni` (`id_registrazione`, `nome_registrazione`, `cognome_registrazione`, `username_registrazione`, `password_registrazione`, `ruolo_registrazione`, `id_sede`, `data_registrazione`, `ultimo_accesso`, `stato_account`) VALUES
(1, 'Fabio', 'Marchetti', 'marchettisoft@gmail.com', 'Filohori11!', 'sviluppatore', 1, '13/09/2025', '18/09/2025 19:29:24', 'attivo'),
(4, 'nomeEdu1', 'cognomeEdu1', 'edu1@gmail.com', 'pwdedu1', 'educatore', 5, '14/09/2025', NULL, 'attivo'),
(5, 'nomeAmi1', 'cognomeAmi1', 'ami1@gmail.com', 'undefined', 'amministratore', 5, '17/09/2025', '17/09/2025 13:16:49', 'attivo'),
(6, 'nomeAmi2', 'cognomeAmi2', 'am2@gmail.com', 'pwdami2', 'amministratore', 1, '17/09/2025', NULL, 'attivo'),
(7, 'nomeAmi3', 'cognomeAmi3', 'ami3@gmail.com', 'pwdami3', 'amministratore', 5, '17/09/2025', NULL, 'attivo'),
(13, 'nomeEdu2', 'cognomeEdu2', 'edu2@gmail.com', 'pwdedu2', 'educatore', 1, '18/09/2025', NULL, 'attivo');

-- --------------------------------------------------------

--
-- Struttura della tabella `sedi`
--

CREATE TABLE `sedi` (
  `id_sede` int NOT NULL,
  `nome_sede` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `indirizzo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `citta` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provincia` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cap` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_creazione` varchar(19) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stato_sede` enum('attiva','sospesa','chiusa') COLLATE utf8mb4_unicode_ci DEFAULT 'attiva'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dump dei dati per la tabella `sedi`
--

INSERT INTO `sedi` (`id_sede`, `nome_sede`, `indirizzo`, `citta`, `provincia`, `cap`, `telefono`, `email`, `data_creazione`, `stato_sede`) VALUES
(1, 'Sede Principale', 'via Linguetta, 2', 'Osim', 'AN', '60900', '07172451', 'info@legadelfilodoro.it', '14/09/2025 19:21:00', 'attiva'),
(5, 'Molfetta', 'Strada Provinciale 112', 'Molfetta', 'BA', '70056', '080 3971653', 'segreteria.molfetta@legadelfilodoro.it', '17/09/2025 11:28:13', 'attiva');

-- --------------------------------------------------------

--
-- Struttura della tabella `settori`
--

CREATE TABLE `settori` (
  `id_settore` int NOT NULL,
  `id_sede` int DEFAULT NULL,
  `nome_settore` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descrizione` text COLLATE utf8mb4_unicode_ci,
  `ordine_visualizzazione` int DEFAULT '0',
  `stato_settore` enum('attivo','sospeso') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo',
  `data_creazione` varchar(19) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dump dei dati per la tabella `settori`
--

INSERT INTO `settori` (`id_settore`, `id_sede`, `nome_settore`, `descrizione`, `ordine_visualizzazione`, `stato_settore`, `data_creazione`) VALUES
(1, 1, 'Scolare', 'Settore educativo scolastico', 1, 'attivo', '14/09/2025 19:20:18'),
(2, 1, 'Trattamenti Intensivi', 'Percorsi terapeutici intensivi specializzati', 2, 'attivo', '14/09/2025 19:20:18'),
(3, 1, 'Centro Diagnostico', 'Valutazioni e diagnosi specialistiche', 3, 'attivo', '14/09/2025 19:20:18'),
(4, 1, 'Diurno', 'Servizi diurni di supporto e riabilitazione', 4, 'attivo', '14/09/2025 19:20:18'),
(5, 1, 'Adulti', 'Programmi per utenti adulti', 5, 'attivo', '14/09/2025 19:20:18');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `classi`
--
ALTER TABLE `classi`
  ADD PRIMARY KEY (`id_classe`),
  ADD UNIQUE KEY `unique_classe_settore` (`id_settore`,`nome_classe`),
  ADD KEY `idx_settore` (`id_settore`),
  ADD KEY `idx_nome_classe` (`nome_classe`),
  ADD KEY `idx_stato` (`stato_classe`),
  ADD KEY `idx_ordine` (`ordine_visualizzazione`);

--
-- Indici per le tabelle `educatori`
--
ALTER TABLE `educatori`
  ADD PRIMARY KEY (`id_educatore`),
  ADD UNIQUE KEY `id_registrazione` (`id_registrazione`),
  ADD KEY `idx_registrazione` (`id_registrazione`),
  ADD KEY `idx_sede` (`id_sede`),
  ADD KEY `idx_settore` (`id_settore`),
  ADD KEY `idx_classe` (`id_classe`);

--
-- Indici per le tabelle `educatori_pazienti`
--
ALTER TABLE `educatori_pazienti`
  ADD PRIMARY KEY (`id_associazione`),
  ADD UNIQUE KEY `unique_associazione_attiva` (`id_educatore`,`id_paziente`,`is_attiva`),
  ADD KEY `idx_educatore` (`id_educatore`),
  ADD KEY `idx_paziente` (`id_paziente`),
  ADD KEY `idx_attiva` (`is_attiva`);

--
-- Indici per le tabelle `pazienti`
--
ALTER TABLE `pazienti`
  ADD PRIMARY KEY (`id_paziente`),
  ADD UNIQUE KEY `id_registrazione` (`id_registrazione`),
  ADD KEY `idx_registrazione` (`id_registrazione`),
  ADD KEY `idx_sede` (`id_sede`),
  ADD KEY `idx_settore` (`id_settore`),
  ADD KEY `idx_classe` (`id_classe`);

--
-- Indici per le tabelle `registrazioni`
--
ALTER TABLE `registrazioni`
  ADD PRIMARY KEY (`id_registrazione`),
  ADD UNIQUE KEY `username_registrazione` (`username_registrazione`),
  ADD KEY `idx_username` (`username_registrazione`),
  ADD KEY `idx_ruolo` (`ruolo_registrazione`),
  ADD KEY `idx_stato` (`stato_account`),
  ADD KEY `idx_data_registrazione` (`data_registrazione`),
  ADD KEY `fk_registrazioni_sede` (`id_sede`);

--
-- Indici per le tabelle `sedi`
--
ALTER TABLE `sedi`
  ADD PRIMARY KEY (`id_sede`),
  ADD UNIQUE KEY `nome_sede` (`nome_sede`),
  ADD KEY `idx_nome_sede` (`nome_sede`),
  ADD KEY `idx_citta` (`citta`),
  ADD KEY `idx_provincia` (`provincia`),
  ADD KEY `idx_stato` (`stato_sede`);

--
-- Indici per le tabelle `settori`
--
ALTER TABLE `settori`
  ADD PRIMARY KEY (`id_settore`),
  ADD UNIQUE KEY `nome_settore` (`nome_settore`),
  ADD KEY `idx_nome_settore` (`nome_settore`),
  ADD KEY `idx_stato` (`stato_settore`),
  ADD KEY `idx_ordine` (`ordine_visualizzazione`),
  ADD KEY `idx_settori_sede` (`id_sede`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `classi`
--
ALTER TABLE `classi`
  MODIFY `id_classe` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT per la tabella `educatori`
--
ALTER TABLE `educatori`
  MODIFY `id_educatore` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `educatori_pazienti`
--
ALTER TABLE `educatori_pazienti`
  MODIFY `id_associazione` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `pazienti`
--
ALTER TABLE `pazienti`
  MODIFY `id_paziente` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `registrazioni`
--
ALTER TABLE `registrazioni`
  MODIFY `id_registrazione` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT per la tabella `sedi`
--
ALTER TABLE `sedi`
  MODIFY `id_sede` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `settori`
--
ALTER TABLE `settori`
  MODIFY `id_settore` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `classi`
--
ALTER TABLE `classi`
  ADD CONSTRAINT `classi_ibfk_1` FOREIGN KEY (`id_settore`) REFERENCES `settori` (`id_settore`) ON DELETE CASCADE;

--
-- Limiti per la tabella `educatori`
--
ALTER TABLE `educatori`
  ADD CONSTRAINT `educatori_ibfk_1` FOREIGN KEY (`id_registrazione`) REFERENCES `registrazioni` (`id_registrazione`) ON DELETE CASCADE,
  ADD CONSTRAINT `educatori_ibfk_2` FOREIGN KEY (`id_sede`) REFERENCES `sedi` (`id_sede`) ON DELETE SET NULL,
  ADD CONSTRAINT `educatori_ibfk_3` FOREIGN KEY (`id_settore`) REFERENCES `settori` (`id_settore`) ON DELETE SET NULL,
  ADD CONSTRAINT `educatori_ibfk_4` FOREIGN KEY (`id_classe`) REFERENCES `classi` (`id_classe`) ON DELETE SET NULL;

--
-- Limiti per la tabella `educatori_pazienti`
--
ALTER TABLE `educatori_pazienti`
  ADD CONSTRAINT `educatori_pazienti_ibfk_1` FOREIGN KEY (`id_educatore`) REFERENCES `educatori` (`id_educatore`) ON DELETE CASCADE,
  ADD CONSTRAINT `educatori_pazienti_ibfk_2` FOREIGN KEY (`id_paziente`) REFERENCES `pazienti` (`id_paziente`) ON DELETE CASCADE;

--
-- Limiti per la tabella `pazienti`
--
ALTER TABLE `pazienti`
  ADD CONSTRAINT `pazienti_ibfk_1` FOREIGN KEY (`id_registrazione`) REFERENCES `registrazioni` (`id_registrazione`) ON DELETE CASCADE,
  ADD CONSTRAINT `pazienti_ibfk_2` FOREIGN KEY (`id_sede`) REFERENCES `sedi` (`id_sede`) ON DELETE SET NULL,
  ADD CONSTRAINT `pazienti_ibfk_3` FOREIGN KEY (`id_settore`) REFERENCES `settori` (`id_settore`) ON DELETE SET NULL,
  ADD CONSTRAINT `pazienti_ibfk_4` FOREIGN KEY (`id_classe`) REFERENCES `classi` (`id_classe`) ON DELETE SET NULL;

--
-- Limiti per la tabella `registrazioni`
--
ALTER TABLE `registrazioni`
  ADD CONSTRAINT `fk_registrazioni_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedi` (`id_sede`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limiti per la tabella `settori`
--
ALTER TABLE `settori`
  ADD CONSTRAINT `fk_settori_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedi` (`id_sede`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
