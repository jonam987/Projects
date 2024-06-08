#include<stdio.h>
#include <stdlib.h>
#include<string.h>

#define DEBUG

//defining timing parameters
#define tburst 8
#define trcd 39
#define tras 76
#define trrdl 12
#define trrds 8
#define trtp 18
#define trp 39
#define tcl 40
#define cwl 38
#define twr 30
#define tccdl 12
#define tccds 8
#define tccdlw 48
#define tccdsw 8
#define tccdlrtw 16
#define tccdsrtw 16
#define tccdlwtr 70
#define tccdswtr 52

#define N 16

//bank status struct
struct bank {
	int st;
	int row;
};

//queue
struct q
{	int time;
	int core;
	int op;
	int row;
	int u_col;
	int l_col;
	int col;
	int ba;
	int bg;
	int ch;
	int bnk;    };

struct q a[N];
struct bank b[32];
int front=-1;
int rear=-1;
unsigned long cpu=0;
unsigned long dim=0;
int end=1;
int k=0;
int time,core,op,l_col,i=0;
long long add;
FILE *fp, *fw;


int isFull() {
  if ((front == rear + 1) || (front == 0 && rear == N - 1)) return 1;
  return 0;
}

int empty()
{
	return front==-1;
}

//enqueue logic
void enq(int time,int core,int op,long long add)
{
	if(front==-1)
	{
		front=0;
	}
	rear=(rear+1)%N;
	a[rear].time=time;
	a[rear].core=core;
	a[rear].op=op;
	a[rear].row=(add>>18)&(((1<<16)-1));
	a[rear].u_col=(add>>12)&(0x3F);
	a[rear].l_col=(add>>2)&(0xF);
	a[rear].col= a[rear].u_col<<4 | a[rear].l_col;
	a[rear].ba= (add>>10)& (0x3);
	a[rear].bg= (add & ((0x7)<<7))>>7;
	a[rear].ch= (add & 1<<6)>>6;
	a[rear].bnk= a[rear].bg*4 + a[rear].ba;
	#ifdef DEBUG
		printf("time:%d core:%d operation:%d ba:%d bg:%d bank:%d row:%x column:%x\n", cpu,core,op,a[rear].ba,a[rear].bg,a[rear].bnk,a[rear].row,a[rear].col);
	#endif	
}

//dequeue logic
void deq()
{
	if(front==rear)
	{		
		rear=front=-1;
	}

	else 
	{
		front=(front+1)%N;
	}	
}

//delay logic
void delay(int t)
{
    for(int g=0;g<t;g++)
	{  
		if(front!=(rear+1)%N)
		{
			if(time<=cpu)
			{
			if(!feof(fp))
			{
				enq(time,core,op,add);
				if(fscanf(fp, "%d %d %d %llx", &time,&core,&op,&add)==EOF)
				{
					end=0;
				}
			}
			else if(end)
			{enq(time,core,op,add);
				end=0;
			}
			}
		}
		cpu++;
		dim=cpu/2;  
	}		
}

//closed page
#ifdef CLOSED
void dimm(struct q j)
{	
	fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "ACT0", 3, j.bg, 3, j.ba, 3, j.row);		
	delay(2);
	fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "ACT1", 3, j.bg, 3, j.ba, 3, j.row);	
	delay(2*trcd);
	if(j.op!=1)
	{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD1", 3, j.bg, 3, j.ba, 3, j.col);
        delay(2*(tras-trcd-1));
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d\n", 10, cpu, 3, j.ch, 6, "PRE", 3, j.bg, 3, j.ba);
        delay(2*((tcl+tburst)-(tras-trcd-1)));
        deq();
        for(int g=0;g<2*(trp-((tcl+tburst)-(tras-trcd-1)));g++)
		{if(front!=-1)
			{		
				if(!(a[front].bg==j.bg && a[front].ba==j.ba))
        		{
					k=1;
            		break;
        		}
			}
			if(front!=(rear+1)%N)
			{if(time<=cpu)
				{
					if(!feof(fp))
					{
						enq(time,core,op,add);
						if(fscanf(fp, "%d %d %d %llx", &time,&core,&op,&add)==EOF)
						{	
							end=0;
						}
					}
					else if(end)
					{
						enq(time,core,op,add);
						end=0;
					}
				}
			}
			cpu++;
			dim=cpu/2;
        	k=1;
		}			
    }
	
	else
	{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR1", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2*(cwl+tburst+twr));		
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d\n", 10, cpu, 3, j.ch, 6, "PRE", 3, j.bg, 3, j.ba);
		deq();
		for(int g=0;g<2*(trp);g++)
		{
        	if(front!=-1)
			{
				if(!(a[front].bg==j.bg && a[front].ba==j.ba))
        		{
					break;
        		}
			}

		if(front!=(rear+1)%N)
		{
			if(time<=cpu)
			{
				if(!feof(fp))
				{
				
					enq(time,core,op,add);
					if(fscanf(fp, "%d %d %d %llx", &time,&core,&op,&add)==EOF)
					{
						end=0;
					}
				}
				else if(end)
				{
					enq(time,core,op,add);
					end=0;
				}
			}
		}
		cpu++;
		dim=cpu/2;
        k=1;
        
		}		
	}   
}
#endif

