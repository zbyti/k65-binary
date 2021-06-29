BEGIN{

xmax=64;

for(x=0;x<xmax;x++)
{
	p1=80-x-16+68;
	p2=80+x-16+68;

	r0 = 12;

	for(cx=0;cx<100;cx++)
	{
		resp=r0+5*cx;
		hx = resp*3-p1;
		if(hx>=-8 && hx<=7) break;
	}
	if(hx<0) hx+=16;

	for(cy=0;cy<100;cy++)
	{
		if(cy==0)	resp=r0+5*cx+3;
		else		resp=r0+5*cx+cy*5-1+3;
		hy = resp*3-p2;
		if(hy>=-8 && hy<=7) break;
	}
	if(hy<0) hy+=16;

	tcx[x]=cx;
	tcy[x]=cy;
	thm[x]=hx*16+hy
}


print "data CubeMoveX { align 64";
for(x=0;x<xmax;x++) printf("    %d\n",tcx[x]);
print "}";

print "data CubeMoveY { align 64";
for(x=0;x<xmax;x++) printf("    %d\n",tcy[x]);
print "}";

print "data CubeMoveH { align 64";
for(x=0;x<xmax;x++) printf("    0x%02X\n",thm[x]);
print "}";

}