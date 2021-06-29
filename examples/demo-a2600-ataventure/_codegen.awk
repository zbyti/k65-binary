

function update_scan_props()
{
	ndraw = 0;
	if(scanline%3==0) ndraw = 1;
	pdraw = drawing;
	if(!drawing != !ndraw)
		drawing = ndraw;
	if(pdraw && !ndraw) ins("cbg=x=0"   ,5,"drawing off");
	if(!pdraw && ndraw) ins("cbg=y y++" ,5,"drawing on");
}

function scaninfo()
{
	printf("\n");
	if(scanline%3==0)	printf("%-20s// SCANLINE %d, drawing display %s\n","",scanline,display);
	else				printf("%-20s// SCANLINE %d, drawing off\n","",scanline);
	printf("\n");
}

function ins(line,nc,expl)
{
	nscan = 0;
	scanpos += nc;
	while(!noscan && scanpos>=76) { scanpos-=76; scanline+=1; nscan=1; }
	printf("    %-16s// %+3d = s%d %2d  %s\n",line,nc,scanline,scanpos,expl);
	if(nscan) scaninfo();
	update_scan_props();
}

function getslot(nc)
{
	if(!drawing) return;
	if(drawing==1)
	{
		ins("pf0=x=" display "0",6,"draw nibble 0");
		ins("pf1=x=" display "1",6,"draw byte 1");
		ins("pf2=x=" display "2",6,"draw byte 2");
		drawing = 2;
	}
	if(drawing==2 && scanpos+nc>=41)
	{
		if(scanpos<42) ins("*" (42-scanpos),42-scanpos,"wait for screen center");
		ins("pf2=x=" display "3",6,"draw byte 3");
		ins("pf1=x=" display "4",6,"draw byte 4");
		ins("pf0=x=" display "5",6,"draw nibble 5");
		drawing = 3;
	}
}

function swap()
{
	while(drawing) ins("*" (76-scanpos),76-scanpos,"wait for drawing end to swap");
	ins("",0,"SWAP!!!");
	if(target=="px") { target="py"; display="px"; }
	else			 { target="px"; display="py"; }
}

function pixel(read)
{
	pixnum++;
	getslot(3); ins("a+sdx",3,"step");
	getslot(5); ins( read ,5,"shift pixel " pixnum);
}

function deadpixel(read)
{
	getslot(5);	ins( read ,5,"dead pixel");
}

function pixels(num,read)
{
	for(i=0;i<num;i++) pixel( target read );
}

function deadpixels(num,read)
{
	for(i=0;i<num;i++) deadpixel( target read );
}

function scaninit(pn)
{
	pixnum = pn;
	getslot(2); ins("c-"	 ,2,"scan setup A");
	getslot(3); ins("a=sbase",3,"scan setup B");
	getslot(3); ins("a+sdy"	 ,3,"scan setup C");
	getslot(3); ins("sbase=a",3,"scan setup D");
}

function scanpixels()
{
# reg 0000 11111111 22222222 33333333 44444444 5555
# bit 4567 76543210 01234567 76543210 01234567 7654
#	px5<<<
#	px4>>>
#	px3<<<
#	px2>>>
#	px1<<<
#	px0>>>

	pixels(4,"0>>>");
	pixels(8,"1<<<");
	pixels(8,"2>>>");
	pixels(8,"3<<<");
	pixels(8,"4>>>");
	pixels(3,"5<<<");

	pixnum++;
	getslot(3); ins("a+sdx",3,"step");
	ins("a=" target "5",3,"last shift start");
	ins("a<<<",2,"shift pixel " pixnum);
	for(i=0;i<4;i++) ins("a<<<",2,"dead shift");
	ins(target "5=a",3,"dead shift end");
}


BEGIN{
scanline = 0;
scanpos = 0;
drawing = 0;
noscan = 0;
target = "px";
display = "py";

print "func scanliner {";
scaninfo();
ins("",6,"cost of JSR instruction");
scaninit(   0); scanpixels();
swap();
scaninit(1000); scanpixels();
swap();

noscan = 1;
ins("",6,"cost of RTS");
ins("",5,"cost of DEC outside this routine");
ins("",3,"cost of BNE outside this routine");
if(scanpos<76) ins("*" (76-scanpos),76-scanpos,"wait for wsync");

print "}";

}