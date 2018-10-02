pragma solidity ^0.4.24;

import './ERC20/MintableToken.sol';


contract VentureFusion_VET is MintableToken {

    string public name = "Venture Fusion VET Token";
    string public symbol = "VFVT";
    uint8 public decimals = 18;


	constructor() public {
		
	}


	//TODO    override token transfers so before token trnasfers check stacked tokens


	// -----------------------------------------
	// VET Token Stacking / UnStacking
	// Called by owner of the tokens to stack some amount VET token against a specific skill set. Stack tokens 
	// will be locked and will not be used for any transactions. 
	//
	// Stocked tokens will also be tracked within this contract. It will track how many token are stacked against a 
	//specific project or how many tokens are stacked against a specific skill 
	// -----------------------------------------
	function stackVETTokens(uint256 _vetTokenAmount) public payable {

	}  
	  
	  
	function unStackVETTokens(uint256 _vetTokenAmount) public payable {

	}



}