<template>
  <b-container class="mb-5">
    <b-row class="header-row">
      <b-col>
        <h1>Puzzler</h1>
        <img :src="spiro2">
      </b-col>
    </b-row>

    <b-row>
      <b-col class="action-container">
        <h4>
          {{ questions[level].question }}
        </h4>

<!-- 6210001000 -->
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
          v-on:click="createSpiro" type="button">Submit</b-button>
          
          <p>Gas costs apply.</p>
        </b-form>
      </b-col>
    </b-row>

    <hr>
    <h2 class="mb-5">Stats</h2>
    <p><u>Account address</u>: {{ account }} </p>
    <p><u>Contract address</u>: {{ contractAddr }} </p>

    <b-row>
      <b-col>
        <p><b>Level: </b>{{ level }}</p>
      </b-col>
      <b-col>
        <p><b>Spiro: </b> {{ spiro }} </p>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <p><b>SpiroID on sale: </b> <ul> <li v-for ="i in spirosOnSale"> {{ i }} </li> </ul> </p>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <p><b>Number of spiros generated so far: </b> <ul> <li v-for ="i in allSpiros"> {{ i }} </li> </ul> </p>
      </b-col>
    </b-row>
    <hr>
  <b-row>
    <b-col class="action-container">
    <b-form>
        <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <b-form-group v-if="!isLoading">
          <p>Enter Spiro ID to buy:</p>
            <b-form-input id="spiroIdToBuy"
                          v-model="spiroIdToBuy"
                          required
                          placeholder="Spiro ID">
            </b-form-input>
          </b-form-group>
          
      
          <b-button 
          v-if="!isLoading"
          v-on:click="buyNew" type="button">Submit</b-button>
          
          <p>Cost for each Spiro (S) = (S.level * 0.005) ether </p>
        </b-form>
    </b-col>
    </b-row>
    <!-- <p>
    <ul >
      <li v-for="item in allSpiros"> {{ item }} </li>
    </ul>
    </p> -->
    <!-- <b-row v-for="i in Math.ceil(allSpiros.length / 3)" v-bind:key="i"> -->
      <!-- <b-col cols="4" v-for="item in allSpiros.slice((i - 1) * 3, i * 3)" -->
             <!-- v-bind:item="item" -->
             <!-- v-bind:key="item.id"> -->
        <!-- <b-card style="height:400px;" class="mb-2"> -->
          <!-- <b-img thumbnail fluid :src="item.url" class="image"/> -->
          <!-- <p class="card-text mt-2 text-center"> -->
            <!-- <b>level:</b> {{ item.level }} -->
            <!-- <br> -->
            <!-- <b>Creator:</b> {{ item.creator }} -->
            <!-- <span v-if="item.matron == 0 && item.sire == 0">Bought</span> -->
            <!-- <span v-else>{{ item.matron }} & {{ item.sire }}</span> -->
          <!-- </p> -->
        <!-- </b-card> -->
      <!-- </b-col> -->
    <!-- </b-row> -->
  </b-container>
</template>

<script>
import allQuestions from './components/questions.json';
import getWeb3 from '../contracts/web3';
import contractAbi from '../contracts/abi';


// import Viper1 from './assets/Viper/1.png';
// import Viper2 from './assets/Viper/2.png';
// import Viper3 from './assets/Viper/3.png';
// import Viper4 from './assets/Viper/4.png';
// import Viper5 from './assets/Viper/5.png';
// import Viper6 from './assets/Viper/6.png';
// import ViperX from './assets/Viper/unknown.png';

//puzzlerContract
const contractAddress = '0xb572e8d58b214455e6aff3aee9e0e8f55a102354';


// const vipersMap = [null, Viper1, Viper2, Viper3, Viper4, Viper5, Viper6];

