<template>
  <b-container class="mb-5">
    <b-row class="header-row">
      <b-col>
        <h1>Puzzler</h1>
        <img src="./assets/spiro/spiro3.png" class = "unknown-viper">
        <p><b>Connected account</b>: {{ account }}</p>
        <p>You currently own <b>Spiro {{ spiro }}</b> on <b>level {{ level }} </b></p>
      </b-col>
    </b-row>

    <b-row>
      <b-col>
    <b-row>
      <b-col>
        
        <p><b>
          <!-- Spiros owned by the contract (spiroID, level):  -->
          Buy new Spiro to level up:
          <small><p>Spiros with level > your level and currently owned by the contract are displayed.</p></small>
          </b> 

          <!-- <ul> 
            <li v-for ="i in contractSpiros"> {{ i }} </li> 
          </ul>  -->
          <div v-if="contractSpiros.length == 0"> <p> No Spiros available to level up. </p></div>
          <div id = "contractSpiros">
            <b-button v-for="i in contractSpiros" v-bind:item="i[1]" v-bind:key="i[0]"   variant="outline-warning"
            v-on:click="buyNew(i[0])">Level: {{ i[1] }} (spiroID: {{ i[0] }})</b-button>
          </div>
          <span style="color:white;">Buying price for each Spiro (S) = (S.level * 0.005) ether </span>
      </b-col>
    </b-row>
      <!-- <h4 class="mb-5">Stats</h4> -->
    <hr>
    <b-row>
      <b-col>
        <p><b>Total number of questions: </b> {{ questions.length }} </p>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <p><b>Total spiros minted: </b> {{ totalSpiros }} </p>
      </b-col>
    </b-row>
      </b-col>
      <b-col>
      <b-col class="action-container">
        <h4>
          <h6>Level: {{ level }} </h6>
          {{ questions[level].question }}
        </h4>
        <b-form>
          <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <b-form-group v-if="!isLoading"
                    >
            <b-form-input id="matron"
                          v-model="matron"
                          required
                          placeholder="Your answer">
            </b-form-input>
          </b-form-group>
          <b-button 
          v-if="!isLoading"
          variant="primary"
          v-on:click="createSpiro" type="button">Submit</b-button>
          
          <p>Gas costs apply.</p>
        </b-form>
      </b-col>
      <hr>
      <b-row>
    <!-- <b-col class="action-container"> -->
    <!-- <b-form>
        <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <b-form-group v-if="!isLoading">
          <p>Buy to freeze/level up:</p>
            <b-form-input id="spiroIdToBuy"
                          v-model="spiroIdToBuy"
                          required
                          placeholder="Spiro ID"
                          >
            </b-form-input>
          </b-form-group>
          <b-button 
          v-if="!isLoading"
          v-on:click="buyNew" type="button">Submit</b-button>
          
          <p>Cost for each Spiro (S) = (S.level * 0.005) ether </p>
        </b-form> -->
    <!-- </b-col> -->
      <br>
      <br> 
    <b-col class="action-container">
        <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <div v-if="!isLoading">
          <b-button 
          variant="outline-danger"
          v-if="!isLoading"
          v-b-modal.modal-1
          type="button">Sell your Spiro</b-button>
          <b-modal 
            id="modal-1" 
            title="Alert" 
            @ok="sellSpiro(spiro)" 
            ok-variant="danger"
            ok-title="Sell Anyway" 
            size = "sm"
          >
            <p class="my-4" style="color:black;">Selling your spiro resets your level to 0.</p>
          </b-modal>
        </div>
          <span style="color:white;">Selling price for each Spiro (S) = (S.level * 0.005) ether </span>
    </b-col>
    </b-row>
      </b-col>
    </b-row>
    <hr>
    <!-- <center><p>Hosted with &#x1F49B; at: <a href="https://ropsten.etherscan.io/address/0x989da6d8a9358d7de3859cf3a15303e9c673cf55"> {{ contractAddr }} </a> </p></center> -->
    <center><p>Contract address: <a href="https://ropsten.etherscan.io/address/0x989da6d8a9358d7de3859cf3a15303e9c673cf55"> {{ contractAddr }} </a> </p></center>

  </b-container>
</template>

