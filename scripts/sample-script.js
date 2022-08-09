// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  let data = require("fs").readFileSync("KL_WL_Freemintv8.csv", "utf8")
  data = data.split("\r\n")
  console.log(typeof(data[1]))
  // for (let i of data2) { data2[i] = data2[i].split(",") }

  // var stream = require("fs").createReadStream("KL_WL_Freemintv8.csv", "utf8")
  // var reader = require("readline").createInterface({ input: stream })
  // var arr = []
  // reader.on("line", (row) => { arr.push(row.split(",")) })
  // console.log(arr)
  const RaffleTicket = await ethers.getContractFactory("KnivesLegacyTicket");
  const raffle_ticket = await RaffleTicket.deploy(327);

  await raffle_ticket.deployed();

  console.log("Raffle ticket deployed to:", raffle_ticket.address);

  await raffle_ticket.createRaffle("Raffle1", "test", 0, 500, 30, 100, true)
  console.log("raffle created")
  for (let i = 0; i < 25; i++) {
    console.log(i)
    let sliced_data = data.slice(i*20, i*20+20) 
    console.log(sliced_data)
    let tx = await raffle_ticket.addParticipants(1, sliced_data)
    await new Promise(r => setTimeout(r, 5000));

  }
  console.log(raffle_ticket.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
