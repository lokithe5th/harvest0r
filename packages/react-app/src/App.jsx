import { Button, Card, Col, Input, InputNumber, List, Menu, Row } from "antd";

import "antd/dist/antd.css";
import {
  useBalance,
  useContractLoader,
  useContractReader,
  useGasPrice,
  // useOnBlock,
  useUserProviderAndSigner,
} from "eth-hooks";
import { useExchangeEthPrice } from "eth-hooks/dapps/dex";
import React, { useCallback, useEffect, useState } from "react";
import { Link, Route, Switch, useLocation } from "react-router-dom";
import "./App.css";
import {
  Account,
  Contract,
  Faucet,
  GasGauge,
  Header,
  Ramp,
  ThemeSwitch,
  NetworkDisplay,
  FaucetHint,
  NetworkSwitch,
  AddressInput,
  Address,
} from "./components";
import { NETWORKS, ALCHEMY_KEY } from "./constants";
import externalContracts from "./contracts/external_contracts";
// contracts
import deployedContracts from "./contracts/hardhat_contracts.json";
import { getRPCPollTime, Transactor, Web3ModalSetup } from "./helpers";
import { Home, Seeds, Subgraph } from "./views";
import { useStaticJsonRPC } from "./hooks";
import { ZERO_ADDRESS } from "./components/Swap";

const { ethers } = require("ethers");
/*
    Welcome to 🏗 scaffold-eth !

    Code:
    https://github.com/scaffold-eth/scaffold-eth

    Support:
    https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA
    or DM @austingriffith on twitter or telegram

    You should get your own Alchemy.com & Infura.io ID and put it in `constants.js`
    (this is your connection to the main Ethereum network for ENS etc.)


    🌏 EXTERNAL CONTRACTS:
    You can also bring in contract artifacts in `constants.js`
    (and then use the `useExternalContractLoader()` hook!)
*/

/// 📡 What chain are your contracts deployed to?
const initialNetwork = NETWORKS.goerli; // <------- select your target frontend network (localhost, goerli, xdai, mainnet)

// 😬 Sorry for all the console logging
const DEBUG = false;
const NETWORKCHECK = true;
const USE_BURNER_WALLET = true; // toggle burner wallet feature
const USE_NETWORK_SELECTOR = false;

const web3Modal = Web3ModalSetup();

// 🛰 providers
const providers = [
  `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_KEY}`
];

