/* Author: Team-7 (Manoj and Gnanesh);   
 * Description: This file defines the two required functions for the branch predictor.
*/

#include "predictor.h"
#include <vector>
//#define DEBUG
#define pc_mask ((1<<13)-1)<<2


std::vector<int> bp(8192,5);    //Prediction Table
short int ind;                   //index
int gh = 0;                     //Global History of 13 bits
    
    bool PREDICTOR::get_prediction(const branch_record_c* br, const op_state_c* os)
        {
		/* replace this code with your own */
            bool prediction = true;
            //printf("%0x %0x %1d %1d %1d %1d ",br->instruction_addr,
			  //                              br->branch_target,br->is_indirect,br->is_conditional,
				//							br->is_call,br->is_return);

            ind = ((br->instruction_addr & pc_mask)>>2) ^ (gh & 0x1FFF);

            if (br->is_conditional)
            {
                prediction = (1<<2 & bp[ind])>>2;
            }
            
            if(br->is_conditional)
            { 
            #ifdef DEBUG
            printf("\nPrediction:\n");
            printf("PC= %0x is_cond=%1d bp=%0x main_tag=%0d T1.tag=%0x T1.pred=%0d T2.tag=%0x T2.pred=%0d T3.tag=%0x T3.pred=%0d T4.tag=%0x T4.pred=%0d ",br->instruction_addr,br->is_conditional,base_prediction,main_tag,T1[i1].tag,T1[i1].pred, T2[i2].tag,
                                                                                                                        T2[i2].pred,T3[i3].tag, T3[i3].pred, T4[i4].tag, T4[i4].pred);
            #endif                                                           
            }
            return prediction;   // true for taken, false for not taken
        }


    // Update the predictor after a prediction has been made.  This should accept
    // the branch record (br) and architectural state (os), as well as a third
    // argument (taken) indicating whether or not the branch was taken.
    void PREDICTOR::update_predictor(const branch_record_c* br, const op_state_c* os, bool taken)
        {
		/* replace this code with your own */
            ind = ((br->instruction_addr & pc_mask)>>2) ^ (gh & 0x1FFF);

            if(br->is_conditional)
            { 
                if(taken)
                {
                    if(bp[ind]!=7)
                        bp[ind]++;
                }

                else
                {
                    if(bp[ind]!=0)
                        bp[ind]--;
                }

                if(br->is_conditional){ 
                #ifdef DEBUG
                printf("\nUpdation:\n");
                printf("PC= %0x is_cond=%1d bp=%0x main_tag=%0d T1.tag=%0x T1.pred=%0d T2.tag=%0x T2.pred=%0d T3.tag=%0x T3.pred=%0d T4.tag=%0x T4.pred=%0d \n",br->instruction_addr,br->is_conditional,base_prediction,main_tag,T1[i1].tag,T1[i1].pred, T2[i2].tag,
                                                                                                                        T2[i2].pred,T3[i3].tag, T3[i3].pred, T4[i4].tag, T4[i4].pred);
                #endif
                }
            }
            
            gh = gh<<1 | taken;
            
            #ifdef DEBUG    
            //printf("lp_ind=%0x g_ind=%0x outcome=%1d\n",lp_ind,g_ind,taken);
            #endif
            
			//printf("%1d\n",taken);

        }
