pragma solidity ^0.4.19;
/**
 * Smart contract to track meat product in its lifecycle from producer to end consumer.
 */
contract LeanMeat {
    address public owner;
    // Object holds important timepoint of product
    struct TimePoint {
        address recordedBy;
        uint256 updatedAt;
    }
    // Product definition
    struct Product {
        uint32 id;
        string category;
        string description;
        // List of import timepoints for given product
        mapping(string=>TimePoint) timePoints;
    }
    // product list, id as key
    mapping(uint32 => Product) products;
    // User object
    struct User {
        uint role;
        string name;
    }
    // List of users
    mapping(address => User) users;
    address[] userAddresses;
    
    event timeSpointEvent(address _a, string indexed _addr, uint256 indexed _date);
    
    constructor() public {
        owner = msg.sender;
    }
    
    /**
     * Get number of users.
     * 
     * @return integer, number of users
     */
    function getUserCount() public view returns (uint) {
        return userAddresses.length;
    }
    
    /**
     * Get user addresses of users.
     * 
     * @return list of user addresses
     */
    function getUsers() public view returns (address[]) {
        return userAddresses;
    }
    
    /**
     * Get user by address.
     * 
     * @return array which include role of user
     */
    function getUser(address _address) public view returns (uint, string) {
        // since address will always be available even it doesn't exist before, it simply defaults to 0/false for int
        if (users[_address].role == 0) {
            revert();
        }
        return (users[_address].role, users[_address].name);
    }
    
    /**
     * Check role of the given user/address.
     * 
     * @return user role, valid value, 1,2
     */
    function check() public view returns (uint) {
        return users[msg.sender].role;
    }
    
    // 1 - Producer, 2 - Shipper
    /**
     * Add user to system, only Admin is allowed to do this.
     */
    function addUser(address _address, uint _role, string _name) public {
        if (msg.sender != owner) revert();
        users[_address] = User(_role, _name);
        userAddresses.push(_address);
    }
    
    /**
     * Return product details by id.
     * 
     * @return id, category, description and stringified timePoints
     */
    function getProduct(uint32 _id) public view returns (uint32, string, string, string) {
        // if id doesn't exist, abort.
        if (products[_id].id == 0) {
            revert();
        }
        
        string memory stringifiedTimePoints = strConcat(
            exactTimePointToString(products[_id].timePoints["productPacked"]), 
            "==========", 
            exactTimePointToString(products[_id].timePoints["productShipped"]), 
            "==========", 
            exactTimePointToString(products[_id].timePoints["productBought"]));
        
        return (products[_id].id, products[_id].category, products[_id].description, stringifiedTimePoints);
    }
    
    /**
     * Action when product get packed.
     * 1. Only Producer can call this function
     * 2. update timestamp
     * 3. update id, cateory and description
     */
    function productPacked(uint32 _id, string _category, string _description) public {
        // if caller is not producer, abort
        if (users[msg.sender].role == 0) {
            revert();
        }
        products[_id] = Product(_id, _category, _description);
        products[_id].timePoints["productPacked"] = TimePoint(msg.sender, now);
        
        emit timeSpointEvent(products[_id].timePoints["productPacked"].recordedBy, toAsciiString(products[_id].timePoints["productPacked"].recordedBy), products[_id].timePoints["productPacked"].updatedAt);
    }
    
    /**
     * Action when product get shipped.
     * 1. Only Shipper can call this function
     * 2. update timestamp
     * 
     */
    function productShipped(uint32 _id) public {
        // if caller is not producer, abort
        if (users[msg.sender].role == 0) {
            revert();
        }
        products[_id].timePoints["productShipped"] = TimePoint(msg.sender, now);
    }
    
    /**
     * Action when consumer does a purchase.
     * 1. Any one can use this method
     * 2. update timestamp
     * 
     */
    function productBought(uint32 _id) public {
        products[_id].timePoints["productBought"] = TimePoint(msg.sender, now);
    }
    
    function temperatureSenser(uint32 _id, string temperature) public {
        // by given a product, rule is it has to be delivered between 0-10 degree.
        // if the temperature voilcate the rule, price will be affect by -5%
    }
    
    function addressToBytes(address _a) private pure returns (bytes32 b) {
        b = bytes32(uint256(_a) << 96);
    }
    
    function toAsciiString(address x) private pure returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
    
    function char(byte b) private pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
    /**
     * Convert uint to string.
     */
    function uintToString(uint v) private pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }
    
    function strConcat(string _a, string _b, string _c, string _d, string _e) private pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    /**
     * Convert TimePoint object to string
     */
    function exactTimePointToString(TimePoint u) private pure returns (string data)
    {
        string memory addr = toAsciiString(u.recordedBy);
        string memory date = uintToString(u.updatedAt);
        return (strConcat(addr, ";", date, "", ""));
    }
}