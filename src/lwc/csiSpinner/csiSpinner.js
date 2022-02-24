import { LightningElement, api, track } from 'lwc';

export default class CsiSpinner extends LightningElement {
  @track displaySpinner = false;
  @api delay = 300;
  
  // Overall goal of spinner is to give the user this visual, and make sure they see it. Also preventing double-clicks on buttons.
  // You don't want them clicking on a refresh button and having the spinner code operate so fast that they see nothing.
  
  /* 
    
    // == Spinner HTML How-To ==
      
      // Begin ADD TO HTML
      //==========================================
      // HTML Setup (typical - single spinner): 

          // <div class="slds-is-relative">
          //   <c-csi-spinner></c-csi-spinner>
          // </div>

      // HTML Setup (multiple spinners): 
      
          // <div class="slds-is-relative">
          //   <c-csi-spinner class="form-spinner"></c-csi-spinner>
          //   <div class="slds-is-relative">
          //     <c-csi-spinner class="inner-form-spinner"></c-csi-spinner>
          //   </div>
          // </div>

      //==========================================
      // End ADD TO HTML
      
    


    // == Spinner JS How-To ==
    
      // Begin ADD TO JS
      //==========================================
      
      // CSI Spinner Methods and How-To
      // ----------------------------------
      //  1. this.showSpinner();
      //      OR this.showSpinner(".inner-form-spinner");

      //  2. do logic

      //  3. this.hideSpinner(300); //300 milliseconds
      //      OR this.hideSpinner(300, ".inner-form-spinner");

      getSpinner(selector) { 
          selector = !selector ? 'c-csi-spinner' : selector;
          return this.template.querySelector(selector);
      }
      showSpinner(selector){    
          let spinner = this.getSpinner(selector);
          if (spinner) spinner.showSpinner();
      }
      hideSpinner(len, selector){
          let spinner = this.getSpinner(selector);
          if (spinner) spinner.hideSpinner(len);
      }
      
      //==========================================
      // END ADD TO JS      



    // Begin EXAMPLES
    //==========================================
      @wire(someWireMethod)
    	wiredTableData(response){
        // Wired methods will fire before the spinner component is on screen sometimes
        this.showSpinner();

        Logic code

        this.hideSpinner(300);
      }

      someButtonFunction(){

        this.showSpinner();

        someImperativeApexMethod()
          then(result => {
            this.hideSpinner(300);
          })
          .catch(error => {
            this.hideSpinner(300);
          });
      }

      refreshButton() {
        this.spinner.showSpinnerDelayHide(600); <-- great for before calling refreshApex
        refreshApex(this.wiredMethodResponseBackup);
      }

      //==========================================
      // End EXAMPLES
      
  */

	@api showSpinnerDelayHide(delay){
    this.displaySpinner = true;
    this.hideSpinner(delay);

    // Use Cases:
    // Just before calling refreshApex()
  }

  @api showSpinner(){
    this.displaySpinner = true;

    // Use Cases:
      // Any function where you know where the end of execution will be
      // Inside wire method, at the top
      // Synchronous code
  }

  @api hideSpinner(delay){
    if (delay == null){
      delay = this.delay;
    }

    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.displaySpinner = false;
    }, delay);

    // Always hide with a delay like the default of 300.
      // Don't forget to put this in your }).catch(error => {} blocks
      // Don't forget: Always show a toast message at the end of your button clicks.
  }

}