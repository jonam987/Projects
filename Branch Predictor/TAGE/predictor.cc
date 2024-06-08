/* Author: Team-7 (Manoj and Gnanesh);   
 * Description: This file defines the two required functions for the branch predictor.
*/

#include "predictor.h"
#include <vector>
//#define DEBUG
#define pc_mask ((1<<12)-1)<<2
#define index_mask ((1<<9)-1)
#define tag_mask ((1<<7)-1)

typedef struct {
    int pred = 5;
    int tag = -1;
}Tagged_Predictor;


std::vector<int> bp(4096,5);    //Base Prediction Table
Tagged_Predictor T1[512],T2[512],T3[512],T4[512];    //Tagged Prediction Tables
int main_tag;
int i1,i2,i3,i4;
long long int gh = 0;                     //Global History of 36 bits
int base_index;                    //Base Table Index
bool base_prediction;          //Base Prediction 
bool final_pred,pred;           //Prediction variables
short int tag_pred;         //Tag Prediction indicator

    bool PREDICTOR::get_prediction(const branch_record_c* br, const op_state_c* os)
        {
		/* replace this code with your own */
            bool prediction = true;
            //printf("%0x %0x %1d %1d %1d %1d ",br->instruction_addr,
			  //                              br->branch_target,br->is_indirect,br->is_conditional,
				//							br->is_call,br->is_return);

            int g1;
            int g2;
            int g3;
            int g4;

            tag_pred =0;

            g1 = gh & (0x1FF);
            g2 = (gh>>9) & (0x1FF);
            g3 = (gh>>18) & (0x1FF);
            g4 = (gh>>27) & (0x1FF);

            base_index = (br->instruction_addr & pc_mask)>>2;
            base_prediction = ((1<<2) & bp[base_index])>>2;
            i1 = (br->instruction_addr ^ g1) & index_mask;
            i2 = (br->instruction_addr ^ g1 ^ g2) & index_mask;
            i3 = (br->instruction_addr ^ g1 ^ g2 ^ g3) & index_mask;
            i4 = (br->instruction_addr ^ g1 ^ g2 ^ g3 ^ g4) & index_mask;
            main_tag = (br->instruction_addr ^ gh) & 0x7F;

            if (br->is_conditional)
            {
                if(T1[i1].tag == main_tag)
                {   
                    final_pred = ((1<<2) & T1[i1].pred)>>2; 
                    tag_pred =1;
                }
                if(T2[i2].tag == main_tag)
                {
                    final_pred = ((1<<2) & T2[i2].pred)>>2; 
                    tag_pred =2;
                } 
                if(T3[i3].tag == main_tag)
                {
                    final_pred = ((1<<2) & T3[i3].pred)>>2;    
                    tag_pred =3;  
                }
                if(T4[i4].tag == main_tag)
                {
                    final_pred = ((1<<2) & T4[i4].pred)>>2; 
                    tag_pred =4;
                }                                  
                
                if(tag_pred)
                    pred = final_pred;
                else
                    pred = base_prediction;  
                
                prediction = pred;
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
            int g1;
            int g2;
            int g3;
            int g4;

            g1 = gh & (0x1FF);
            g2 = (gh>>9) & (0x1FF);
            g3 = (gh>>18) & (0x1FF);
            g4 = (gh>>27) & (0x1FF);

            base_index = (br->instruction_addr & pc_mask)>>2;
            base_prediction = ((1<<2) & bp[base_index])>>2;
            i1 = (br->instruction_addr ^ g1) & index_mask;
            i2 = (br->instruction_addr ^ g1 ^ g2) & index_mask;
            i3 = (br->instruction_addr ^ g1 ^ g2 ^ g3) & index_mask;
            i4 = (br->instruction_addr ^ g1 ^ g2 ^ g3 ^ g4) & index_mask;
            main_tag = (br->instruction_addr ^ gh) & 0x7F;

            if(br->is_conditional)
            { 
                if(taken)
                {
                    if(tag_pred!=0 && bp[base_index]!=7)
                    {
                        bp[base_index]++;
                    }
                    if(T1[i1].tag == main_tag && T1[i1].pred !=7)
                    {   
                        T1[i1].pred++;
                    }
                        
                    if(T2[i2].tag == main_tag && T2[i2].pred !=7)
                    {   
                        T2[i2].pred++;
                    }
                    if(T3[i3].tag == main_tag && T3[i3].pred !=7)
                    {   
                        T3[i3].pred++;
                    }
                    if(T4[i4].tag == main_tag && T4[i4].pred !=7)
                    {   
                        T4[i4].pred++;
                    }
                }

                else
                {

                    if(bp[base_index]!=0)
                    {
                        bp[base_index]--;
                    }
                    if(T1[i1].tag == main_tag && T1[i1].pred !=0)
                    {   
                        T1[i1].pred--;
                    }
                        
                    if(T2[i2].tag == main_tag && T2[i2].pred !=0)
                    {   
                        T2[i2].pred--;
                    }
                    if(T3[i3].tag == main_tag && T3[i3].pred !=0)
                    {   
                        T3[i3].pred--;
                    }
                    if(T4[i4].tag == main_tag && T4[i4].pred !=0)
                    {   
                        T4[i4].pred--;
                    }
                }

                

                if(pred != taken)
                {                    
                    T1[i1].tag = main_tag;
                    T2[i2].tag = main_tag;                    
                    T3[i3].tag = main_tag;                    
                    T4[i4].tag = main_tag;
                }

                if(T1[i1].tag == -1)
                {
                    T1[i1].tag = main_tag;
                }

                if(T2[i2].tag == -1)
                {
                    T2[i2].tag = main_tag;
                }

                if(T3[i3].tag == -1)
                {
                    T3[i3].tag = main_tag;
                }

                if(T4[i4].tag == -1)
                {
                    T4[i4].tag = main_tag;
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
