//SPDX-License-Identifier: Unlicense

// contracts/BuyMeACoffee.sol
pragma solidity ^0.8.4;

// Switch this to your own contract address once deployed, for bookkeeping!
// Example Contract Address on Goerli: 0xDBa03676a2fBb6711CB652beF5B7416A53c1421D

contract BuyMeABeer  {
    // Event to emit when a Memo is created.
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // Memo struct.
    struct Memo {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    
    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    // The idea behind this distinction is that address payable is an address you can send Ether to, 
    // while you are not supposed to send Ether to a plain address, 
    // for example because it might be a smart contract that was not built to accept Ether.
    address payable owner;

    // List of all memos received from coffee purchases.
    Memo[] memos;

    constructor() {
        // Store the address of the deployer as a payable address.
        // When we withdraw funds, we'll withdraw here.
        // conversions from address to address payable must be explicit via payable(<address>).
        owner = payable(msg.sender);
    }

    /**
     * @dev fetches all stored memos
     */
    // function (<parameter types>) {internal|external} [pure|view|payable] [returns (<return types>)]
    // internal functions can be used in internal library functions because ( default )
    // view functions are read only functions and do not modify the state of the block chain
    // pure functions are more restrictive then view functions and do not modify the state AND do not read the state of the block chain
    // payable can receive Ether and respond to an Ether deposit for record-keeping purposes.
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /**
     * @dev buy a coffee for owner (sends an ETH tip and leaves a memo)
     * @param _name name of the coffee purchaser
     * @param _message a nice message from the purchaser
     */

    // memory keyword to store the data temporarily during the execution of a smart contract.
    // low cost involved. However, it is also volatile and has a limited capacity.

    function buyCoffee(string memory _name, string memory _message) public payable {
        // Must accept more than 0 ETH for a coffee.
        require(msg.value > 0, "can't buy coffee for free!");

        // Add the memo to storage!
        memos.push(Memo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a NewMemo event with details about the memo.
        emit NewMemo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        );
    }

    /**
     * @dev send the entire balance stored in this contract to the owner
     */
    // address(this).balance fetches the ether stored on the contract
    // owner.send(...) is the syntax for creating a send transaction with ether
    // the require(...) statement that wraps everything is there to ensure that if there are any issues, the transaction is reverted and nothing is lost
    function withdrawTips() public {
        require(owner.send(address(this).balance));
    }
}