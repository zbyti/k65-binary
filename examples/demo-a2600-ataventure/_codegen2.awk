function add_kernel(fn,tmin,tmax,nc)
{
ker_fn[n_kernels]=fn;
ker_tmin[n_kernels]=tmin;
ker_tmax[n_kernels]=tmax;
ker_nc[n_kernels]=nc;
n_kernels++;
}

function scaninfo()
{
	printf("\n");
	printf("%-28s// SCANLINE %d\n","",scanline);
	printf("\n");
}

function ins_raw(line,nc,expl)
{
	scanline = sprintf("%d",scanpos/76)+0;
	start = sprintf("s%d %2d",scanline,scanpos-76*scanline);
	scanpos += nc;
	scanline = sprintf("%d",scanpos/76)+0;
	printf("    %-24s// [%s] %+3d = s%d %2d  %s\n",line,start,nc,scanline,scanpos-76*scanline,expl);
}

function do_kernel()
{
	ins_raw(ker_fn[kerdone],ker_nc[kerdone],"-k" kerdone "-");
	ker_tmin[kerdone] += 76;
	ker_tmax[kerdone] += 76;
	kerdone++;
	if(kerdone>=n_kernels)
		kerdone = 0;
}

function kertest(nc)
{
	if(scanpos>=ker_tmin[kerdone])
	{
		do_kernel();
		return 1;
	}

	if(scanpos+nc>ker_tmax[kerdone])
	{
		w8 = ker_tmin[kerdone]-scanpos;
		ins_raw("*" w8,w8,"-w-");
		do_kernel();
		return 1;
	}
	return 0;
}

function ins(line,nc,expl)
{
	while(kertest(nc)) {}
	ins_raw(line,nc,expl);
}

BEGIN{
n_kernels=0;
#add_kernel("cbg=a=(txtc),x",0,13,8);
add_kernel("pf1=y=frambuff,x",0,21-1,7);
add_kernel("pf1=y=tmp7",35,53,7);

scanpos = 6;
kerdone = 0;

print "func scanliner2 {";

ins("x++",2,"");
ins("gp0=y=frambuff+32,x",7,"");
ins("a=px3 a+px2 px3=a",9,"start X computation");
for(i=0;i<8;i++) ins("a+px1 a?0x80 tmp3<<<",10,"do X");
for(i=0;i<8;i++) ins("a+px1 a?0x80 tmp4>>>",10,"do X");
ins("a=py3 a+py2 py3=a",9,"start Y computation");
for(i=0;i<8;i++) ins("a+py1 a?0x80 tmp5<<<",10,"do Y");
for(i=0;i<8;i++) ins("a+py1 a?0x80 tmp6>>>",10,"do Y");
ins("a=tmp3 a^tmp5 gp1=a",9,"finalize 1");
ins("a=tmp4 a^tmp6 tmp7=a",9,"finalize 2");
#ins("cbg=a=0xDA",5,""); ins("*10",10,"");
#ins("y=a=x a=(tmp1),y cbg=a",12,""); ins("*3",3,"");

#ins("x?18",2,"");
#ins("*10",10,"");
#ins("*10",10,"");


ins("a=x c- a+dfx2 a&dfx3",10,"");
ins("tmp1=a",3,"");
ins("y=0 a=(tmp1),y",7,"");
ins("a&dfxN c- a+dfx4 cbg=a",11,"");
ins("*4",4,"");
ins("x?18",2,"");
ins("",0,"");

print "}";

}