<script>
import allQuestions from './components/questions.json';
import getWeb3 from '../contracts/web3';
// import FlipCard from 'vue-flip-card';
import contractAbi from '../contracts/abi';
//puzzlerContract
const contractAddress = '0x989da6d8a9358d7de3859cf3a15303e9c673cf55';
export default {
  name: 'App',
  data() {
    return {
      web3: null,
      account: null,
      contractInstance: null,
      contractAddr: contractAddress,
      level: 0,
      spiro: 0,
      spirosOnSale: [],
      allSpiros: [],
      contractSpiros: [],
      isLoading: false,
      questions: allQuestions,
      totalSpiros: null,
      openStats: false,
      dummyContractSpiros: null,
    };
  },
  mounted() {
    getWeb3().then((res) => {
      this.web3 = res;
      this.contractInstance = new this.web3.eth.Contract(contractAbi, contractAddress);
      this.web3.eth.getAccounts().then((accounts) => {
        this.account = accounts[0];
        this.getSpiro();
        this.getContractSpiros();
        this.getTotalSpiros();
      }).catch((err) => {
        console.log(err, 'err!!');
      });
    });
  },

  methods: {
    openStats(){
      openStats = true;
    },
    createSpiro () {
      if (matron.value == this.questions[this.level].answer) {
          this.isLoading = true;
          if (this.level == 0) {
          this.level ++;
          this.isLoading = false;
          this.getContractSpiros();
      }
      else {
          this.contractInstance.methods.createSpiro(this.level).send({
          from: this.account
      }).then((receipt) => {
        // this.addSpiroFromReceipt(receipt);
          this.level ++;
          this.isLoading = false;
          this.getContractSpiros();
      }).catch((err) => {
          console.log(err, 'err');
          this.isLoading = false;
      })
      } 
      }else {
        console.log("matron value");
        console.log(matron.value);
        console.log ("answer is");
        console.log (this.questions[this.level].answer);
        alert ("This isn't the right answer");
      }
      
      // this.getContractSpiros();
    }, 
    getTotalSpiros() {
      this.contractInstance.methods.totalSupply().call ({
        from: this.account
      }).then((totalSupply) => {
        console.log("total supply: ", totalSupply);
        this.totalSpiros = totalSupply;
      });
    },
    buyNew (id) {
      let lvl;
      let amt;
      this.isLoading = true;

      this.contractInstance.methods.spiros(id).call({
          from: this.account
        }).then((s) => {
          lvl = s.level;
          amt = lvl * 0.005;
          return amt;
          // console.log("level: ", lvl);
          }).then((amt)=> {
            console.log ("amt", amt);
            this.contractInstance.methods.buyNewSpiro(id).send({
                from: this.account,
                value: web3.toWei(amt, 'ether')
            }).then((receipt) => {
        this.spiro = id;
        this.isLoading = false;
        this.getSpiro();
        this.getContractSpiros();
      }).catch((err) => {
        console.log (err);
        this.isLoading = false;
      });
        })
        
    },

    getSpiro() {
      this.isLoading = true;
      this.contractInstance.methods.ownerToSpiro(this.account).call({
        from:this.account
      }).then((receipt) => {
        this.spiro = receipt;
        // this.level = receipt;
        this.contractInstance.methods.spiros(this.spiro).call({
          from: this.account
        }).then((s) => {
          console.log ("this.spiro = ", this.spiro);
          console.log("setting level to: ", s.level);
          console.log(s);
          this.level = s.level;
        });
        
        this.isLoading = false;
        console.log ("user spiro set to: ", this.spiro);
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      });
    },

    getContractSpiros () {
      this.contractInstance.methods.getSpiros().call({
        from: this.account
      }).then((allSpiros) => {
        this.contractSpiros = [];        
        
        let dCS = [];
        let cS = allSpiros;

        let first, second;

        for (let i = 0; i < cS.length; i++) {
          this.contractInstance.methods.spiros(cS[i]).call ({
            from:this.account 
          }).then((spiro) => {
            if (spiro.level != 0 && spiro.level > this.level) {
              first = cS[i];
              second = spiro.level;
              // cS[i] += ", "  + spiro.level;
              // this.contractSpiros.push(cS[i]);
              this.contractSpiros.push([first, second]);
              dCS.push([first, second]);
            }
          })
        }
      }).catch((err) => {
        console.log (err, 'err');
      });
    },

    sellSpiro (id) {
      if (id != 0) {
      this.isLoading = true;
      this.contractInstance.methods.sellSpiro(id).send({
        from: this.account
      }).then((receipt) => {
        console.log(receipt);
        this.getSpiro();
        this.getContractSpiros();
        this.isLoading = false;
      });
      } else {
        alert ("0th Spiro cannot be sold. Answer questions/ buy new spiros to level up.");
      }
    }
  },
};
</script>

<style lang="css">
@import url('https://fonts.googleapis.com/css?family=Poppins:400,500');

* {
  font-family: 'Poppins', sans-serif;
}
button {
  width: 100%;
}
h1, h2, h3, h4, p {
  color: white;
}
hr { display: block; height: 1px;
    border: 0; border-top: 1px solid #ccc;
    margin: 1em 0; padding: 0; }
 body {
  background-color: rgb(24,24,24);
  /* font-color: white; */
}
#contractSpiros {
  height: 300px;
  overflow-y: auto;
}
.header-row {
  text-align: center;
  margin: 30px 0;
}
.action-container h4 {
  text-align: center;
  margin-bottom: 30px;
}
.action-container p {
  text-align: center;
  margin-top: 10px;
}
.middle-container {
  display: flex;
  justify-content: center;
  align-items: center;
}
.middle-container img {
  height: 100px;
}
.unknown-viper {
  height: 180px;
  width: 180px;
  margin: 9px 0;
}
</style>
