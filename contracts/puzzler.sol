pragma solidity 0.5.3;

// Importing OpenZeppelin's ERC-721 and SafeMath Implementation
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract puzzler is ERC721Full {
    // ----------------
    // Variables
    // ----------------
    
    string public name = "Puzzler";
    string public symbol = "PZLR";
    
    // spiro struct 
    struct Spiro {
        uint level; // level at which it is created
        address creator;
    }
    // list of existing spiros 
    Spiro[] public spiros;
    
    // maps each user to his progress in the puzzler
    mapping (address => uint256) public userProgress;   
    // ether balance of all users     
    mapping (address => uint) public balanceOfEther;
    // if 0, spiro not for sale 
    mapping (uint => uint) public spiroToSalePrice;
    
    // owner of a spiro  
    mapping (address => uint) public ownerToSpiro;
    
    // ----------------
    // Events
    // ----------------
    
    // new spiro generation
    event newSpiro (address creator, uint level);
    // new spiro up for sale 
    event emitUpForSale (uint256 _spiroId);
    // bought a spiro 
    event emitBought (uint256 _spiroId, uint256 _at, address _by);
    // sale offer removed from spiro 
    event emitSaleOfferRemoved (uint256 _spiroId);
    // user levelled up 
    event emitLevelUp (address user);
    
    // ----------------
    // Constructors
    // ----------------
    
    constructor () ERC721Full (name, symbol) public {
    } 
    
    // ----------------
    // Functions
    // ----------------
    
    // check to see if a given address is that of a contract 
    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    // fallback function
    function() external payable {
    }
    
    /** @dev funtion that generates a new spiro
      * @param userLevel - level at which the user is 
      * @return the new spiro's id 
      */
    function createSpiro(uint userLevel) public returns (uint) {
        require(msg.sender != address(0));
        require (userLevel > 0);
        
        Spiro memory NewSpiro = Spiro ({
            level: userLevel,
            creator: msg.sender
        });
        
        uint256 newSpiroId = spiros.push(NewSpiro).sub(1);
        
        // the minted token is owned by the smart contract until purchased
        super._mint(address(this), newSpiroId);
        
        // update user progress 
        userProgress[msg.sender] = userLevel;
        emit emitLevelUp (msg.sender);
        
        // created-by and level of the creator
        emit newSpiro (msg.sender, userLevel);
        
        return newSpiroId;
    }
    
    /**@dev function to allow user to buy the spiro he has created   
     * transfer of ownership from the contract to the creator
     */
    function buyNewSpiro (uint _spiroId) public payable {
        uint amount = spiros[_spiroId].level * 0.005 ether;
        require (msg.value == amount);
        require (spiros[_spiroId].creator == msg.sender);
        require (userProgress[msg.sender] == spiros[_spiroId].level);
        require (!isContract(msg.sender));
        ownerToSpiro[msg.sender] = _spiroId;
        
        super._transferFrom(ownerOf(_spiroId), msg.sender, _spiroId);
        
        // spiroToSalePrice[_spiroId] = 0; // not exactly required. But jussssst to be on safe side
        
        balanceOfEther[msg.sender] += msg.value;
        
        emit emitBought (_spiroId, msg.value, msg.sender);
    }
    
    /**@dev function to allow user to buy a spiro from a different owner
     */
    function buySpiro(uint _spiroId) public payable {
        
        require (spiroToSalePrice[_spiroId] > 0);
        require (msg.value == spiroToSalePrice[_spiroId]);
        require (!isContract(msg.sender));
        // can only buy a spiro representing a higher level 
        require(userProgress[msg.sender] <= spiros[_spiroId].level);
        
        // user can only own a single spiro - 
        // buying a spiro while already owning one would automatically 
        // put for sale the previously owned spiro
        sellSpiro (ownerToSpiro[msg.sender]);
        
        ownerToSpiro[msg.sender] = _spiroId;
        
        super._transferFrom(ownerOf(_spiroId), msg.sender, _spiroId);
        
        balanceOfEther[msg.sender] += msg.value;
        spiroToSalePrice[_spiroId] = 0;
        
        emit emitBought(_spiroId, msg.value, msg.sender);
    }
    
    /**@dev sell a spiro 
     * @param _spiroId to sell 
     */
    function sellSpiro(uint _spiroId) public {
        require (msg.sender == ownerOf(_spiroId));
        require (!isContract(msg.sender));
        
        uint salePrice = spiros[_spiroId].level * 0.005 ether;
        
        spiroToSalePrice[_spiroId] = salePrice;
        userProgress[msg.sender] = 0;
        emit emitUpForSale(_spiroId);
    }
    
    /** @dev withdraw ether off the contract
     */
     
    function withdraw() public {
        uint amount = balanceOfEther[msg.sender];
        balanceOfEther[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    /** @dev return spiros owned by the contract 
     */
    function getSpiros () public view returns (uint [] memory) {
        uint [] memory result = new uint[](spiros.length);
        uint counter = 0;
        for (uint i = 0; i < spiros.length; i ++) {
            if (ownerOf(i) == address(this)) {
                result[counter] = i;
                counter ++;
            }
        }
        return result;
    } 
    
    /** @dev return spiros currently on sale 
     */
    function getUpForSellingSpiros () public view returns (uint [] memory) {
        uint [] memory result = new uint[](spiros.length);
        uint counter = 0;
        for (uint i = 0; i < spiros.length; i ++) {
            if (spiroToSalePrice[i] > 0) {
                result[counter] = i;
                counter ++;
            }
        }
        return result;
    } 
    
    
}