pragma solidity ^0.4.24;
//https://blog.zeppelin.solutions/how-to-create-token-and-initial-coin-offering-contracts-using-truffle-openzeppelin-1b7a5dae99b6

import "./contracts/crowdsale/emission/MintedCrowdsale.sol";


contract VentureFusionVET_Crowdsale is MintedCrowdsale, Ownable {

    constructor (
            uint256 _rate,
            address _wallet,
            MintableToken _token
    )
    public 
	Crowdsale(_rate, _wallet, _token)    //call the constructor of the parent
	{ 
	
	}

	
    // -----------------------------------------
    //  Set new rate for VET tokens
    //  New token mintered will be now on this rate 
    // ----------------------------------------
    function setRate(uint256 _rate) onlyOwner public {
	    rate = _rate;
    }

}
