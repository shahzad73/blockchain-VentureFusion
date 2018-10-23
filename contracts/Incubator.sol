pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';
import './Migrations.sol';

contract Incubator is Ownable {
	
	//-----------------------------------------------------------------------------------------------------
	// Incubator projects collection, Project structure and number of projects in this incubator. 
	// numberOfProjectsInThisIncubator contains number of projects in this incubator and this is 0 based
	// which means if value is 1 then first project contract is at 0 index in the mapping 
	//-----------------------------------------------------------------------------------------------------
	uint private numberOfProjectsInThisIncubator = 0;   
	struct projectsStruct {             				
		string name;
		uint8 decimals;
		string symbol;
		address projectContractAddress;
		address projectOwner;
		address projectIncubatorOwner;
	}
	mapping (uint => projectsStruct) private incubatorProjects; 

	
	
	
	//-----------------------------------------------------------------------------------------------------
	// Events in this contract 
	//-----------------------------------------------------------------------------------------------------
	event ProjectCreatedEvent(uint ProjectID, string projectName );
	
	
	
	
	//-------------------------------------------------
	// Contract Constructor       
	//-------------------------------------------------
	constructor() public 
    {
		
	}
	

	
	function getProjectCount() onlyOwner public view returns (uint) {
		return numberOfProjectsInThisIncubator;
	}
	
	
	function getProject(uint id) onlyOwner public view 
	returns ( 	string name,
				string symbol,
				uint8 decimals,
				address projectContractAddress,
				address projectOwner,
				address projectIncubatorOwner ) 
	{
	
		return (  
				incubatorProjects[id].name,
				incubatorProjects[id].symbol,
				incubatorProjects[id].decimals,
				incubatorProjects[id].projectContractAddress,
				incubatorProjects[id].projectOwner,
				incubatorProjects[id].projectIncubatorOwner		
		);
	}
	
	
	
	//-----------------------------------------------------------------------------------------
	// Add new project.   This interface will create a new project within this incubator
	//-----------------------------------------------------------------------------------------
	projectsStruct newProject;
	function addNewProject(
					address _projectOwner,
					address _incubatorOwnerAddress,
					uint _incubatorOwnerPercentageInProject, 
					address _ventureFusionOwnerAddress, 
					uint _ventureFusionPercentageInProject, 
				    string _name,
				    string _symbol,					
					uint8 _decimals
				) public onlyOwner 		
		returns ( uint newProjectID, 
				  address projectAddress, 
				  string projectName
				)
	{

		//Create new project contract
		address newProjectContract = new ProjectEquity(_projectOwner, _incubatorOwnerAddress, _incubatorOwnerPercentageInProject, _ventureFusionOwnerAddress, _ventureFusionPercentageInProject, _name, _symbol, _decimals);

		//Create project structure object and add it to projects collection
		newProject = projectsStruct(_name, _decimals, _symbol, newProjectContract, _projectOwner, _incubatorOwnerAddress);
		incubatorProjects[numberOfProjectsInThisIncubator] = newProject;
		
		//Transfer ownership to project owner
		require(newProjectContract.call(bytes4(keccak256("transferOwnership(address)")),_projectOwner));
		
		//Emit event that project has been created 
		emit ProjectCreatedEvent(numberOfProjectsInThisIncubator, _name);
		
		//Increment counter for next new project
		numberOfProjectsInThisIncubator = numberOfProjectsInThisIncubator + 1;
		
		//Set return values of this function 
		newProjectID = numberOfProjectsInThisIncubator;
		projectAddress = newProject.projectContractAddress;
		projectName = _name;
		
	}



}

