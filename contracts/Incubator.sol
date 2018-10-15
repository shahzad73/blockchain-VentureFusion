pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';

contract Incubator is Ownable {
	
	uint public incubatorOwnerPercentageInProject;	
	uint public ventureFusionPercentageInProject;
	uint public ProjectSingleShareDivision;
	
	address internal ventureFusionOwnerAddress;	
	uint public transactionPriceInTokens;
	
	
	//-----------------------------------------------------------------------------------------------------
	// Incubator projects collection, Project structure and number of projects in this incubator. 
	// numberOfProjectsInThisIncubator contains number of projects in this incubator and this is 0 based
	// which means if value is 1 then first project contract is at 0 index in the mapping 
	//-----------------------------------------------------------------------------------------------------
	uint public numberOfProjectsInThisIncubator = 0;   
	struct projectsStruct {             				
		string projectName;
		address projectContractAddress;
		uint ProjectSingleShareDivision;
		address projectOwner;
	}
	mapping (uint => projectsStruct) public incubatorProjects; 

	
	
	//-----------------------------------------------------------------------------------------------------
	// Events in this contract 
	//-----------------------------------------------------------------------------------------------------
	event changeIncubatorOwnerProjectPercentageEvent(uint oldPercentage, uint percentage);
	event changeVentureFusionProjectPercentageEvent(uint oldPercentage, uint percentage);
	event changeVETTokenForTransactionsEvent(uint oldPrice, uint price);
	event changeProjectSingleShareDivisionEvent(uint oldSingleShareDivision, uint singleShareDivision);	
	event ProjectCreatedEvent(uint ProjectID, string projectName, uint incubatorOwnerPercentageInProject, address ventureFusionOwnerAddress, uint ventureFusionPercentageInProject, uint ProjectSingleShareDivision );
	
	
	
	
	//-------------------------------------------------
	// Contract Constructor       
	//-------------------------------------------------
	constructor( 
	     uint _incubatorOwnerPercentageInProject,            // Percentage of Incubator owner in new project 
		 uint _ventureFusionPercentageInProject,             // VentureFusion percantage in new projects 
		 address _ventureFusionOwnerAddress,                 // Address of VentureFusion Owner 
		 uint _transactionPriceInTokens,                     // Transaction price in VET tokens in this incubator 
		 uint _singleShareDivision)                          // Division of each share in this incubator
    public 
    {
		incubatorOwnerPercentageInProject = _incubatorOwnerPercentageInProject;
		ventureFusionPercentageInProject = _ventureFusionPercentageInProject;
		transactionPriceInTokens = _transactionPriceInTokens;
		ventureFusionOwnerAddress = _ventureFusionOwnerAddress;
		ProjectSingleShareDivision = _singleShareDivision;
	}
	
	
	
	
	//-------------------------------------------------
	// Check that only venture fusion owner is calling this function
	//-------------------------------------------------
	modifier onlyVentureFusionOwner() {
		require(msg.sender == ventureFusionOwnerAddress);
		_;
	}
	

	//---------------------------------------------------------------------------------
	// Change the percentages owned by incubator owner when creating a new project
	//---------------------------------------------------------------------------------
	function changeIncubatorOwnerProjectPercentage(uint _projectPercentage) public onlyVentureFusionOwner {	
		emit changeIncubatorOwnerProjectPercentageEvent(incubatorOwnerPercentageInProject, _projectPercentage);
		incubatorOwnerPercentageInProject = _projectPercentage;
	}
	
	
	//---------------------------------------------------------------------------------
	// Change the percentages owned by VentureFusion when creating a new project  
	//---------------------------------------------------------------------------------
	function changeVentureFusionProjectPercentage(uint _projectPercentage) public onlyVentureFusionOwner {	
		emit changeVentureFusionProjectPercentageEvent(ventureFusionPercentageInProject, _projectPercentage);
		ventureFusionPercentageInProject = _projectPercentage;
	}
	
	
	//-------------------------------------------------------------------------------------------------------------
	// This interface will be called by the VentureFusion admin and will set the number of tokens required to perform 
    // each transaction in this incubator. For exmaple to launch SellBuy shares needs 4 VET tokens  	
	//-------------------------------------------------------------------------------------------------------------
	function changeVETTokenForTransactions(uint _transactionPriceInTokens) public onlyVentureFusionOwner {
		emit changeVETTokenForTransactionsEvent(transactionPriceInTokens, _transactionPriceInTokens);
		transactionPriceInTokens = _transactionPriceInTokens;
	}

	
	
	//-------------------------------------------------------------------------------------------------------------
	// This interface can be called by VentureFusion owner to set the decimal places for new projects 
	//-------------------------------------------------------------------------------------------------------------
	function changeProjectSingleShareDivision(uint _singleShareDivision) public onlyVentureFusionOwner {
		emit changeProjectSingleShareDivisionEvent(ProjectSingleShareDivision, _singleShareDivision);
		ProjectSingleShareDivision = _singleShareDivision;
	}
	
	

	//-----------------------------------------------------------------------------------------
	// Add new project.   This interface will create a new project within this incubator
	//-----------------------------------------------------------------------------------------
	projectsStruct newProject;
	function addNewProject(string _projectName, address _projectOwner) 
		public onlyOwner 
		returns ( uint newProjectID, address projectAddress, string projectName )  
	{
		//Create new project contract
		address newProjectContract = new ProjectEquity(_projectOwner, owner, incubatorOwnerPercentageInProject, ventureFusionOwnerAddress, ventureFusionPercentageInProject, ProjectSingleShareDivision);
		
		//Create project structure object and add it to projects collection
		newProject = projectsStruct(_projectName, newProjectContract, ProjectSingleShareDivision, _projectOwner);
		incubatorProjects[numberOfProjectsInThisIncubator] = newProject;
		
		//Transfer ownership to project owner
		require(newProjectContract.call(bytes4(keccak256("transferOwnership(address)")),_projectOwner));
		
		//Emit event that project has been created 
		emit ProjectCreatedEvent(numberOfProjectsInThisIncubator, _projectName, incubatorOwnerPercentageInProject, ventureFusionOwnerAddress, ventureFusionPercentageInProject, ProjectSingleShareDivision);
		
		//Increment counter for next new project
		numberOfProjectsInThisIncubator = numberOfProjectsInThisIncubator + 1;
		
		//Set return values of this function 
		newProjectID = numberOfProjectsInThisIncubator;
		projectAddress = newProject.projectContractAddress;
		projectName = _projectName;
		
	}


}

