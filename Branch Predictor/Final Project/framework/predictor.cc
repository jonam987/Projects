/* Author: Team-7 (Manoj and Gnanesh);   
 * Description: This file defines the two required functions for the branch predictor.
*/

#include "predictor.h"
#include <vector>
//#define DEBUG
#define lht_mask ((1<<10)-1)<<2
#define gh_mask ((1<<12)-1)

int lht[1024]={ 0 };            //Local History Table
std::vector<int> lp(1024,5);    //Local Prediction Table
std::vector<int> gp(4096,2);    //Global Prediction Table
std::vector<int> cp(4096,1);    //Choice Prediction Table
int gh = 0;                     //Global History of 12 bits
int lht_ind;                    //Local History Table Index
int lp_ind;                     //Local Prediction Table Index
int g_ind;                      //Path History Index
bool local_prediction;          //Local Prediction  
bool global_prediction;         //Global Prediction
bool choice_prediction;         //Choice Prediction

    bool PREDICTOR::get_prediction(const branch_record_c* br, const op_state_c* os)
        {
		/* replace this code with your own */
            bool prediction = true;

			//printf("%0x %0x %1d %1d %1d %1d ",br->instruction_addr,
			  //                              br->branch_target,br->is_indirect,br->is_conditional,
				//							br->is_call,br->is_return);


            lht_ind = (br->instruction_addr & lht_mask)>>2;
            g_ind = gh & gh_mask;
            lp_ind = lht[lht_ind] & ((1<<10)-1);
            local_prediction = ((1<<2) & lp[lp_ind])>>2;
            global_prediction = ((1<<1) & gp[g_ind])>>1;
            choice_prediction = ((1<<1) & cp[g_ind])>>1;
            if (br->is_conditional)
            {
                if(choice_prediction)
                    prediction = global_prediction;
                else
                    prediction = local_prediction;

            }
            
            #ifdef DEBUG
            printf("\nPrediction:\n");
            printf("PC= %0x is_cond=%1d lht_ind=%0x lp=%0d cp=%0d gp=%0d lp_ind=%0x g_ind=%0x pred=%1d",br->instruction_addr,br->is_conditional,
                                                                        lht_ind,lp[lp_ind],cp[g_ind],gp[g_ind],lp_ind,g_ind,prediction);
            #endif                                                           

            return prediction;   // true for taken, false for not taken
        }


    // Update the predictor after a prediction has been made.  This should accept
    // the branch record (br) and architectural state (os), as well as a third
    // argument (taken) indicating whether or not the branch was taken.
    void PREDICTOR::update_predictor(const branch_record_c* br, const op_state_c* os, bool taken)
        {
		/* replace this code with your own */
            lht_ind = (br->instruction_addr & lht_mask)>>2;
            lp_ind = lht[lht_ind] & ((1<<10)-1);
            g_ind = gh & gh_mask;
            local_prediction = ((1<<2) & lp[lp_ind])>>2;
            global_prediction = ((1<<1) & gp[g_ind])>>1;;

            if(br->is_conditional)
            { 
                if(taken)
                {
                    if(lp[lp_ind] == 7)
                        lp[lp_ind] = 7;
                    else
                        lp[lp_ind]++;
                    
                    if(gp[g_ind] == 3)
                        gp[g_ind] = 3;
                    else
                        gp[g_ind]++;
                }
                else
                {
                    if(lp[lp_ind] == 0)
                        lp[lp_ind] = 0;
                    else
                        lp[lp_ind]--;

                    if(gp[g_ind] == 0)
                        gp[g_ind] = 0;
                    else
                        gp[g_ind]--;
                }

                if(local_prediction == global_prediction)
                    cp[g_ind] = cp[g_ind];
                else
                {
                    if(local_prediction == taken)
                        cp[g_ind] == 0? 0 : cp[g_ind]--;
                    else
                        cp[g_ind] == 3? 3 : cp[g_ind]++;
                }
            
                #ifdef DEBUG
                printf("\nUpdation:\n");
                printf("PC= %0x is_cond=%1d lht_ind=%0x lp=%0d cp=%0d gp=%0d ",br->instruction_addr,br->is_conditional,
                                                                        lht_ind,lp[lp_ind],cp[g_ind],gp[g_ind]);
                #endif
                lht[lht_ind] = lht[lht_ind]<<1 | taken;
            }
                gh = gh<<1 | taken;
                lp_ind = lht[lht_ind] & ((1<<10)-1);
                g_ind = gh & gh_mask;
            
            #ifdef DEBUG    
            printf("lp_ind=%0x g_ind=%0x outcome=%1d\n",lp_ind,g_ind,taken);
            #endif
            
			//printf("%1d\n",taken);

        }
