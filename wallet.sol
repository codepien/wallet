pragma solidity 0.7.5;
pragma abicoder v2;

contract DAO {

    //create a directory for Dao members by index    
    mapping(uint => Owner) public owners;
    
    //create oject or struct for a class of member
    struct Owner {
        string name;
        address _address;
    }
    
    uint balance;
    
    address CEO;
    
    Owner[] board;
    
    address[] voted;
    
    string[] displayMembers;
    
    event transfer(address _to, uint _amount);
    
    //wanted a way to ensure that only the CEO can add and delete members to the board. Decided to set
    //definition of CEO and use the require(msg.sender == CEO)
    constructor() {
        CEO = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    }

    //CEO adds member to board. Require function to make sure only CEO can add.
    //created and _index for the mapping above.
    //once create the members were pushed into the board[] array.
    //incremented the _index by 1 so that each member has it's own mapping key
    function addUser(string memory _name, address _address) public {
        require(msg.sender == CEO);
        uint _index = 0;
        Owner memory owner = Owner(_name, _address);
        owners[_index] = owner;
        board.push(owner);
        _index++;
        
        //cleared out displayMembers becuase we are going to recreate the entire array below
        for(uint i = 0; i < displayMembers.length; i++) {
            delete displayMembers[i];
        }
        
        //recreate the displayedMembers array including the new member
        for (uint i = 0; i < board.length; i++) {
            Owner memory member = board[i];
            displayMembers.push(member.name);
        }
        
    }
    
    //Only CEO can delete member
    function deleteUser(address _address) public {
        require(msg.sender == CEO);
        
        //search through board array for the address we want to delete, then delete
        for (uint i = 0; i < board.length; i++) {
           Owner memory owner = board[i];
           if (owner._address == _address) {
               delete board[i];
           }
            
        }
        
        //delete the entire displayMember array because we will recreate the array with the updated list
        for(uint i = 0; i < displayMembers.length; i++) {
            delete displayMembers[i];
        }
        
        //recreate the entire displayMembers[] array with updated list
        for (uint i = 0; i < board.length; i++) {
            Owner memory member = board[i];
            displayMembers.push(member.name);
        }
    }
    
    //taken from the displayMember[] array we display the current board members by string name.
    function displayBoard() public view returns(string[] memory) {
        return displayMembers;
    }
    
    //Create a way for participants to deposit into the Wallet contract
    function deposit() public payable {
        balance += msg.value;   
    }
    
    //Be able to check the current balance of the contract
    function contractBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    //check it see who approved the transaction. We want this array to make sure members can't double vote.
    //So when we approve a transaction we search through voted[]array to see if they voted before
    //if already voted before, we do not enable that vote to approve the transaction
    function displayVoted() public view returns(address[] memory) {
        return voted; 
    }
    
    //set up state variables so we can display same amounts form request transaction
    //in the display and approve functions. They are referenced in those functions.
    //They need to be state, becuase if if were just in the requestTx function
    //the other functions would not be able to access them
    address payable txTo;
    uint txAmount;
    
    function requestTx(address payable txAddress, uint txValue) public payable {
        txTo = txAddress;
        txAmount = txValue;

        //We delete the entire voted[] arrray because it is a new transaction
        //we don't want old voted to be used for a different transaction
        for(uint i = 0; i < voted.length; i++) {
            delete voted[i];
        }
        
    }
    //display request for board members so they can decided whether to approve or not
    function viewRequest() public view returns(address, uint) {
        return (txTo, txAmount);
    }
    
    //set up a state variable to keep track if msg.sender already voted
    //needed to be state because it needs to be accessed from a different if then statement
    //always reset to false when a vote goes through
    //so each approval send with start off false
    //then we run the check in voted[] array
    //if address in voted[] array then we set alreadyVoted to true;
    bool alreadyVoted = false;
    
    function approvetx() public returns(string memory) {
        
        require(address(this).balance >= txAmount, "The Dao does not have enough funds");
        
        for(uint i = 0; i < voted.length; i++) {
            if (msg.sender == voted[i]) {
                alreadyVoted = true;
           }
       }
        //we reference the alreadyVoted to see with we should count the vote
        //if false then we count the vote and push that address into the voted[]array
        if (alreadyVoted == false) {
            voted.push(msg.sender);
            //Since we need two members to approve the transaction, we check to see
            //if the voted[]array has to entries
            //if true we transfer the money
            if (voted.length >=2) {
                txTo.transfer(txAmount);
                emit transfer(txTo, txAmount);
                alreadyVoted = false;
            } else {
                //if there is not more than two entries in the array
                //we tell them there needs to be two approvals
                //here is where we set the already voted
                alreadyVoted = false;
                return "You need one more approval";
                }
        
            
        } else {
            //if already voted is true. then we tell them
            //and reset the alreadyVoted state varaible to back to false for the next
            //approval check
            alreadyVoted = false;
            return "You have already voted";
        }
    }
    //this was used just to check if things were working correctly
    //sometimes it's hard to find where the error is?
    //I put out functions to make sure certain steps are working
    //The challenge is find out which step is not working correctly
    function viewVoted() public view returns(bool) {
        return alreadyVoted;
    }
}





