# High-Fashion Tracking Smart Contract


## Premesse:

Per attivazione e disattivazione del contratto s’intende il controllo dello stato dello stesso, tramite una variable booleana oppure enum, manipolabile solamente tramite funzioni invocabili dall’owner. Nel caso in cui la variabile segnali il contratto come chiuso, qualsiasi altra funzione deve rifiutare l’esecuzione della transazione invocata. Eccezion fatta per la funzione dedita alla riattivazione del contratto, sempre invocabile soltanto dall’owner.

Adoperare in ciascuna traccia i pattern CRUD e Check Effects Interactions, disponendo delle
opportune strutture dati e degli eventi necessari.


## Traccia 1

Scrivere uno smart contract che gestisca il collegamento tra un prodotto di alta moda finito ed un dispositivo di tracciamento.

**Il dispositivo di tracciamento deve essere descritto in merito a:**

	- Identificativo univoco,
	- Chiave pubblica,
	- Data di registrazione a sistema.
**Il prodotto finito, invece, deve esser descritto in termini di:**

	- Nome,
	- Identificativo numerico,
	- Dati fisici, taglia, colore,
	- Tipologia di vestiario (vestito, giacca ecc),
	- Tipologia di tessuto,


Solo un utente con il ruolo di produttore potrà invocare la funzionalità principale di questo Smart
Contract.

Disporre anche di funzioni apposite per la creazione di prodotti e dispositivi di tracciamento, come anche per la lettura di informazioni su di essi, e la loro quantità.

Prevedere funzionalità per l’attivazione e disattivazione del contratto, da parte dello stesso utente responsabile per la sua istanziazione su rete blockchain.

Non deve esser possibile registrare uno stesso prodotto più volte. Non deve esser possibile registrare un dispositivo a due prodotti diversi.