//open page
#ifdef OPEN
void dimm(struct q j)
{
	if(b[j.bnk].st==0)
	{
	fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "ACT0", 3, j.bg, 3, j.ba, 3, j.row);		
	delay(2);
	fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "ACT1", 3, j.bg, 3, j.ba, 3, j.row);
	b[j.bnk].st=1;
	b[j.bnk].row=j.row;
	delay(2*trcd);
	if(j.op!=1)
	{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD1", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2*(tcl+tburst));
		deq();
		k=1;
		return;
	}
	else{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR1", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2*(cwl+tburst+twr));
		deq();
		k=1;
		return;
	}
	}
	else if(b[j.bnk].st==1 && b[j.bnk].row!=j.row)
	{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d\n", 10, cpu, 3, j.ch, 6, "PRE", 3, j.bg, 3, j.ba);
		delay(2*trp);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "ACT0", 3, j.bg, 3, j.ba, 3, j.row);		
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "ACT1", 3, j.bg, 3, j.ba, 3, j.row);
		b[j.bnk].st=1;
		b[j.bnk].row=j.row;
		delay(2*trcd);
		if(j.op!=1)
		{
			fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD0", 3, j.bg, 3, j.ba, 3, j.col);
			delay(2);
			fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD1", 3, j.bg, 3, j.ba, 3, j.col);
			delay(2*(tcl+tburst));
		}
	else{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR1", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2*(cwl+tburst+twr));
	}
	deq();
	k=1;
	return;
	}

	else{
	if(j.op!=1)
	{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "RD1", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2*(tcl+tburst));
		
	}
	else{
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR0", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2);
		fprintf(fw, "%-*lu%-*d%-*s%-*d%-*d%-*x\n", 10, cpu, 3, j.ch, 6, "WR1", 3, j.bg, 3, j.ba, 3, j.col);
		delay(2*(cwl+tburst+twr));
	}
	deq();
	k=1; //set increment flag
	return;
	}	
}
#endif

int main (int argc, char *argv[3])
{		
	if(argc>3)
	{
		printf("Enter Currect number of arguments!");
		return 0;
	}	
	if(argc>1)
	{
		fp=fopen(argv[1], "r");
	}
	else
	{
		fp=fopen("trace.txt","r");
	}

	if(argc>2)
	{
		fw=fopen(argv[2], "w");
	}
	else
	{
		fw=fopen("dram.txt","w");
	}
	
	//bank status initialisation
	for( int l=0;l<32;l++)
	{
		b[l].st=0;
		b[l].row=-1;
	}

	fscanf(fp, "%d %d %d %llx", &time,&core,&op,&add);  //read first line
	do
	{
		k=0; //reset increment flag
		if(cpu%2==0)
		{
			if(front!=-1)
			{
			   dimm(a[front]);				
			}
		}				
		if(front!=(rear+1)%N)
		{
			if(time<=cpu)
			{
			if(!feof(fp))
			{				
				enq(time,core,op,add);
				if(fscanf(fp, "%d %d %d %llx", &time,&core,&op,&add)==EOF)  //enqueue and read next line
                {
                    end=0;
                }				
			}
			else if(end) 
			{
				enq(time,core,op,add);
				end=0;
			}
			}
		}      
        if(k==0)
        {
            cpu++;
        } 
		dim=cpu/2;		
	}while((!feof(fp) || front!=-1) || end==1);	
	
	fclose(fp);
	fclose(fw);
	return 0;
}