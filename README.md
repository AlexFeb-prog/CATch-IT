# CATch It! 🐾 - Videogioco per Gatti (iPad & Mac)

Videogioco nativo sviluppato in **Swift / SwiftUI / Sprite & Audio Engine** specificamente ottimizzato per il comportamento visivo, uditivo e predatorio dei gatti.

---

## 🎯 Ricerca Etologica e Psicologia Felina Applicata

Durante la progettazione del gameplay ci siamo basati sui pilastri scientifici della percezione e dell'etologia felina:

1. **Ciclo Predatorio Completo (*Orient $\rightarrow$ Stalk $\rightarrow$ Chase $\rightarrow$ Pounce*):**
   - I gatti hanno una visione orientata ai bastoncelli (sensibilità al movimento ad alta frequenza) e un'acuità dicromatica centrata su blu, ciano e giallo/marrone caldo.
   - Il gameplay implementa micro-pause improvvise ("freezing") seguite da scatti rapidi a zig-zag: il movimento lineare non attiva l'istinto, mentre le esitazioni della preda scatenano l'attacco.

2. **Frequenze Sonore Attraenti:**
   - I gatti captano frequenze ultrasoniche e alte (fino a 64 kHz). I campioni sintetizzati per il gioco emettono frequenze tra 2.800 Hz e 5.000 Hz (squittii acuti del topo, battito d'ali e cinguettii dell'uccellino, fruscio del gomitolo).

3. **Feedback Immediato alla Zampata (*Acoustic & Visual Confirmation*):**
   - Quando la zampa tocca il display: onda d'urto ad anello d'acqua, suono "pop" istantaneo e burst di particelle ad alto contrasto.

4. **Protezione Antiuscita (*Cat-Proof Parent Lock*):**
   - I gatti toccano ovunque sullo schermo. Per evitare che chiudano l'app per errore, il pulsante di uscita richiede una pressione prolungata (Long Press) di oltre 1 secondo.

---

## 📱 Struttura UI / UX Fedele ai Mockup Forniti

- **Homepage:** Gatto sbirciante animato in cima, grande pulsante sagomato *"Play"* pulsante con gradienti morbidi, logo stilizzato *"CATch It!"* e dock inferiore circolare.
- **Typegame (Selezione Tipo di Gioco):** 4 carte interattive:
  - 🐦 **Bird** (Uccellino con cinguettii rapidi)
  - 🐭 **Mouse** (Topolino con scatti e squittii)
  - 🧶 **Thread** (Gomitolo con scia e animazione di trascinamento)
  - 🎲 **Mix** (Modalità dinamica mista)
- **Impostazioni (Audio & Gioco):**
  - **Audio:** Regolazione del volume per gli effetti sonori ad alta frequenza.
  - **Gioco:** Cursore velocità delle prede (0.5x – 2.0x), durata sessione (1m, 3m, 5m, 10m), numero di prede simultanee sullo schermo (da 1 a 5).
- **Barra di Navigazione:** 3 pulsanti circolari con ombreggiatura e icone: Gomitolo (Prede), Zampa (Home), Ingranaggio (Opzioni).

---

## 🚀 Come Giocare e Provare Subito su Mac

Il file eseguibile è pronto ed è stato compilato per il tuo Mac:

1. Apri il file bundle:
   ```bash
   open /Users/afppar074/.gemini/antigravity/scratch/CatChIt/CatChIt.app
   ```
2. Oppure fai doppio clic sull'archivio:
   `/Users/afppar074/.gemini/antigravity/scratch/CatChIt/CatChIt_macOS.zip`

---

## 📲 Pubblicazione su App Store (iPad)

La cartella del progetto contiene il file di progetto Xcode nativo:
`/Users/afppar074/.gemini/antigravity/scratch/CatChIt/CatChIt.xcodeproj`

### Passaggi per la pubblicazione:
1. Fai doppio clic su `CatChIt.xcodeproj` per aprirlo in Xcode.
2. In **Signing & Capabilities**, seleziona il tuo **Apple Developer Team** e verifica il bundle identifier (`com.catchit.catgame`).
3. Seleziona come target **Any iOS Device (arm64)**.
4. Vai su **Product > Archive**.
5. Al termine dell'archiviazione, clicca su **Distribute App** e seleziona **App Store Connect**.
