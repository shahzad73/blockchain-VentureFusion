var Incubator = artifacts.require("./Incubator.sol");
var projectEquity = artifacts.require("./ProjectEquity.sol");
const truffleAssert = require('truffle-assertions');

contract('Incubator', function(accounts) {


  beforeEach(async () => {

  });




  it("Create new project and make transfers", async () => {  
  
	const ventureFusionAccount = accounts[0];
	const incubatorOwner1 = accounts[1];
	const projectOwner = accounts[3];
	 
 	 var meta = await Incubator.deployed();

	 let tx = await meta.addNewProject("Test Proj 101", projectOwner, incubatorOwner1, 3000, ventureFusionAccount, 2000, 3, {from : ventureFusionAccount});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 101" && ev.ProjectID == 0;
     });
	 var zz = await meta.incubatorProjects(0);	 
	 var inc = await projectEquity.at(zz[1]);
	 
	 var decimals = await inc.decimals();
	 assert.equal(decimals.valueOf(), 3, "3 decimals should be returned");
	 
	 var incubatorOwnPercent = await inc.balanceOf(incubatorOwner1);
	 assert.equal(incubatorOwnPercent.valueOf(), 3000, "3000 decimals should be returned");

	 var VFOwnPercent = await inc.balanceOf(ventureFusionAccount);
	 assert.equal(VFOwnPercent.valueOf(), 2000, "2000 decimals should be returned");

	 var projectOwnPercent = await inc.balanceOf(projectOwner);
	 assert.equal(projectOwnPercent.valueOf(), 95000, "95000 decimals should be returned");
	 
  });


  
  
  
  
  it("Test trasnfer of shares between people", async () => {  
  
	const ventureFusionAccount = accounts[0];        //2000 shares 
	const incubatorOwner1 = accounts[1];             //3000 shares
	const projectOwner = accounts[3];                //9500 shares 
	const shareHolder1 = accounts[5];                //0 shares 
	const shareHolder2 = accounts[6];                //0 shares 
	 
 	var meta = await Incubator.deployed();  
  
	//check there is one project
	var counts = await meta.numberOfProjectsInThisIncubator();
	assert.equal(counts.valueOf(), 1, "1 Project should have been created");
	
	 	
	//transfer some shares from project owner to share holder 1
	 var zz = await meta.incubatorProjects(0);	 //get the first project contract 
	 var project = await projectEquity.at(zz[1]);
	 
	 
	 //first check that share holder 1 has 0 shares
	 var share1 = await project.balanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 0, "0 decimals should be returned");	 
	 
	 tx = await project.transfer(shareHolder1, 1000, {from : projectOwner});
	 //ToDo  raise a event and check the values 
	 //Now check that share holder 1 has 1000 shares 
	 share1 = await project.balanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 1000, "1000 decimals should be returned");  

	 share1 = await project.balanceOf(projectOwner);
	 assert.equal(share1.valueOf(), 94000, "1000 decimals should be returned");  

	 tx = await project.transfer(shareHolder2, 300, {from : shareHolder1});
	 //Now check that share holder 1 has 700 shares 
	 share1 = await project.balanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 700, "700 decimals should be returned");  
	 share1 = await project.balanceOf(shareHolder2);
	 assert.equal(share1.valueOf(), 300, "300 decimals should be returned");  

	 tx = await project.transfer(shareHolder1, 100, {from : shareHolder2});
	 share1 = await project.balanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 800, "800 decimals should be returned");  
	 share1 = await project.balanceOf(shareHolder2);
	 assert.equal(share1.valueOf(), 200, "200 decimals should be returned");  

  });
  

  
  

  
  
  it("Test trasnfer approval and transfer from", async () => {  
  
	const ventureFusionAccount = accounts[0];        //2000 shares 
	const incubatorOwner1 = accounts[1];             //3000 shares
	const projectOwner = accounts[3];                //9400 shares 
	const shareHolder1 = accounts[5];                //800 shares 
	const shareHolder2 = accounts[6];                //200 shares 
	const shareHolder3 = accounts[7];                //0 shares 
	 
 	var meta = await Incubator.deployed();  
  
	//transfer some shares from project owner to share holder 1
	var zz = await meta.incubatorProjects(0);	 //get the first project contract 
	var project = await projectEquity.at(zz[1]);	
	
	//First check that share holder 1 has 0 shares from project owner that he can spend 
	let share1 = await project.allowance(projectOwner, shareHolder1);
	assert.equal(share1.valueOf(), 0, "0 decimals should be returned");  	
	let tx = await project.approve(shareHolder1, 1000, {from : projectOwner});
    truffleAssert.eventEmitted(tx, 'Approval', (ev) => {
		return ev.value == 1000
    });
	//Now check that share holder 1 has 1000 shares that he can spend 
	share1 = await project.allowance(projectOwner, shareHolder1);
	assert.equal(share1.valueOf(), 1000, "1000 decimals should be returned");  


	//now using the shares of project owner  share holder 1 will transfer share to share holder 3
	tx = await project.transferFrom(projectOwner, shareHolder3, 500, {from : shareHolder1});
    truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
		return ev.value == 500
    });
	//Now check that share holder 1 has 1000 shares that he can spend from project owner's shares 
	share1 = await project.allowance(projectOwner, shareHolder1);
	assert.equal(share1.valueOf(), 500, "500 decimals should be returned");  
	//Also check that share holder 3 has 500 shares 
	share1 = await project.balanceOf(shareHolder3);
	assert.equal(share1.valueOf(), 500, "500 decimals should be returned");  
	//Also check that project owner shares are decreased by 500
	share1 = await project.balanceOf(projectOwner);
	assert.equal(share1.valueOf(), 93500, "93500 decimals should be returned");  
	
  });	
  
  

  
  
  afterEach(async () => {

  });





});





