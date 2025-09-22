// scripts/deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const RNVCOIN = await ethers.getContractFactory("RNVCOIN");
  const token = await RNVCOIN.deploy(deployer.address);

  await token.deployed();

  console.log("RNVCOIN deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
