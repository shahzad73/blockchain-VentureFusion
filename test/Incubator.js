var Incubator = artifacts.require("./Incubator.sol");
const truffleAssert = require('truffle-assertions');

contract('Incubator', function(accounts) {


  beforeEach(async () => {

  });




  it("Using Async for above function", async () => {  
    
	const meta = await Incubator.deployed();
	
	var percent = (await meta.incubatorOwnerPercentageInProject.call()).toNumber();
	
	assert.equal(percent.valueOf(), 1, "Expected value 1 was not returned");
	
  });




  it("Async func called 2", async () => {  
  
	const acct = accounts[0];
  
 	 var meta = await Incubator.deployed();

	 let tx = await meta.addNewProject("Test Proj 101", {from : acct});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 101" && ev.ProjectNo == 0;
     });	 
	 
	 tx = await meta.addNewProject("Test Proj 102", {from : acct});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 102" && ev.ProjectNo == 1;
     });	 
	 
	 tx = await meta.addNewProject("Test Proj 103", {from : acct});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 103" && ev.ProjectNo == 2;
     });
	 	 
	 var counts = await meta.numberOfProjectsInThisIncubator();
	 assert.equal(counts.valueOf(), 3, "3 Project should have been created");
	 //console.log("Number of Project : " + counts);

  });



  
  afterEach(async () => {

  });





});









/*
     
  it("Check VentureFusion Percentage in project has been initialized correctly", function() {
    
	return Incubator.deployed()
	.then(function(instance) 
	{
		return instance.ventureFusionPercentageInProject.call();
    }).then(function(balance) 
	{
	    assert.equal(balance.valueOf(), 1, "Expected value 1 was not returned");
    });
	
  });
  
  
  
  
  
  it("Check VentureFusion Percentage in project has been initialized correctly", function() {  
	
		return Incubator.deployed()
		.then(function(instance) 
		{
			return instance.addNewProject.call("Test Proj 1");
		}).then(function(params) 
		{
			assert.equal(params[0].valueOf(), 0, "Expected value 0 was not returned");
			return Incubator.deployed();
		})
		.then(function(instance) 
		{
			return instance.addNewProject.call("Test Proj 2");
		}).then(function(params) 
		{
			assert.equal(params[0].valueOf(), 0, "Expected value 1 was not returned");
		});
  
  });
  
 */