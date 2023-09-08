//SPDX-License-Identifier: Unlicense

// contracts/BuyMeABeer.sol
pragma solidity ^0.8.4;


contract BuyMeABeer  {

    // Evento emesso quando un messaggio viene creato
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // Struttura per il messaggio
    struct Memo {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    
    // Indirizzo di chi pubblica il contratto ( proprietario )
    // Un indirizzo che può ricevere Ether perchè marcato come "payable"    
    address payable owner;

    // Elenco di tutti i messaggi ricevuti dagli acquisti di birra
    Memo[] memos;

    constructor() {
        
        // Memorizza l'indirizzo del distributore come indirizzo pagabile.
        // Quando preleviamo fondi, li ritireremo qui.
        // le conversioni da un indirizzo ad un indirizzo payable devono essere esplicite tramite payable(<address>). 
        owner = payable(msg.sender);
    }

    /**
     * @dev recupera tutti i messaggi memorizzati
     */
    // function (<parameter types>) {internal|external} [pure|view|payable] [returns (<return types>)]
    // le funzioni internal possono essere utilizzate nelle funzioni della libreria interna (default)
    // le funzioni view sono funzioni di sola lettura e non modificano lo stato della catena di blocchi
    // le funzioni pure sono più restrittive delle funzioni di visualizzazione e non modificano lo stato E non leggono lo stato della blockchain
    // le funzionu payable possono ricevere Ether e rispondere a un deposito di Ether
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /**
     * @dev compra una birra per il proprietario (invia ETH e lascia un messaggio)
     * @param _name nome dell'acquirente della birra
     * @param _message un messaggio da parte dell'acquirente
     *
     * La parola chiave "memory" è usata per archiviare temporaneamente i dati durante l'esecuzione di uno smart contract.
     * A basso costo. Tuttavia, è anche volatile e ha una capacità limitata.
     */
    function buyBeer(string memory _name, string memory _message) public payable {
        // Deve accettare più di 0 ETH per una birra.
        require(msg.value > 0, "can't buy beer for free!");

        // Aggiungi un messaggio alla storage
        memos.push(Memo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emette un evento NewMemo con i dettagli sul messaggio.
        emit NewMemo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        );
    }

    /**
     * @dev inviare al proprietario l'intero saldo memorizzato nel presente contratto
     */
    function withdrawTips() public {
        // address(this).balance recupera gli ether memorizzati nel contratto
        // owner.send(...) è la sintassi per creare una transazione di invio con ether
        // the require(...) La dichiarazione che racchiude tutto è lì per garantire che, in caso di problemi, 
        // la transazione venga annullata e nulla venga perso
        require(owner.send(address(this).balance));
    }
}