function App(props) {
  // specify all the chains your app is available on. Eg: ['localhost', 'mainnet', ...otherNetworks ]
  // reference './constants.js' for other networks
  const networkOptions = [initialNetwork.name];

  const [injectedProvider, setInjectedProvider] = useState();
  const [address, setAddress] = useState();
  const [selectedNetwork, setSelectedNetwork] = useState(networkOptions[0]);
  const location = useLocation();

  const targetNetwork = NETWORKS[selectedNetwork];

  // 🔭 block explorer URL
  const blockExplorer = targetNetwork.blockExplorer;

  // load all your providers
  const localProvider = useStaticJsonRPC([
    process.env.REACT_APP_PROVIDER ? process.env.REACT_APP_PROVIDER : targetNetwork.rpcUrl,
  ]);

  const mainnetProvider = useStaticJsonRPC(providers, localProvider);

  // Sensible pollTimes depending on the provider you are using
  const localProviderPollingTime = getRPCPollTime(localProvider);
  const mainnetProviderPollingTime = getRPCPollTime(mainnetProvider);

  if (DEBUG) console.log(`Using ${selectedNetwork} network`);

  // 🛰 providers
  if (DEBUG) console.log("📡 Connecting to Mainnet Ethereum");

  const logoutOfWeb3Modal = async () => {
    await web3Modal.clearCachedProvider();
    if (injectedProvider && injectedProvider.provider && typeof injectedProvider.provider.disconnect == "function") {
      await injectedProvider.provider.disconnect();
    }
    setTimeout(() => {
      window.location.reload();
    }, 1);
  };

  /* 💵 This hook will get the price of ETH from 🦄 Uniswap: */
  const price = useExchangeEthPrice(targetNetwork, mainnetProvider, mainnetProviderPollingTime);

  /* 🔥 This hook will get the price of Gas from ⛽️ EtherGasStation */
  const gasPrice = useGasPrice(targetNetwork, "fast", localProviderPollingTime);
  // Use your injected provider from 🦊 Metamask or if you don't have it then instantly generate a 🔥 burner wallet.
  const userProviderAndSigner = useUserProviderAndSigner(injectedProvider, localProvider, USE_BURNER_WALLET);
  const userSigner = userProviderAndSigner.signer;

  useEffect(() => {
    async function getAddress() {
      if (userSigner) {
        const newAddress = await userSigner.getAddress();
        setAddress(newAddress);
      }
    }
    getAddress();
  }, [userSigner]);

  // You can warn the user if you would like them to be on a specific network
  const localChainId = localProvider && localProvider._network && localProvider._network.chainId;
  const selectedChainId =
    userSigner && userSigner.provider && userSigner.provider._network && userSigner.provider._network.chainId;

  // For more hooks, check out 🔗eth-hooks at: https://www.npmjs.com/package/eth-hooks

  // The transactor wraps transactions and provides notificiations
  const tx = Transactor(userSigner, gasPrice);

  // 🏗 scaffold-eth is full of handy hooks like this one to get your balance:
  const yourLocalBalance = useBalance(localProvider, address, localProviderPollingTime);

  // Just plug in different 🛰 providers to get your balance on different chains:
  const yourMainnetBalance = useBalance(mainnetProvider, address, mainnetProviderPollingTime);

  // const contractConfig = useContractConfig();

  const contractConfig = { deployedContracts: deployedContracts || {}, externalContracts: externalContracts || {} };

  // Load in your local 📝 contract and read a value from it:
  const readContracts = useContractLoader(localProvider, contractConfig);

  // If you want to make 🔐 write transactions to your contracts, use the userSigner:
  const writeContracts = useContractLoader(userSigner, contractConfig, localChainId);

  // EXTERNAL CONTRACT EXAMPLE:
  //
  // If you want to bring in the mainnet DAI contract it would look like:
  const mainnetContracts = useContractLoader(mainnetProvider, contractConfig);

  // If you want to call a function on a new block
  // useOnBlock(mainnetProvider, () => {
  //   console.log(`⛓ A new mainnet block is here: ${mainnetProvider._lastBlockNumber}`);
  // });

  // keep track of a variable from the contract in the local React state:
  let seedsSup = useContractReader(readContracts, "Seeds", "totalSupply",[], localProviderPollingTime)
  console.log("Seedsup: ",seedsSup);

  //const harvestorFactory = useContractReader(readContracts, "Harvest0rFactory", localProviderPollingTime)
  /*
  const addressFromENS = useResolveName(mainnetProvider, "austingriffith.eth");
  console.log("🏷 Resolved austingriffith.eth as:", addressFromENS)
  */
  const balance = useContractReader(readContracts, "Seeds", "balanceOf", [address]);
  const totalSupplyBig = useContractReader(readContracts, "Seeds", "totalSupply", [], localProviderPollingTime);
  
  const totalSupply = (totalSupplyBig && totalSupplyBig.toNumber && totalSupplyBig.toNumber());
  console.log("🤗 totalSupply:", totalSupply);
  const yourBalance = balance && balance.toNumber && balance.toNumber();
  console.log("Your balance: ", yourBalance);

  const [seedsCollectibles, setSeedsCollectibles] = useState();
  const [value, setValue] = useState();
  const mintprice = ethers.utils.parseEther("0.069");

  useEffect(() => {
    console.log("INSIDE USE EFFECT ---------------->")
    const updateSeedsCollectibles = async () => {
      const collectibleUpdate = [];
      for (let tokenIndex = 0; tokenIndex < totalSupply; tokenIndex++) {
        try {
          console.log("Getting token index", tokenIndex);
          //const tokenId = await readContracts.Worlds.tokenOfOwnerByIndex(address, tokenIndex);
          //const testId = tokenId && balance.toNumber && balance.toNumber();
          console.log("tokenId", tokenIndex);
          const tokenURI = await readContracts.Seeds.tokenURI(tokenIndex.toString());
          console.log(tokenURI);
          const tokenOwner = await readContracts.Seeds.ownerOf(tokenIndex);
          console.log("Owner of token: "+tokenOwner);
          const jsonManifestString = atob(tokenURI.substring(29))
          console.log("jsonManifestString", jsonManifestString);
/*
          const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");
          console.log("ipfsHash", ipfsHash);
          const jsonManifestBuffer = await getFromIPFS(ipfsHash);
        */
          try {
            const jsonManifest = JSON.parse(jsonManifestString);
            console.log("jsonManifest", jsonManifest);
            collectibleUpdate.push({ id: tokenIndex, uri: tokenURI, owner: tokenOwner, ...jsonManifest });
            console.log({id: tokenIndex, uri: tokenURI, owner: tokenOwner, ...jsonManifest});
          } catch (e) {
            console.log(e);
          }

        } catch (e) {
          console.log(e);
        }
      }
      setSeedsCollectibles(collectibleUpdate.reverse());
    };
    updateSeedsCollectibles();
  }, [address, yourBalance]); 

  const [toAddress, setToAddress] = useState();
  const [harvestorAddress, setHarvestorAddress] = useState();

  const updateHarvestor = async (target) => {
    let addr;
      try {
        addr = await readContracts.Harvest0rFactory.findHarvestor(target);
      } catch (e) {
        console.log(e);
      }
    setHarvestorAddress(addr);
  };
  //
  // 🧫 DEBUG 👨🏻‍🔬
  //
  useEffect(() => {
    if (
      DEBUG &&
      mainnetProvider &&
      address &&
      selectedChainId &&
      yourLocalBalance &&
      yourMainnetBalance &&
      readContracts &&
      writeContracts &&
      mainnetContracts
    ) {
      console.log("_____________________________________ 🏗 scaffold-eth _____________________________________");
      console.log("🌎 mainnetProvider", mainnetProvider);
      console.log("🏠 localChainId", localChainId);
      console.log("👩‍💼 selected address:", address);
      console.log("🕵🏻‍♂️ selectedChainId:", selectedChainId);
      console.log("💵 yourLocalBalance", yourLocalBalance ? ethers.utils.formatEther(yourLocalBalance) : "...");
      console.log("💵 yourMainnetBalance", yourMainnetBalance ? ethers.utils.formatEther(yourMainnetBalance) : "...");
      console.log("📝 readContracts", readContracts);
      console.log("🔐 writeContracts", writeContracts);
    }
  }, [
    mainnetProvider,
    address,
    selectedChainId,
    yourLocalBalance,
    yourMainnetBalance,
    readContracts,
    writeContracts,
    mainnetContracts,
    localChainId
  ]);

  const loadWeb3Modal = useCallback(async () => {
    //const provider = await web3Modal.connect();
    const provider = await web3Modal.requestProvider();
    setInjectedProvider(new ethers.providers.Web3Provider(provider));

    provider.on("chainChanged", chainId => {
      console.log(`chain changed to ${chainId}! updating providers`);
      setInjectedProvider(new ethers.providers.Web3Provider(provider));
    });

    provider.on("accountsChanged", () => {
      console.log(`account changed!`);
      setInjectedProvider(new ethers.providers.Web3Provider(provider));
    });

    // Subscribe to session disconnection
    provider.on("disconnect", (code, reason) => {
      console.log(code, reason);
      logoutOfWeb3Modal();
    });
    // eslint-disable-next-line
  }, [setInjectedProvider]);

  useEffect(() => {
    if (web3Modal.cachedProvider) {
      loadWeb3Modal();
    }
    //automatically connect if it is a safe app
    const checkSafeApp = async () => {
      if (await web3Modal.isSafeApp()) {
        loadWeb3Modal();
      }
    };
    checkSafeApp();
  }, [loadWeb3Modal]);

  const faucetAvailable = localProvider && localProvider.connection && targetNetwork.name.indexOf("local") !== -1;

  return (
    <div className="App">
      {/* ✏️ Edit the header and change the title to your project name */}
      <Header>
        {/* 👨‍💼 Your account is in the top right with a wallet at connect options */}
        <div style={{ position: "relative", display: "flex", flexDirection: "column" }}>
          <div style={{ display: "flex", flex: 1 }}>
            {USE_NETWORK_SELECTOR && (
              <div style={{ marginRight: 20 }}>
                <NetworkSwitch
                  networkOptions={networkOptions}
                  selectedNetwork={selectedNetwork}
                  setSelectedNetwork={setSelectedNetwork}
                />
              </div>
            )}
            <Account
              useBurner={USE_BURNER_WALLET}
              address={address}
              localProvider={localProvider}
              userSigner={userSigner}
              mainnetProvider={mainnetProvider}
              price={price}
              web3Modal={web3Modal}
              loadWeb3Modal={loadWeb3Modal}
              logoutOfWeb3Modal={logoutOfWeb3Modal}
              blockExplorer={blockExplorer}
            />
          </div>
        </div>
      </Header>
      {yourLocalBalance.lte(ethers.BigNumber.from("0")) && (
        <FaucetHint localProvider={localProvider} targetNetwork={targetNetwork} address={address} />
      )}
      <NetworkDisplay
        NETWORKCHECK={NETWORKCHECK}
        localChainId={localChainId}
        selectedChainId={selectedChainId}
        targetNetwork={targetNetwork}
        logoutOfWeb3Modal={logoutOfWeb3Modal}
        USE_NETWORK_SELECTOR={USE_NETWORK_SELECTOR}
      />
      <Menu style={{ textAlign: "center", marginTop: 20 }} selectedKeys={[location.pathname]} mode="horizontal">
        <Menu.Item key="/seeds">
          <Link to="/seeds">Seeds Access Voucher NFTs</Link>
        </Menu.Item>
        <Menu.Item key="/harvestorFactory">
          <Link to="/harvestorFactory">Factory</Link>
        </Menu.Item>
        <Menu.Item key="/harvestor">
          <Link to="/harvestor">Harvest0r</Link>
        </Menu.Item>
        <Menu.Item key="/debug">
          <Link to="/debug">Debug</Link>
        </Menu.Item>
      </Menu>

      <Switch>
         <Route exact path="/">
          {/* pass in any web3 props to this Home component. For example, yourLocalBalance */}
          <h1>Harvest0rs</h1>
          <p><em>Disclaimer: Always consult a tax professional with regards to tax matters. The below info is for entertainment purposes.</em></p>
          <p>Did your moonshot token turn into an infinite regret jpg? 😭</p>
          <p>Degens are gonna degen, but the tax bill comes due every year.</p>
          <p>Times are tough, and maybe you can save some money on taxes through tax-loss harvesting.</p>
          <p>But why look for someone to buy your defunct token? If I needed a friend for every worthless token clogging my wallets... well, then I would need a lot more friends! 😅</p>
          <p>The solution is simple: deploy or find the right harvest0r and sell your tokens to it.</p>
          <p>Go to the <Link to="/seeds">Seeds Access Voucher</Link> page to get your access voucher NFT and become a Harvest000r 🚜 🚜 🚜</p>
        </Route>
        <Route exact path="/debug">
          {/*
                🎛 this scaffolding is full of commonly used components
                this <Contract/> component will automatically parse your ABI
                and give you a form to interact with it locally
            */}
          <Contract 
            name="Seeds"
            price={price}
            signer={userSigner}
            provider={localProvider}
            address={address}
            blockExplorer={blockExplorer}
            contractConfig={contractConfig}
          />
          <Contract
            name="Harvest0r"
            price={price}
            signer={userSigner}
            provider={localProvider}
            address={address}
            blockExplorer={blockExplorer}
            contractConfig={contractConfig}
          />
          <Contract
            name="Harvest0rFactory"
            price={price}
            signer={userSigner}
            provider={localProvider}
            address={address}
            blockExplorer={blockExplorer}
            contractConfig={contractConfig}
          />
        </Route>
        <Route exact path="/seeds">
						<div class="wrapper">
							<div class="inner" data-onvisible-trigger="1">
								<h1>Harvestors</h1>
                <h1>🚜 🚜 🚜</h1>
								<p><h2>The flow to use a `Harvest0r` is:</h2></p>
                    <p><strong>Step 1: </strong>Obtain a `Seeds Access Voucher` NFT</p>
                    <p><strong>Step 2: </strong>Navigate to the `Harvest0rFactory` and either deploy a `Harvest0r` for the token you want to harvest, or find the `Harvest0r` address if already deployed.</p>
                    <p><strong>Step 3: </strong>Access the `sellToken` functionality of the `Harvest0r`-token pair. You will receive a constant `0.0069 ether` per sale. This consumes one charge of the `SEEDS` NFT.</p>
                    <p><strong>Step 4: </strong>Should the charges become depleted you can replenish the NFT's charges by calling `recharge` on the `SEEDS` NFT contract, this costs `0.069 ether` for 9 charges.</p>
                    <br></br>
                  <p><em>Harvest0r project is a portfolio project by @lourenslinde.</em></p>
                  <br></br>
                  <em>The NFT uses a gas efficient implementation of ERC721A from Chiru Labs.</em>
                    <br></br>
                    <p><strong>Proudly developed with Scaffold-Eth</strong></p>
                  <p><span class="p"><strong><a href="https://goerli.etherscan.io/address/0x833Aefa8d2fb594669095256bCD9f98A09897B84#code">Seeds Contract Address</a></strong></span></p>
                  <p><span class="p"><strong><a href="https://goerli.etherscan.io/address/0x28905e2424C1c364df9a036275387cb77A4D4F3b#code">Harvst0r Factory Contract Address</a></strong></span></p>
							</div>
						</div>
					<hr id="divider05" class="style1 full screen"></hr>
          <div id="container03" data-scroll-id="two" data-scroll-behavior="center" data-scroll-offset="0" data-scroll-invisible="1" class="style1 container default">
						<div class="wrapper">
							<div class="inner" data-onvisible-trigger="1">
								<h3 id="text13" class="style7">Mint Your Own</h3>
								<p id="text14" class="style1">The Harvest0rs live on the Ethereum blockchain.</p>
                <p class="style1"><em>Please refresh your browser after a few minutes to reveal your Seeds NFT</em></p>
                </div>
						</div>
					</div>
          <div><p textAlign="center">🚜🚜🚜</p></div>
						<div class="wrapper">
							<div class="inner" data-onvisible-trigger="1">
                  {userSigner?(
                    <div>
                    <p><InputNumber
                    min={1}
                    max={5}
                    onChange={value => {
                      setValue(value);
                    }}/></p><p>
                    <p>
                <Button type={"primary"} onClick={()=>{
                  tx( writeContracts.Seeds.mint(value, { value: (mintprice*value).toString()}))
                }}>MINT FOR 0.069 E</Button></p></p></div>
              ):(
                <Button type={"primary"} onClick={loadWeb3Modal}>CONNECT WALLET</Button>
              )}
							</div>
					</div>
				
					<hr id="divider04" class="style1 full screen"></hr>
          <div id="container02" data-scroll-id="one" data-scroll-behavior="center" data-scroll-offset="0" data-scroll-invisible="1" class="style1 container default">
						<div class="wrapper">
							<div class="inner" data-onvisible-trigger="1">
								<h3 id="text04" class="style7">All Minted Seeds Vouchers</h3>
                <List
                grid={{ gutter: 16, column: 3 }}
                bordered
                dataSource={seedsCollectibles}
                renderItem={item => {
                  const id = item.id;
                  const tokenId = item.tokenId;

                  console.log("IMAGE",item.image)
                  console.log("Data", tokenId)
                  //<a href={"https://opensea.io/assets/"+(readContracts && readContracts.Seeds && readContracts.Seeds.address)+"/"+item.id} target="_blank">

                  return (
                    <List.Item key={id + "_" + item.uri + "_" + item.owner}>
                      <Card
                        title={
                          <div>
                            <span style={{ fontSize: 18, marginRight: 8 }}>{item.name}</span>
                          </div>
                        }
                      >
                        <a href={"https://opensea.io/assets/"+(readContracts && readContracts.Seeds && readContracts.Seeds.address)+"/"+item.id} target="_blank">
                        <img src={item.image} />
                        </a>
                        <div>
                        </div>
                        <p><em>Seeds Access Voucher NFT</em></p>
                      </Card>

                      
                    </List.Item>
                  );
                }}
              />
							</div>
						</div>
					</div>
					<hr id="divider03" class="style1 full screen"></hr>
					<p id="text05" class="style3">© lourens.eth 2023. All rights reserved.</p>         
        </Route>
        <Route path="/harvestorFactory">
        <Contract
            name="Harvest0rFactory"
            show={["findHarvestor", "isHarvestor", "newHarvestor"]}
            price={price}
            signer={userSigner}
            provider={localProvider}
            address={address}
            blockExplorer={blockExplorer}
            contractConfig={contractConfig}
          />
        </Route>
        <Route path="/harvestor">
          <br></br><Row><Card style={{ width: 300}}></Card>
          <Card title="Enter the Address of the token you want to harvest" style={{ width: 500 }} class=".mx-auto">
            <p><AddressInput
                autoFocus
                ensProvider={mainnetProvider}
                placeholder="Enter address"
                value={toAddress}
                onChange={setToAddress}>
            </AddressInput></p>
            <p><Button type={"primary"} onClick={()=>{
              updateHarvestor(toAddress);
                }}>Load Harvest0r</Button></p>
                <p><Address value={harvestorAddress}></Address></p>
          </Card></Row>
          {/*
            <Contract
              name="UNI"
              customContract={mainnetContracts && mainnetContracts.contracts && mainnetContracts.contracts.UNI}
              signer={userSigner}
              provider={mainnetProvider}
              address={address}
              blockExplorer="https://etherscan.io/"
            />
            */}
            <br></br>
            <hr></hr>
            { harvestorAddress != ZERO_ADDRESS ? (
        <Contract             
            name="Harvest0r"
            show={["sellToken"]}
            price={price}
            signer={userSigner}
            provider={localProvider}
            address={harvestorAddress}
            blockExplorer={blockExplorer}
            contractConfig={contractConfig}></Contract>
            ) : (
              <div>
                <p>It seems that no Harvest0r has been deployed for this token address.</p>
                <p>Want to try deploying a Harvest0r for this token?</p>
                <p>You can do this <Link to="/harvest0rFactory">here</Link></p>
              </div>
            
            ) }

        </Route>
        <Route path="/subgraph">
          <Subgraph
            subgraphUri={props.subgraphUri}
            tx={tx}
            writeContracts={writeContracts}
            mainnetProvider={mainnetProvider}
          />
        </Route>
      </Switch>

      <ThemeSwitch />

      {/* 🗺 Extra UI like gas price, eth price, faucet, and support: */}
      <div style={{ position: "fixed", textAlign: "left", left: 0, bottom: 20, padding: 10 }}>
        <Row align="middle" gutter={[4, 4]}>
          <Col span={8}>
            <Ramp price={price} address={address} networks={NETWORKS} />
          </Col>

          <Col span={8} style={{ textAlign: "center", opacity: 0.8 }}>
            <GasGauge gasPrice={gasPrice} />
          </Col>
          <Col span={8} style={{ textAlign: "center", opacity: 1 }}>
            <Button
              onClick={() => {
                window.open("https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA");
              }}
              size="large"
              shape="round"
            >
              <span style={{ marginRight: 8 }} role="img" aria-label="support">
                💬
              </span>
              Support
            </Button>
          </Col>
        </Row>

        <Row align="middle" gutter={[4, 4]}>
          <Col span={24}>
            {
              /*  if the local provider has a signer, let's show the faucet:  */
              faucetAvailable ? (
                <Faucet localProvider={localProvider} price={price} ensProvider={mainnetProvider} />
              ) : (
                ""
              )
            }
          </Col>
        </Row>
      </div>
    </div>
  );
}

export default App;
