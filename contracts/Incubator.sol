pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';

contract Incubator is Ownable {
	
	uint public ventureFusionPercentageInProject;
	uint public transactionPriceInTokens;
	
	
	uint public numberOfProjectsInThisIncubator = 0;   //current number of project in this incubator
	struct projectsStruct {             //project structure
		string projectName;
		address projectContractAddress;
	}
	mapping (uint => projectsStruct) public incubatorProjects;     //mapping of projects
	
	
	
	constructor(uint _projectPercentage, uint _transactionPriceInTokens) public {
		
	}
	
	
	//-------------------------------------------------
	// Change the percentages owned by VentureFusion when creating a new project  
	//-------------------------------------------------
	function changeProjectPercentage(uint _projectPercentage) public onlyOwner {	
		ventureFusionPercentageInProject = _projectPercentage;
	}
	
	
	//-------------------------------------------------
	// This interface will be called by the VentureFusion admin and will set the number of tokens required to perform 
    // each transaction in this incubator. For exmaple to launch SellBuy shares needs 4 VET tokens  	
	//-------------------------------------------------
	function setVETTokenTransactionPrice(uint _transactionPriceInTokens) public onlyOwner {
		transactionPriceInTokens = _transactionPriceInTokens;
	}

	
	//-------------------------------------------------
	// Add new project.   This will create a new project within this incubator
	//-------------------------------------------------
	function addNewProject(string _projectName) 
		public onlyOwner 
		returns ( uint newProjectID, address projectAddress )  
	{
		projectsStruct storage newProject;
		newProject.projectName = _projectName;
		newProject.projectContractAddress = 0x0;
		incubatorProjects[numberOfProjectsInThisIncubator] = newProject;

		//set return values 
		newProjectID = numberOfProjectsInThisIncubator;
		projectAddress = newProject.projectContractAddress;

		//increment the counter for next new project
		numberOfProjectsInThisIncubator = numberOfProjectsInThisIncubator + 1;		
	}



}