export default {
  name: 'App',
  data() {
    return {
      web3: null,
      account: null,
      contractInstance: null,
      contractAddr: contractAddress,
      level: 1,
      spiro: null,
      spirosOnSale: [],
      allSpiros: [],
      contractBalance: null,
      isLoading: false,
      questions: allQuestions
      
    };
  },
  mounted() {
    getWeb3().then((res) => {
      this.web3 = res;
      this.contractInstance = new this.web3.eth.Contract(contractAbi, contractAddress);
      this.web3.eth.getAccounts().then((accounts) => {
        // [this.account] = accounts;
        this.account = accounts[0];
        this.getSpiro();
      }).catch((err) => {
        console.log(err, 'err!!');
      });
    });
  },

  methods: {
    
    createSpiro () {
      if (matron.value == this.questions[this.level].answer) {
      this.isLoading = true;
      this.contractInstance.methods.createSpiro(this.level).send({
        from: this.account
      }).then((receipt) => {
        this.addSpiroFromReceipt(receipt);
        this.level ++;
        this.isLoading = false;
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      })
      }else {
        console.log("matron value");
        console.log(matron.value);
        console.log ("answer is");
        console.log (this.questions[this.level].answer);
        alert ("This isn't the right answer");
      }
    }, 
    buyNew () {
      let amt = this.level * 0.005;
      // this.isLoading = true;
      console.log(this.spiroIdToBuy);
      console.log(typeof(this.spiroIdToBuy));

      this.contractInstance.methods.buyNewSpiro(this.spiroIdToBuy).send({
        from: this.account,
        value: web3.toWei(amt, 'ether')
      }).then((receipt) => {
        this.addSpiroFromReceipt(receipt);
        this.level = 1;
        this.isLoading = false;
      }).catch((err) => {
        console.log (err);
        this.isLoading = false;
      })
    },

    // buyViper() {
    //   this.isLoading = true;
    //   this.contractInstance.methods.buyViper().send({
    //     from: this.account,
    //     value: web3.toWei(0.02, 'ether'),
    //   }).then((receipt) => {
    //     this.addViperFromReceipt(receipt);
    //     this.isLoading = false;
    //   }).catch((err) => {
    //     console.log(err, 'err');
    //     this.isLoading = false;
    //   });
    // },

    // breedVipers() {
    //   this.isLoading = true;
    //   console.log(this.matron);
    //   this.contractInstance.methods.breedVipers(this.matron, this.sire).send({
    //     from: this.account,
    //     value: web3.toWei(0.05, 'ether'),
    //   }).then((receipt) => {
    //     this.addViperFromReceipt(receipt);
    //     this.isLoading = false;
    //   }).catch((err) => {
    //     console.log(err, 'err');
    //     this.isLoading = false;
    //   });
    // },
    getSpiro() {
      this.isLoading = true;
      this.contractInstance.methods.ownerToSpiro(this.account).call({
        from:this.account
      }).then((receipt) => {
        this.spiro = receipt;
        this.isLoading = false;
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      });
    },
    // getVipers() {
    //   this.isLoading = true;
    //   this.contractInstance.methods.ownedVipers().call({
    //     from: this.account,
    //   }).then((receipt) => {
    //     for (let i = 0; i < receipt.length; i += 1) {
    //       this.contractInstance.methods.getViperDetails(receipt[i]).call({
    //         from: this.account,
    //       }).then((viper) => {
    //         this.vipers.push({
    //           id: viper[0],
    //           genes: viper[1],
    //           matron: viper[2],
    //           sire: viper[3],
    //           url: vipersMap[viper[1]],
    //         });
    //       }).catch((err) => {
    //         console.log(err, 'err');
    //       });
    //     }
    //     this.isLoading = false;
    //   }).catch((err) => {
    //     console.log(err, 'err');
    //     this.isLoading = false;
    //   });
    // },

    addSpiroFromReceipt(receipt) {
      console.log("---");
      console.log(receipt);
      console.log(typeof(receipt));
      this.allSpiros.push({
        // id: receipt.events.newSpiro.returnValues.spiroId,
        level: receipt.events.newSpiro.returnValues.level,
        creator: receipt.events.newSpiro.returnValues.creator,
        // url: spirosMap[receipt.events.newSpiro.returnValues.spiroId]
      });
      console.log(this.allSpiros);
    },

    // addViperFromReceipt(receipt) {
    //   this.vipers.push({
    //     id: receipt.events.Birth.returnValues.viperId,
    //     genes: receipt.events.Birth.returnValues.genes,
    //     matron: receipt.events.Birth.returnValues.matronId,
    //     sire: receipt.events.Birth.returnValues.sireId,
    //     url: vipersMap[receipt.events.Birth.returnValues.genes],
    //   });
    // },

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
